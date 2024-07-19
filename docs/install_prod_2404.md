# Installation of production environment:

## Requirements:
  - A Virtual Private Server(VPS) on a Cloud Provider. 
  - Ubuntu 24.04 installed on server.
  - Access to root user, or a user with sudo privileges.
    - Ability to connect to server with ssh.
    - There are good tutorials you can follow on Cloud Providers. There are links below.
  - Finish the previous steps in "[Installation of development environment](./install_dev.md)" .

## Variables:
- Controller PC: Physical PC (Vagrant Host, Ansible Controller, Developer PC).
- local_user: local1
  - The user of your Controller PC. (Local Development PC)
- prod_ssh_key: produser1
- server_user: produser1
  - User name other than root. If there is no such user, we will create one.
- server_ip: 
  - Public IP of the VPS.
- server_ssh_port: 22
  - Server SSH Port. Default is 22. 
- domain_name_1: demo1.myserver.com
  - A domain name registered to you.
- domain_name_2: myserver.com
  - A domain name registered to you.
- local_workspace: local_workspace
  - The directory to store software source code.
- local_project_dir: dswebdocs
  - This directory holds dswebdocs workbench project.
- workbench_directory: /home/<local_user>/<local_workspace>/<local_project_dir>
  - Variable holds the full path to dswebdocs workbench project.
- compose_project_name: myproject
- my_dns_provider: hetzner
- my_dns_provider_dns_server_1_IP: 213.133.100.98
- my_dns_provider_dns_server_2_IP: 88.198.229.192

When you see these variables through the document , enter the values valid for your setup.

### Example:

**Document:**
```bash
$ ping <domain_name_1>
or
ping myserver.com
```

**Use it as:**
```bash
$ ping example.com
```
Dolar sign on the left is used to show it is a terminal command prompt.

## Files that must be created/modified/checked before use:

/etc/hosts

workbench_directory: /home/<local_user>/<local_workspace>/<local_project_dir>

workbench_directory/
  - ansible/inventory
  - dockerfiles/.env
  - dockerfiles/docker-compose.yml 
  - dockerfiles/fail2ban/jail.local
  - dockerfiles/traefik/traefik.yml
  - dockerfiles/traefik/dynamic.yml
  - dockerfiles/traefik/my_dns_provider_api_key.txt
  - dockerfiles/traefik/users.txt
  - vagrant/Vagrantfile

We will create/modify/check these files through the installation process.

## Initial Setup Ubuntu 24.04 on VPS

### On Developer PC:
Add your server user ssh key to ssh agent
```bash
$ ssh-add ~/.ssh/<prod_ssh_key>
```

If there is a non-root user with sudo privileges on the server, connect to server with that user. Then continue with "Update apt packages" step.

Else,

### On VPS: Creating a New User 
Connect to your server via ssh as a root user, then: 
```bash
adduser <server_user>
```
### On VPS: Granting Administrative(sudo) Privileges 
```bash
usermod -aG sudo <server_user>
rsync --archive --chown=<server_user>:<server_user> ~/.ssh /home/<server_user>
```
<kbd>CTRL</kbd>+<kbd>d</kbd> to end ssh session.


### Connect to VPS with the new user
```bash
ssh <server_user>@<server_ip> -p <server_ssh_port>
```

### On VPS: Update apt packages
Connect to server with ssh. Then,
```bash
sudo apt update
sudo apt upgrade
```
Reboot, if necessary.

### On VPS: Enable UFW firewall
Enabling two firewalls at the same time may cause some problems. Please follow your Cloud Provider's manuals before activating UFW firewall.
```bash
sudo ufw status
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw reload
sudo ufw status
```

### On VPS: SSH authentication and removing Password login

```bash
sudo nano /etc/ssh/sshd_config
```

Edit the file according to the following lines. Add the AllowUsers row, enter your user name in place <server_user> without the angle brackets.

```bash
PermitRootLogin no
PasswordAuthentication no
X11Forwarding no
AllowUsers <server_user>
```

<kbd>CTRL</kbd> + <kbd>o</kbd> to SAVE file.
<kbd>CTRL</kbd> + <kbd>x</kbd> to exit nano.


### On VPS: Restart ssh service
```bash
sudo systemctl restart sshd
```
The system is ready to be managed with Ansible, and a bit more secure.

-----

## On Controller PC: Check /etc/hosts file
Domain name must NOT be defined in /etc/hosts file. If there are rows related to production domain name, delete or comment out the rows.

## On VPS: Open Ports on Firewall for http, https, traefik, ping

```bash
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 8080
sudo ufw allow 8082
sudo ufw reload
sudo ufw status
```

8080 is for traefik, 8082 is for ping

## On Controller PC: Edit Ansible inventory file.
Edit Ansible inventory file. Enter Server IP address, ssh port, user name.

