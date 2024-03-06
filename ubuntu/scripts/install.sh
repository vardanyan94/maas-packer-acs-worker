#!/bin/bash

# Create the keyrings directory
sudo mkdir -p /etc/apt/keyrings

# Download and add the CloudStack GPG key to the keyring
wget -O- http://packages.shapeblue.com/release.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/cloudstack.gpg > /dev/null

# Add CloudStack repository to sources.list.d
echo 'deb [signed-by=/etc/apt/keyrings/cloudstack.gpg] http://packages.shapeblue.com/cloudstack/upstream/debian/4.18 /' | sudo tee /etc/apt/sources.list.d/cloudstack.list > /dev/null

# Update package list and upgrade packages include the new repository
apt update && DEBIAN_FRONTEND=noninteractive apt -y upgrade

# Install packages
DEBIAN_FRONTEND=noninteractive sudo apt install -y openntpd openssh-server sudo vim htop tar bridge-utils intel-microcode qemu-kvm cloudstack-agent libvirt-daemon-driver-storage-rbd

# Configure libvirt/qemu settings
sudo sed -i -e 's/\#vnc_listen.*$/vnc_listen = "0.0.0.0"/g' /etc/libvirt/qemu.conf
sudo sed -i -e 's/^LIBVIRTD_ARGS=""$/LIBVIRTD_ARGS="--listen"/g' /etc/default/libvirtd
echo 'listen_tls=0' >> /etc/libvirt/libvirtd.conf
echo 'listen_tcp=0' >> /etc/libvirt/libvirtd.conf
echo 'tls_port = "16514"' >> /etc/libvirt/libvirtd.conf
echo 'tcp_port = "16509"' >> /etc/libvirt/libvirtd.conf
echo 'mdns_adv = 0' >> /etc/libvirt/libvirtd.conf
echo 'auth_tcp = "none"' >> /etc/libvirt/libvirtd.conf

# Mask libvirtd sockets
systemctl mask libvirtd.socket libvirtd-ro.socket libvirtd-admin.socket libvirtd-tls.socket libvirtd-tcp.socket

#enable root login
sed -i 's/disable_root: true/disable_root: false/' /etc/cloud/cloud.cfg

#Configure sysctl file and apply it
echo 'net.bridge.bridge-nf-call-arptables = 0' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-iptables = 0' >> /etc/sysctl.conf
sysctl -p

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC43d42yEoEXOrHTa43O7CMkvDFmvYR9m1xvCNAZ1PIAXPDhyFa6Fz8QDEsdaVZVy3G6g9HSpOmPEXtkdRb1NtOz9+i41NiMGuDq7auv3LdXUx/D346NvOv1wilBZf+StVPIUdl8kGl7feswa7J8T/5rY8LoCoNPRWqeTPRDkjFunVhyZIrdMCqLjNxza7qr/YdyRWcael9vsvcFxC8Ko2oBZVHK1KQZp1hX6ThYJd3jpYqzhjyXatAfgkqGkGdBpc4l4uXkDKC/3E0aQh9cy27KEKk/wBepFSV759eqHPo7ZPW29Iwyad73jR8l2YuPJHIyA1nMtrj248sY/7ZtLJm3PD3/hprfOYNzuabqHLbD2rcXmGA4e1g80iF75MrHW3rLJAPuK58yS/U7jJad+zEEmjGemqRgPsHPCPLH6jblOakD7dUjjIh/4wpek959ZtZZQIuJ9W8tfRupFS/i+jF8CvNyokP4mm3U1n21Aiwi5mQrWvRw/Oys2id9ZGZI+0= cloud@asc-ctl1" >> /root/.ssh/authorized_keys
