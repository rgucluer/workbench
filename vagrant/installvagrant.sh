#!/bin/bash

# source: https://www.vagrantup.com/downloads
# Ubuntu
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant

sudo apt install qemu libvirt-daemon-system libvirt-clients libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev ruby-libvirt ebtables dnsmasq-base -y
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate

# Source: https://ostechnix.com/install-and-configure-kvm-in-ubuntu-20-04-headless-server/
# Install qemu
sudo apt install qemu-kvm virtinst bridge-utils -y
sudo systemctl enable libvirtd 
sudo systemctl start libvirtd

if [ -z "${VAGRANT_DEFAULT_PROVIDER}" ]; then
    echo "VAGRANT_DEFAULT_PROVIDER is undefined"
    echo "export VAGRANT_DEFAULT_PROVIDER=libvirt"  >> /etc/environment ;
    source /etc/environment;
    source ~/.bashrc;
    echo "VAGRANT_DEFAULT_PROVIDER is set to : '$VAGRANT_DEFAULT_PROVIDER'"; 
else
    echo "VAGRANT_DEFAULT_PROVIDER is already set to : '$VAGRANT_DEFAULT_PROVIDER'";  
fi

# virt-manager
sudo apt install virt-manager -y