~/<local_workspace>/<local_project_dir>/ansible/inventory
```yaml
production:
  ansible_host: <server_ip>
  ansible_port: <server_ssh_port>
  ansible_user: <server_user>
```

Enter ssh key filename and path for production environment.
```yaml
production:
  ansible_ssh_private_key_file: ~/.ssh/<prod_ssh_key>
```

## Docker Compose Settings

Development and production environments differ in storage settings. Development environment uses Docker bind mounts. Bind mounts enable transfer of file changes to the related Docker container. In production this is not needed, also include security risks.

Docker Compose Profiles seperate development and production environments in docker-compose.yml.

### On Controller PC: Check the current environment

Check the current environment in <workbench_directory>/.env file. Uncomment production row, comment out development row.
```ini
# COMPOSE_PROFILES="development"
COMPOSE_PROFILES="production"
```

### On Controller PC:
**Enter your domain address in docker-compose.yml**
<workbench_directory>/docker-compose.yml
```yaml
services:
  ...
  reverse-proxy-production:
    profiles: ["production"]
    build:
    ...
      args:
        virtual_host: "traefik.myserver.com"

  app1-production:
    profiles: ["production"]
    build:
    ...
      args:
        virtual_host: "demo1.myserver.com"
  labels:
    ...
    traefik.http.routers.app1-https.rule: "Host(`demo1.myserver.com`)"
    ...
    traefik.http.routers.app1-https.tls.domains.main: "demo1.myserver.com"
```


**Enter a second domain address in docker-compose.yml**
<workbench_directory>/dockerfiles/docker-compose.yml
```yaml
services:
  ...

  app2-production:
    profiles: ["production"]
    build:
      ...
      args:
        virtual_host: "myserver.com"
  ...
  labels:
    ...
    traefik.http.routers.app2-https.rule: "Host(`myserver.com`)"
    ...
    traefik.http.routers.app2-https.tls.domains.main: "myserver.com"
```

## Configure Fail2ban
Edit file: <workbench_directory>/fail2ban/jail.local. Add the VPS server public IP address to **ignoreip** value list.

```ini
...
[traefik-forceful-browsing]
...
ignoreip = <enter your server IP address here> ...
...
```

## Install Docker on Production Server

### On Controller PC:
Add your ssh key to ssh agent
```bash
$ ssh-add ~/.ssh/<prod_ssh_key>
```

Run Ansible playbook
```bash
$ cd <workbench_full_path>/ansible
$ ansible-playbook installdocker.yml -l production --become-user <server_user>
```
Will ask "BECOME password" for production server user. We run Ansible commands on Controller PC, which make changes in Production Server via a ssh connection.

Reboot the Production Server to enable recently made changes.
```bash
$ cd <workbench_full_path>/ansible
$ ansible production -m ansible.builtin.reboot 
```

Test docker installation.
```bash
$ ssh <server_user>@<server_ip> -p <server_ssh_port>
$ docker run hello-world
```
Press [CTRL] + [d] to end ssh session.

## Docker build and run on Production Server

### On Controller PC:
```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
ansible-playbook dockerrebuild.yml -l production --become-user <server_user>
```

## Open sites on a web browser
Open a web browser, and visit the following addresses.

http://<domain_name_1>

http://<domain_name_2>

http://traefik.<domain_name_1>:8082/ping

https://traefik.<domain_name_1>:8080/dashboard/
( The last slash is important , do not omit it. )

These pages must run without problem at this point. Let's modify the index.html , and update the sites.

## Edit a source file
Related source files are in:
~/<local_workspace>/<local_project_dir>/dockerfiles/app1/data
  - www directory

~/<local_workspace>/<local_project_dir>/dockerfiles/app2/data
  - www directory

Edit ~/<local_workspace>/<local_project_dir>/dockerfiles/app1/data/www/index.html file with a text editor , make some changes in content, and save the file.

In production environment, we must do the following to update production server.
  - Stop docker containers, delete containers, delete volumes
  - Delete old docker images.
  - Upload new/updated files in dockerfiles directory. 
  - Create new docker images with the new content.
  - Run docker containers with new docker images.

All of these steps are defined in ansible/dockerrebuild.yml playbook. 

*** Warning: Backup first ***
*** Warning: This step will stop all the containers, and delete all the volumes of those containers.  ***

Run dockerrebuild.yml playbook
```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
ansible-playbook dockerrebuild.yml -l production --become-user <server_user>
```
Open a web browser, and go to: 'http://<domain_name_1>' .
You can refresh the page by pressing <kbd>SHIFT</kbd>+<kbd>F5</kbd> function key.  We can see the change at this point.

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

- Fail2ban
  - https://github.com/fail2ban/fail2ban
  - https://blog.lrvt.de/configuring-fail2ban-with-traefik/