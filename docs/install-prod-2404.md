# Installation of production environment:

## Requirements:
  - A Virtual Private Server(VPS) on a Cloud Provider. 
  - Ubuntu 24.04 installed on server.
  - Access to root user, or a user with sudo privileges.
    - Ability to connect to server with ssh.
    - There are good tutorials you can follow on Cloud Providers. There are links below.
  - Finish the previous steps in "[Installation of development environment](./install_dev.md)" .
  

## Variables:
When you see these variables through the document , enter the values valid for your setup.

- Controller PC: Physical PC (Multipass Host, Ansible Controller, Developer PC).
  - local_user: local1
    - The user of your Controller PC. 
  - local_workspace: workspace
    - The directory to store software source code.
  - local_project_dir: workbench
    - This directory holds dswebdocs workbench project.
  - workbench_directory: 
    - /home/<local_user>/<local_workspace>/<local_project_dir>
    - /home/produser1/workspace/workbench
    - Variable holds the full path to dswebdocs workbench project.

- Virtual Private Server (VPS)
  - server_user: produser1
    - User name other than root. If there is no such user, we will create one.
  - prod_ssh_key: produser1
    - VPS server_user ssh key
  - server_ip: 
    - Public IP of the VPS.
  - server_ssh_port: 22
    - Server SSH Port. Default is 22. 

- domain_name_1: myserver.com
- domain_name_2: demo1.myserver.com
- domain_name_3: blog.myserver.com
  - Domain names controlled by you. Defined, and active in your DNS management system. Not defined in /etc/hosts (At least commented out).

- compose_project_name: myproject
- my_dns_provider: hetzner
- my_dns_provider_dns_server_1_IP: 213.133.100.98
- my_dns_provider_dns_server_2_IP: 88.198.229.192

- github_ssh_key: githubuser_key


### Example:

**Document:**
```bash
ping <domain_name_1>
or
ping myserver.com
```

**Use it as:**
```bash
ping enter_your_domain_name.com
```

## Stop Virtual Machine
```bash
multipass stop <vm_instance_name>
```

## Initial Setup Ubuntu 24.04 on VPS

### On Developer PC:
Add your server user ssh key to ssh agent
```bash
ssh-add ~/.ssh/<prod_ssh_key>
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
```

### On VPS: Copy .ssh directory of root to the new user's directory
```bash
rsync --archive --chown=<server_user>:<server_user> ~/.ssh /home/<server_user>
```

### On Developer PC:
On developer computer, don't close this terminal. Open a new terminal, try to login with the new user.

```bash
ssh <server_user>@<server_ip> -p <server_ssh_port>
```

### On VPS: 
If you are successful then switch to the first terminal (root user), and press <kbd>CTRL</kbd>+<kbd>d</kbd> to end the ssh session. 

### On VPS: Update apt packages
With the already open terminal:
```bash
sudo apt update
sudo apt upgrade
```
Reboot, if necessary.

### On VPS: Enable UFW firewall
Enabling two firewalls at the same time may cause some problems. Please follow your Cloud Provider's manuals before activating UFW firewall. Be sure to allow your ssh port in UFW, if you use another port other than 22 then allow that port instead of OpenSSH.
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

Edit the file according to the following lines. Add the AllowUsers row to the end of file, replace <server_user> with your server user name without the angle brackets.

```bash
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
X11Forwarding no
TCPKeepAlive yes
ClientAliveInterval 45
ClientAliveCountMax 3
AllowUsers <server_user>
```

<kbd>CTRL</kbd> + <kbd>o</kbd> to SAVE file.
<kbd>CTRL</kbd> + <kbd>x</kbd> to exit nano.


### On VPS: Restart ssh service
```bash
sudo systemctl restart ssh.service
```
The system is ready to be managed with Ansible, and a bit more secure.

-----

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

## [Docker Compose Settings](docker-compose-production.md)
Edit [Docker Compose](docker-compose-production.md) settings.

## On Controller PC: Check /etc/hosts file
In production environment domain names must NOT be defined in /etc/hosts file. If there are rows related to production domain name, delete or comment out the rows, save & exit.
```bash
sudo nano /etc/hosts
```
```txt
#<virtual_machine_IP> <domain_name_1>
#<virtual_machine_IP> demo1.<domain_name_1>
#<virtual_machine_IP> whoami.<domain_name_1>
#<virtual_machine_IP> traefik.<domain_name_1>
# If gatsby blog is installed
#<virtual_machine_IP> <domain_name_3>
```

