# Installation steps of production environment:

## Requirements:
  - A Virtual Private Server on a VPS Hosting Provider. 
  - Ubuntu 22.04 installed on server.
  - Access to root user, or a user with sudo privileges.
    - Ability to connect to server with ssh.
    - There are good howtos you can follow on VPS Hosting Providers. There are links below.
  - Finish the previous steps in "Installation steps of development environment" .

## Variables:
- prod_ssh_key: produser1
- server_user: produser1
  - User name other than root. If there is no such user, we will create one.
- server_ip: 
  - Public IP of the server.
- server_ssh_port: 22
  - Server SSH Port. Default is 22. 
- domain_name_1: myserver1.com
  - Domain name that set to point to your VPS Server IP address.
- domain_name_2: myserver2.com
  - Another domain name you can add. (You can also add a subdomain demo.myserver1.com )
- local_workspace: dswebdocs
  - The directory to store software source code.
- local_project_dir: workbench
  - This directory holds dswebdocs workbench project
- workbench_directory: /home/<local_user>/<local_workspace>/<local_project_dir>
  - Variable holds the full path to dswebdocs workbench project.

When you see these variables inside '< >' symbols through the document, enter the values valid for your setup.

### Example:

**Document:**
```bash
ping <domain_name_1>
```

**Use it as:**
```bash
ping myserver1.com
```

## Files that must be modified/checked before use:

/etc/hosts

~/<local_workspace>/<local_project_dir>/
  - ansible/inventory
  - dockerfiles/.env
  - dockerfiles/nginx1-production.env
  - dockerfiles/nginx2-production.env

We will edit these files through the installation process.


## Initial Server Setup Ubuntu 22.04

If there is a non-root user with sudo privileges on the server, connect to server with that user. Then continue with "Update apt packages" step.
Else,

### On Server: Creating a New User 
Connect to your server via ssh as a root user. 
```bash
adduser <server_user>
```
### On Server: Granting Administrative(sudo) Privileges 
```bash
usermod -aG sudo <server_user>
rsync --archive --chown=<server_user>:<server_user> ~/.ssh /home/<server_user>
```
<kbd>CTRL</kbd>+<kbd>d</kbd> to end ssh session.


### Connect to server with the new user
```bash
ssh <server_user>@<server_ip> -p <server_ssh_port>
```

### On Server: Update apt packages
Connect to server with ssh. Then,
```bash
sudo apt update
sudo apt upgrade
```
Reboot, if necessary.


### On Server: Enable UFW firewall
Enabling two firewalls at the same time may cause some problems. Please follow your VPS Hosting Provider's manuals before activating UFW firewall.
```bash
sudo ufw app list
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw reload
sudo ufw status
```


### On Server: SSH authentication and removing Password login

```bash
sudo nano /etc/ssh/sshd_config
```

Edit the file according to the following lines. Add the AllowUsers row, enter your user name in place <server_user> without the angle brackets.

```bash
PermitRootLogin no
PasswordAuthentication no
X11Forwarding no
MaxAuthTries 5
AllowUsers <server_user>
```

<kbd>CTRL</kbd> + <kbd>o</kbd> to SAVE file.
<kbd>CTRL</kbd> + <kbd>x</kbd> to exit nano.


### On Server: Restart ssh service
```bash
sudo systemctl restart sshd
```
The system is ready to be managed with Ansible, and a bit more secure.

-----

## On Controller PC: Check /etc/hosts file
Domain name must not be defined in /etc/hosts file. If there is row related to production domain name, delete the row.

## On Controller PC: Edit Ansible inventory file.
Edit Ansible inventory file, enter Server IP address.

~/<local_workspace>/<local_project_dir>/ansible/inventory
```yaml
production1:
  ansible_host: <server_ip>
```

Enter ssh port.
```yaml
production1:
  ansible_port: <server_ssh_port>
```

Enter user name.
```yaml
production1:
  ansible_user: <server_user>
```

