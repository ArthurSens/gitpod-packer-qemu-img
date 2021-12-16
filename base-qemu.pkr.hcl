packer {
  required_version = "~> 1.7.8"
}

variable "boot_wait" {
  type    = string
  default = "6s"
}

variable "communicator" {
  type    = string
  default = "ssh"
}

variable "cpus" {
  type    = string
  default = "4"
}

variable "description" {
  type    = string
  default = "Base box for x86_64 Ubuntu Jammy Jellyfish 22.04.x LTS"
}

variable "disk_size" {
  type    = string
  default = "30G"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "host_port_max" {
  type    = string
  default = "4444"
}

variable "host_port_min" {
  type    = string
  default = "2222"
}

variable "http_directory" {
  type    = string
  default = "."
}

variable "http_port_max" {
  type    = string
  default = "9000"
}

variable "http_port_min" {
  type    = string
  default = "8000"
}

variable "iso_checksum" {
  type    = string
  default = "file:http://cdimage.ubuntu.com/ubuntu-server/daily-live/pending/SHA256SUMS"
  # default = "sha256:0123456789abcdef"
}

variable "iso_file" {
  type    = string
  default = "jammy-live-server-amd64.iso"
}

variable "iso_path_external" {
  type    = string
  default = "http://cdimage.ubuntu.com/ubuntu-server/daily-live/pending"
}

variable "iso_path_internal" {
  type    = string
  default = "http://myserver:8080/ubuntu"
}

variable "memory" {
  type    = string
  default = "8192"
}

variable "packer_cache_dir" {
  type    = string
  default = "${env("PACKER_CACHE_DIR")}"
}

variable "qemu_binary" {
  type    = string
  default = "qemu-system-x86_64"
}

variable "shutdown_timeout" {
  type    = string
  default = "5m"
}

variable "ssh_agent_auth" {
  type    = string
  default = "false"
}

variable "ssh_clear_authorized_keys" {
  type    = string
  default = "false"
}

variable "ssh_disable_agent_forwarding" {
  type    = string
  default = "false"
}

variable "ssh_file_transfer_method" {
  type    = string
  default = "scp"
}

variable "ssh_handshake_attempts" {
  type    = string
  default = "100"
}

variable "ssh_keep_alive_interval" {
  type    = string
  default = "5s"
}

variable "ssh_password" {
  type    = string
  default = "1ma63b0rk3d"
}

variable "ssh_port" {
  type    = string
  default = "22"
}

variable "ssh_pty" {
  type    = string
  default = "false"
}

variable "ssh_timeout" {
  type    = string
  default = "60m"
}

variable "ssh_username" {
  type    = string
  default = "ghost"
}

variable "start_retry_timeout" {
  type    = string
  default = "5m"
}

variable "userdata_location" {
  type    = string
  default = "template/ubuntu/22.04_jammy"
}

variable "vm_name" {
  type    = string
  default = "test-packer"
}

variable "vnc_vrdp_bind_address" {
  type    = string
  default = "127.0.0.1"
}

variable "vnc_vrdp_port_max" {
  type    = string
  default = "6000"
}

variable "vnc_vrdp_port_min" {
  type    = string
  default = "5900"
}

# The "legacy_isotime" function has been provided for backwards compatability,
# but we recommend switching to the timestamp and formatdate functions.

locals {
  output_directory = "build/${legacy_isotime("2006-01-02-15-04-05")}"
}

source "qemu" "qemu" {
  accelerator = "kvm"
  boot_command = [
    "<wait><wait><wait><esc><esc><esc><enter><wait><wait><wait>",
    "/casper/vmlinuz root=/dev/sr0 initrd=/casper/initrd autoinstall ",
    "ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.userdata_location}/",
    "<enter>"
  ]
  boot_wait            = var.boot_wait
  communicator         = var.communicator
  cpus                 = var.cpus
  disk_cache           = "writeback"
  disk_compression     = false
  disk_discard         = "ignore"
  disk_image           = false
  disk_interface       = "virtio-scsi"
  disk_size            = var.disk_size
  format               = "raw"
  headless             = var.headless
  host_port_max        = var.host_port_max
  host_port_min        = var.host_port_min
  http_directory       = var.http_directory
  http_port_max        = var.http_port_max
  http_port_min        = var.http_port_min
  iso_checksum         = var.iso_checksum
  iso_skip_cache       = false
  iso_target_extension = "iso"
  iso_target_path      = "${var.packer_cache_dir}/${var.iso_file}"
  iso_urls = [
    "${var.iso_path_internal}/${var.iso_file}",
    "${var.iso_path_external}/${var.iso_file}"
  ]
  machine_type                 = "pc"
  memory                       = var.memory
  net_device                   = "virtio-net"
  output_directory             = local.output_directory
  qemu_binary                  = var.qemu_binary
  shutdown_command             = "echo '${var.ssh_password}' | sudo -E -S poweroff"
  shutdown_timeout             = var.shutdown_timeout
  skip_compaction              = true
  skip_nat_mapping             = false
  ssh_agent_auth               = var.ssh_agent_auth
  ssh_clear_authorized_keys    = var.ssh_clear_authorized_keys
  ssh_disable_agent_forwarding = var.ssh_disable_agent_forwarding
  ssh_file_transfer_method     = var.ssh_file_transfer_method
  ssh_handshake_attempts       = var.ssh_handshake_attempts
  ssh_keep_alive_interval      = var.ssh_keep_alive_interval
  ssh_password                 = var.ssh_password
  ssh_port                     = var.ssh_port
  ssh_pty                      = var.ssh_pty
  ssh_timeout                  = var.ssh_timeout
  ssh_username                 = var.ssh_username
  use_default_display          = false
  vm_name                      = var.vm_name
  vnc_bind_address             = var.vnc_vrdp_bind_address
  vnc_port_max                 = var.vnc_vrdp_port_max
  vnc_port_min                 = var.vnc_vrdp_port_min
}

build {
  description = "Can't use variables here yet!"

  sources = ["source.qemu.qemu"]

  provisioner "shell" {
    binary              = false
    execute_command     = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    expect_disconnect   = true
    inline              = ["apt-get update", "apt-get --yes dist-upgrade", "apt-get clean"]
    inline_shebang      = "/bin/sh -e"
    only                = ["qemu", "vbox"]
    skip_clean          = false
    start_retry_timeout = var.start_retry_timeout
  }

  provisioner "shell" {
    binary              = false
    execute_command     = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    expect_disconnect   = true
    inline              = ["dd if=/dev/zero of=/ZEROFILL bs=16M || true", "rm /ZEROFILL", "sync"]
    inline_shebang      = "/bin/sh -e"
    only                = ["qemu", "vbox"]
    skip_clean          = false
    start_retry_timeout = var.start_retry_timeout
  }

  post-processor "compress" {
    compression_level   = 6
    format              = ".gz"
    keep_input_artifact = true
    only                = ["qemu"]
    output              = "${local.output_directory}/${var.vm_name}.raw.gz"
  }
}