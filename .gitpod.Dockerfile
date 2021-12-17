FROM gitpod/workspace-full

USER root


ENV WORKSPACE_KERNEL 5.4.0-1033-gke

RUN apt update -y && \
    apt install -y qemu qemu-system-x86 libguestfs-tools linux-image-$WORKSPACE_KERNEL sshpass netcat

## packer
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && apt-get install -y packer

RUN curl -o /usr/bin/kubectx https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx && chmod +x /usr/bin/kubectx \
 && curl -o /usr/bin/kubens  https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens  && chmod +x /usr/bin/kubens
