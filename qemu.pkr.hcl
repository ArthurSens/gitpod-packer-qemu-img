variable "image_name" {
  type    = string
  default = "var"
}

variable "source_image" {
  type    = string
  default = "var"
}

variable "zone" {
  type    = string
  default = "var"
}

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "qemu" "build_image" {
  image_labels = {
    ubuntu     = "21_10"
    kernel     = "v5_13"
    containerd = "v1_5_8"
    k3s        = "v1_22_3"
  }
  
  iso_url           = "http://mirror.raystedman.net/centos/6/isos/x86_64/CentOS-6.9-x86_64-minimal.iso"
  iso_checksum      = "md5:af4a1640c0c6f348c6c41f1ea9e192a2"
  output_directory  = "output_centos_tdhtest"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  disk_size         = "5000M" 
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "path/to/httpdir"
  ssh_username      = "root"
  ssh_password      = "s0m3password"
  ssh_timeout       = "20m"
  vm_name           = "tdhtest"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_wait         = "10s"
  boot_command      = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos6-ks.cfg<enter><wait>"]

}

build {
  sources = ["source.googlecompute.build_image"]

  provisioner "file" {
    source      = "${path.root}/linux/limits.conf"
    destination = "/tmp/limits.conf"
  }

  provisioner "file" {
    source      = "${path.root}/linux/containerd/containerd.toml"
    destination = "/tmp/containerd.toml"
  }

  provisioner "file" {
    source      = "${path.root}/linux/stargz-snapshotter/containerd-stargz-grpc.toml"
    destination = "/tmp/containerd-stargz-grpc.toml"
  }

  provisioner "file" {
    source      = "${path.root}/linux/stargz-snapshotter/stargz-snapshotter.service"
    destination = "/tmp/stargz-snapshotter.service"
  }

  provisioner "file" {
    source      = "${path.root}/airgap.txt"
    destination = "/tmp/airgap.txt"
  }

  provisioner "file" {
    source      = "${path.root}/setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "file" {
    source      = "${path.root}/kubernetes/kubelet-config.json"
    destination = "/tmp/kubelet-config.json"
  }

  provisioner "file" {
    source      = "${path.root}/linux/sysctl"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "${path.root}/kubernetes/manifests"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo bash -c 'cd /tmp; ./setup.sh'",
      "sleep 10",
      "sudo reboot --force"
    ]
    expect_disconnect = true
  }

  # Compile shiftfs after rebooting the VM with the new kernel
  provisioner "shell" {
    inline            = [
      "git clone -b k5.13 https://github.com/toby63/shiftfs-dkms.git /tmp/shiftfs-k513",
      "cd /tmp/shiftfs-k513; sudo make -f Makefile.dkms",
      "sudo modinfo shiftfs",
      "sudo rm /etc/hostname"
    ]
  }

  # cleanup journal logs
  provisioner "shell" {
    inline            = [
      "sudo journalctl --rotate",
      "sudo journalctl --vacuum-time=1s"
    ]
  }
}