## On Controller PC: Edit Ansible inventory file.
Edit Ansible inventory file. Enter Server IP address, ssh port, user name,ssh key .

<workbench_directory>/ansible/inventory
```yaml
prod_servers:
  hosts:
    production:
      ansible_host: <server_ip>
      ansible_port: <server_ssh_port>
      ansible_connection: ssh
      ansible_user: <server_user>
      ansible_become: true
      become_method: sudo
      ansible_ssh_private_key_file: ~/.ssh/<prod_ssh_key>
      docker_profile: production
```

## Install Docker on Production Server

### On Controller PC:
Add your VPS ssh key to ssh agent
```bash
ssh-add ~/.ssh/<prod_ssh_key>
```

Run Ansible playbook
```bash
cd <workbench_full_path>/ansible
```
```bash
ansible-playbook prod-installdocker.yml
```
Will ask "BECOME password" for production server user. We run Ansible commands on Controller PC, which make changes in Production Server via a ssh connection.

Reboot the Production Server to enable recently made changes.
```bash
ansible production -m ansible.builtin.reboot 
```

Test docker installation.
```bash
ssh <server_user>@<server_ip> -p <server_ssh_port>
```
```bash
docker run hello-world
```
Press [CTRL] + [d] to end ssh session.

## [Implement HTTPS, and setup Traefik](https-traefik-production.md)

## If Gatsby Blog is installed 
- We will not install node, and nvm on Virtual Private Server.
  - We installed them to use gatsby develop. We will upload and build images inside Virtual Private Server .
- We will use the project we created in development.

## Rebuild,and run the project on Production Server

### On Controller PC:
```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
```
```bash
ansible-playbook prod-rebuild.yml
```
Will ask for BECOME password of VPS user. Gatsby build time is a bit long, so be patient.

## Open sites on a web browser
Open a web browser, and visit the following addresses.

http://<domain_name_1>

http://<domain_name_2>

If you add a Gatsby Blog
http://<domain_name_3>

http://traefik.<domain_name_1>:8082/ping/

https://traefik.<domain_name_1>:8080/dashboard/
( The last slash is important , do not omit it. )

These pages must run without problem at this point. Let's modify the index.html , and update the sites.

## Edit a source file
- Edit ~/<local_workspace>/<local_project_dir>/dockerfiles/app1/data/www/index.html file with a text editor , make some changes in content, and save the file.

If Gatsby is installed:
- Change content, dockerfiles/gatsby/content/blog/hello-world/index.md
- Build Gatsby
```bash
cd <workbench_full_path>/dockerfiles/gatsby
```
```bash
gatsby build
```

In production environment, we must do the following to update production server.
  - Stop docker containers, delete containers, delete volumes
  - Delete old docker images.
  - Upload new/updated files in dockerfiles directory. 
  - Create new docker images with the new content.
  - Run docker containers with new docker images.

All of these steps are defined in ansible/tasks/prod-rebuild.yml playbook. 

*** Warning: Backup first ***
*** Warning: All DATA will be deleted. This step will stop all the containers, and delete all the volumes of those containers. You will lose all the state saved in those volumes. ***

Actually, there are other better methods for updating. I will learn and implement those methods in future commits. 

Run prod-rebuild.yml playbook
```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
```
```bash
ansible-playbook prod-rebuild.yml
```
Open a web browser, and go to: 'http://<domain_name_1>' .
You can refresh the page by pressing <kbd>SHIFT</kbd>+<kbd>F5</kbd> function key.  We can see the change at this point.

[Back to README](../README.md)

TODO: Learn and implement CI/CD methods to do these in a more convenient way.

-----

## References:
- Install Ubuntu on a VPS server
  - https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-22-04
  - https://community.hetzner.com/tutorials/howto-initial-setup-ubuntu
  - https://community.hetzner.com/tutorials/howto-ssh-key
  - https://community.hetzner.com/tutorials/security-ubuntu-settings-firewall-tools

- Ansible:
  - https://github.com/ansible/ansible/tree/v2.14.0
  - https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
  - https://www.ansible.com/overview/how-ansible-works
  - https://galaxy.ansible.com/geerlingguy/pip

- Docker:
  - https://docs.docker.com/engine/install/ubuntu
  - https://www.digitalocean.com/community/tutorials/how-to-use-ansible-to-install-and-set-up-docker-on-ubuntu-22-04

- Traefik
  - https://doc.traefik.io/traefik/https/acme/

- Fail2ban
  - https://github.com/fail2ban/fail2ban
  - https://blog.lrvt.de/configuring-fail2ban-with-traefik/