Enter ssh key filename and path for production environment.
```yaml
production1:
  ansible_ssh_private_key_file: ~/.ssh/<prod_ssh_key>
```

## Docker Compose Settings

Development and production environments differ in storage settings. Development environment uses Docker bind mounts. Bind mounts enable transfer of file changes to the related Docker container. In production this is not needed, also include security risks.

Docker Compose Profiles seperate development and production environments in docker-compose.yml.

**Check the current environment**
Check the current environment in ~/<local_workspace>/<local_project_dir>/dockerfiles/.env file . Uncomment production row, comment out development row.
```ini
# COMPOSE_PROFILES="development"
COMPOSE_PROFILES="production"
```

**Enter your domain address in nginx1-production.env**
~/<local_workspace>/<local_project_dir>/dockerfiles/nginx1-production.env
```yaml
APP_FOLDER="site1"
VIRTUAL_HOST="example.com"
```

**Enter a second domain address in nginx2-production.env**
~/<local_workspace>/<local_project_dir>/dockerfiles/nginx2-production.env
```yaml
APP_FOLDER="site2"
VIRTUAL_HOST="example2.com"
```

## Install Docker on Production Server

Add your ssh key to ssh agent
```bash
ssh-add ~/.ssh/<prod_ssh_key>
```

Run Ansible playbook
```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
ansible-playbook installdocker.yml -l production1
```
Will ask "BECOME password" for production server user. We run Ansible commands on Controller PC, which make changes in Production Server via a ssh connection.

Reboot the Production Server to enable recently made changes.
```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
ansible production1 -m ansible.builtin.reboot 
```

Test docker installation.
```bash
ssh <server_user>@<server_ip> -p <server_ssh_port>
docker run hello-world
```
Press [CTRL] + [d] to end ssh session.

## Copy files to remote server

```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
ansible-playbook filescopytoremote.yml -l production1
```

## Docker build and run on Production Server

```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
ansible-playbook dockerbuild.yml -l production1
ansible-playbook dockerup.yml -l production1
```

## Open Ports on Firewall for http and https

```bash
sudo ufw allow http
sudo ufw allow https
sudo ufw reload
sudo ufw status
```

## Open sites on a web browser
Open a web browser, and visit the following addresses.

http://<domain_name_1>/

http://<domain_name_2>/

These pages must run without problem at this point. Let's modify the index.html , and update the sites.

## Edit a source file
Related source files are in:
~/<local_workspace>/<local_project_dir>/dockerfiles/site1/data
  - www directory

~/<local_workspace>/<local_project_dir>/dockerfiles/site2/data
  - www directory

Edit ~/<local_workspace>/<local_project_dir>/dockerfiles/site1/data/www/index.html file with a text editor , make some changes in content, and save the file. 

In production environment, we must do the following to update production server.
  - Stop docker containers, delete containers, delete volumes.
  - Delete old docker images we build before.
  - Upload new/updated files in dockerfiles directory. 
  - Create new docker images with the new content.
  - Run docker containers with new docker images.

All of these steps are defined in ansible/dockerrefresh.yml playbook. 

*** Warning: Backup first ***
*** Warning: this step will stop all the containers, and delete all the volumes of those containers. Backup up first, or edit dockerrefresh.yml***

Run dockerrefresh.yml playbook
```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
ansible-playbook dockerrefresh.yml -l production1 --become-user <server_user>
```

Open a web browser, and go to: 'http://<domain_name_1>' .
You can refresh the page by pressing <kbd>SHIFT</kbd>+<kbd>F5</kbd> function key.


[Back to README](../README.md)

-----

## References:
- Install Ubuntu on a VPS server
  - https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-22-04

- Ansible:
  - https://github.com/ansible/ansible/tree/v2.14.0
  - https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
  - https://www.ansible.com/overview/how-ansible-works
  - https://galaxy.ansible.com/geerlingguy/pip
  - https://www.digitalocean.com/community/tutorials/how-to-use-ansible-to-install-and-set-up-docker-on-ubuntu-22-04
