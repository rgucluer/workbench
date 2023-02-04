# Dswebdocs workbench
Development environment using Vagrant, Libvirt, Qemu, Docker, Git and Ansible.

I am learning web development. I want to make my development environment and production server as similar as possible. A Vagrant VM will mimic the production VPS(Virtual Private Server). Docker containers will somewhat isolate running services inside VM/VPS. Ansible will automate installation/management processes as possible. 

Developed on Pop!_OS, so these instructions will work on Ubuntu 22.04, and Pop!_OS 22.04 without problem. Not tested on other systems at the moment. 

The process is not fully automated, will automate more as I learn.

I am open to suggestions. You can reach me via rgucluer [at] gmail.com

Requirements:
    Operating System: Ubuntu 22.04, or Pop!_OS 22.04

# Installation steps for Controller PC development environment:

Controller PC: Physical PC (Vagrant Host, Ansible Controller, Developer PC).

Vagrant VM: The virtual machine created by Vagrant.

## Install git
```
sudo apt-get update
sudo apt install git-all -y
git config --global user.name "Replace with your Name Surname"
git config --global user.email your_email@example.com
git config --list
```
Reference: https://github.com/git-guides/install-git


## Create a folder to use with this project

```bash
mkdir ~/dswebdocs
```

## Clone repository

```bash
cd ~/dswebdocs
git clone  https://github.com/dswebdocs/workbench.git
```

## Create a ssh key pair for workbench

```bash
cd ~/.ssh
ssh-keygen -t rsa 4096 -f devuser1
```
It will ask for a passphraze, you can enter one, or skip it by pressing [ENTER] . ( You will need this passphraze later, keep it safe. )

Make key pair readable/writable only by the user: 
```bash
chmod u=wr-,g=---,o=--- ~/.ssh/devuser1*
```

Add ssh key to ssh agent:
```bash
ssh-add ~/.ssh/devuser1
```

## Install Vagrant

You can install Vagrant, Qemu, virt-manager, etc... with the following command in terminal
```bash
cd ~/dswebdocs/workbench/vagrant
./installvagrant.sh
```
References:

https://www.vagrantup.com/downloads

https://ostechnix.com/install-and-configure-kvm-in-ubuntu-20-04-headless-server/

https://www.qemu.org/

https://virt-manager.org/


## Check Vagrantfile

Open ~/dswebdocs/workbench/vagrant/Vagrantfile ,and check for 
```bash
ssh_key_filename="devuser1"
```
The value must be equal to the ssh key name we created in "Create a ssh key pair for workbench" step.

## Run Vagrant
```bash
cd ~/dswebdocs/workbench/vagrant
vagrant up --provision
```
![ip address](docs/images/vagrant_ip_address.png)

Note the IP address in the output. We will use in the following steps.


## Test Vagrant ssh login 

Enter the IP Address from the previous step ( without < >  characters ).
Will ask "Are you sure you want to continue connecting (yes/no/[fingerprint])?" , write  "yes" and press ENTER .

```bash
ssh vagrant@<IP Address>
```

Now, we are in the Vagrant VM. Let's list the current directory.

![vagrant pwd](docs/images/vagrant_pwd.png)

Exit from ssh session, press [CTRL]+[D].

![vagrant pwd](docs/images/vagrant_exit_ssh.png)

Now, we are back in Controller PC .

## Files that must be modified/checked before use:

/etc/hosts

~/dswebdocs/workbench/dockerfiles/site1/nginx/conf.d/site1.conf

~/dswebdocs/workbench/dockerfiles/site2/nginx/conf.d/site2.conf

~/dswebdocs/workbench/ansible/inventory

We will edit these files through the installation process.

## Edit /etc/hosts file 

Add the following rows end of /etc/hosts file. Enter IP address for ansible_host we noted at previous steps ( without < >  characters ).

```
<IP Address> site1.local
<IP Address> site2.local
```

## Check site1 nginx config file
Open ~/dswebdocs/workbench/dockerfiles/site1/nginx/conf.d/site1.conf

Check server_name value
```
    server_name site1.local;
```
This variable must point to a domain name. For this tutorial we use site1.local for the first site. If you want to point this to another address then change this variable in this file, and also change it in /etc/hosts file. After you change these values you must also delete old docker images, and create new images.


## Check site2 nginx config file
Open ~/dswebdocs/workbench/dockerfiles/site2/nginx/conf.d/site2.conf

Check server_name value
```
    server_name site2.local;
```

## Edit Ansible inventory file 
~/dswebdocs/workbench/ansible/inventory

Enter IP address for ansible_host we noted at previous steps ( without < >  characters ).

```yaml
...
    development:
...
      ansible_host: <IP Address>
```

Enter ssh key filename and path for development environment

```yaml
...
    development:
...
      ansible_ssh_private_key_file: ~/.ssh/devuser1
```

Enter docker files directory name (only directory name)

```yaml
...
    development:
...
      docker_directory: dockerfiles
```

Enter full path for dockerfiles directory

```yaml
docker_directory_full_path: /home/user_name/dswebdocs/workbench/dockerfiles
```

## Install Ansible 

```bash
hash -r
sudo  ln -sf python3.10 /usr/bin/python
pip3 install ansible
```

References:

https://github.com/ansible/ansible/tree/v2.14.0

https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

## List hosts with Ansible 

```bash
cd ~/dswebdocs/workbench/ansible
ansible -i inventory all --list-hosts

-list-hosts
  hosts (2):
    production1
    development
```

## Install Docker on Vagrant VM 

```bash
cd ~/dswebdocs/workbench/ansible
ansible-playbook installdocker.yml -l development -i inventory --ask-become-pass
```
We run Ansible commands on Controller PC, which make changes in Vagrant VM via a ssh connection.

Reference: https://www.ansible.com/overview/how-ansible-works

Enter the following commands to enable recently made changes to files and user.
```bash
cd ~/dswebdocs/workbench/vagrant
vagrant halt
vagrant up
```

Test docker installation. Enter IP address for ansible_host we noted at previous steps ( without < >  characters ).
```bash
ssh vagrant@<IP Address>
docker run hello-world
```
Press [CTRL] + [d] to end ssh session.


## Python and pip steps 
```bash
cd ~/dswebdocs/workbench/ansible
ansible-playbook pythonpip.yml -l development -i inventory --ask-become-pass	
```
This creates a symlink for python3.10, installs python3-pip apt package, and installs requests python module on Vagrant VM.

## Deploy two static sites on Vagrant VM
```bash
cd ~/dswebdocs/workbench/vagrant
vagrant halt
vagrant up

cd ~/dswebdocs/workbench/ansible
ansible-playbook dockerbuild.yml -l development -i inventory --ask-become-pass  -vvv
ansible-playbook dockerup.yml -l development -i inventory --ask-become-pass  -vvv
```

## Open sites on a web browser
Open a web browser, and visit the following addresses.

http://site1.local/

http://site2.local/
