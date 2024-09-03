# Installation of development environment:

This document in not up to date.

## Requirements:
- Operating System: Ubuntu 22.04, or Pop!_OS 22.04.
- Virtualization enabled.
- For Letsencrypt HTTPS support
  - A valid registered domain name.

### Variables:
- Controller PC: Physical PC (Vagrant Host, Ansible Controller, Developer PC).
- Vagrant VM: The virtual machine created by Vagrant in Controller PC.
- vagrant_ssh_key: devuser1
- local_user: local1
  - The user of your Controller PC. (Local Development PC)
- vagrant_vm_IP:
  - Vagrant sets an IP address on the first run of the VM. 
- domain_name_1: demo1.myserver.com
  - A domain name defined in /etc/hosts file.
- domain_name_2: myserver.com
  - A domain name defined in /etc/hosts file.
- local_workspace: local_workspace
  - The directory to store software source code.
- local_project_dir: workbench
  - This directory holds dswebdocs workbench project
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
ping <domain_name_2>
or
ping myserver.com
```

**Use it as:**
```bash
ping example.com
```
Dolar sign on the left is used to show it is a terminal command prompt.

## On Controller PC: Install Ansible 

### Install Pip
```bash
cd ~
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
```

**Add ~/.local/bin directory PATH variable**
```bash
nano ~/.bashrc
```
This will open .bashrc file. Add the following line, save & exit. Enter your system user name on Controller PC replacing <user_name> without angle brackets.
```bash
export PATH="$PATH:/home/<user_name>/.local/bin"
```

Reload settings:
```bash
source ~/.bashrc
```

### Install Ansible

```bash
python3 -m pip install -U pip setuptools
python3 -m pip install -U pip requests
python3 -m pip install --upgrade --user ansible
```

## Install git
```bash
sudo apt install git-all -y
```

## Create a workspace directory if you don't have one

```bash
mkdir ~/<local_workspace>
```


## Clone repository

```bash
cd ~/<local_workspace>
git clone  https://github.com/dswebdocs/workbench.git
```

## Files that must be modified/checked before use:

/etc/hosts

~/<local_workspace>/<local_project_dir>/
  - ansible/inventory
  - vagrant/Vagrantfile
  - dockerfiles/.env
  - dockerfiles/docker-compose.yml 
  - dockerfiles/traefik/traefik.yml
  - dockerfiles/traefik/dynamic.yml
  - dockerfiles/traefik/my_dns_provider_api_key.txt
  - dockerfiles/traefik/users.txt

We will edit these files through the installation process.

## Set your Preferred TimeZone

View your current setting:
```bash
timedatectl
```

View results. If it does not fits your own timezone, you can set it as you wish.
```bash
               Local time: Sun 2024-05-19 12:19:29 +03
           Universal time: Sun 2024-05-19 09:19:29 UTC
                 RTC time: Sun 2024-05-19 09:19:29
                Time zone: Europe/Istanbul (+03, +0300)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```


First, list time zones, and select your zone:
```bash
timedatectl list-timezones
```

Use <kbd>up</kbd> , <kbd>down</kbd> keys, and <kbd>PgUp</kbd>/<kbd>PgDown</kbd> keys to navigate. Note or copy your selection.

Then, set it :
```bash
sudo timedatectl set-timezone Europe/Istanbul
```


## Create a ssh key pair for workbench

```bash
cd ~/.ssh
ssh-keygen -t rsa 4096 -f ~/.ssh/<vagrant_ssh_key>
```
It will ask for a passphraze, you can enter one, or skip it by pressing <kbd>ENTER</kbd> . ( You will need this passphraze later, keep it safe. )

Make key pair readable/writable only by the user: 
```bash
chmod u=wr-,g=---,o=--- ~/.ssh/<vagrant_ssh_key>*
```

Add ssh key to ssh agent:
```bash
ssh-add ~/.ssh/<vagrant_ssh_key>
```

## Docker Compose Settings

Development and production environments differ in storage settings. Development environment uses Docker bind mounts. Bind mounts enable transfer of file changes to the related Docker container. In production this is not needed, also include security risks. 

Docker Compose Profiles seperate development and production environments in docker-compose.yml.


### On Controller PC: Check the current environment

Check the current environment in ~/<local_workspace>/<local_project_dir>/dockerfiles/.env file. Uncomment development row, comment out production row.
```ini
COMPOSE_PROFILES="development"
# COMPOSE_PROFILES="production"
```

### On Controller PC:
**Enter your domain address in docker-compose.yml**
~/<local_workspace>/<local_project_dir>/dockerfiles/docker-compose.yml
```yaml
services:
  ...
  reverse-proxy-development:
    profiles: ["development"]
    build:
    ...
      args:
        virtual_host: "traefik.myserver.com"

  app1-development:
    profiles: ["development"]
    build:
    ...
      args:
        virtual_host: "demo1.myserver.com"
    ...
    labels:
      traefik.enable: true
      traefik.http.routers.app1-https.rule: "Host(`demo1.myserver.com`)"
      traefik.http.routers.app1-https.entryPoints: "web-secure"
      traefik.http.routers.app1-https.service: "app1-development-myproject"
      traefik.http.routers.app1-https.tls.domains.main: "demo1.myserver.com"
```

**Enter a second domain address in docker-compose.yml**
~/<local_workspace>/<local_project_dir>/dockerfiles/docker-compose.yml
```yaml
services:
  ...

  app2-development:
    profiles: ["development"]
    build:
      ...
      args:
        virtual_host: "myserver.com"
  ...
  labels:
    traefik.enable: true
    traefik.http.routers.app2-https.rule: "Host(`myserver.com`)"
    traefik.http.routers.app2-https.entryPoints: "web-secure"
    traefik.http.routers.app2-https.service: "app2-development-myproject"
    traefik.http.routers.app2-https.tls.domains.main: "myserver.com"
```


## On Controller PC: Install Vagrant

### Copy inventory.example file as inventory
```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
cp inventory.example inventory
```

### Edit Ansible inventory file 

~/<local_workspace>/<local_project_dir>/ansible/inventory

Enter full path for workbench directory.

```yaml
workbench_full_path: /home/<local_user>/<local_workspace>/<local_project_dir>
```

### Install Vagrant
Current user must have sudo privileges.

The following commands will install Vagrant, Qemu, libvirt, virt-manager, and related other packages.

```bash
cd ~/<local_workspace>/<local_project_dir>/ansible
ansible-galaxy install -r requirements.yml --force
ansible-playbook workbench.yml
```
"BECOME password" is the password of the current system user.

### Check Vagrantfile

Open <workbench_full_path>/vagrant/Vagrantfile, and check for the following

```bash
ssh_key_filename="<vagrant_ssh_key>"
```
The value must be equal to the ssh key name we created in "Create a ssh key pair for workbench" step ( devuser1 ).


### Run Vagrant
```bash
cd <workbench_full_path>/vagrant
vagrant up
```
![ip address](images/vagrant_ip_address.png)

Note the IP address in the output ( vagrant_vm_IP ) . We will use in the following steps.


### Edit /etc/hosts file
Add the following rows to the /etc/hosts file with a text editor. You must run the text editor with sudo privileges.
```bash
sudo nano /etc/hosts
```
Add the following rows to the end of file.
```bash
<vagrant_vm_IP> <local_domain_name_1>
<vagrant_vm_IP> <local_domain_name_2>
```
<kbd>CTRL</kbd> + <kbd>o</kbd> to Save (o is, as in oscar).

<kbd>CTRL</kbd> + <kbd>x</kbd> to Exit.

Web browser is directed to this virtual machine when we enter http://<local_domain_name_1> to the address bar.


### Test Vagrant ssh login 

```bash
ssh vagrant@<vagrant_vm_IP>
```

Will ask "Are you sure you want to continue connecting (yes/no/[fingerprint])?" , write  "yes" and press <kbd>ENTER</kbd> .

If you set a passphraze for your ssh key, it may ask for the passphraze.
( It won't ask for a passphraze if you add your ssh key beforehand to ssh-agent. )

Now, we are in the Vagrant VM. Let's see the current directory.

![vagrant pwd](images/vagrant_pwd.png)

Exit from ssh session, press <kbd>CTRL</kbd>+<kbd>D</kbd>.

![vagrant pwd](images/vagrant_exit_ssh.png)

Now, we are back in Controller PC .


### Start rsync-auto

Start Vagrant Virtual Machine (if not working):
```bash
cd <workbench_full_path>/vagrant
vagrant up
```

Open a new terminal, start rsync-auto.
```bash
cd <workbench_full_path>/vagrant
vagrant rsync-auto
```
rsync-auto keeps running in foreground until we exit.
rsync replicates changes from Ansible Controller to Vagrant VM.

<workbench_full_path>/vagrant/Vagrantfile
config.vm.synced_folder sets which directory to sync.


### Stop rsync-auto
Switch to the terminal runnig synch-auto. <kbd>CTRL</kbd>+<kbd>c</kbd> to stop rsync-auto .


### Stop vagrant VM
```bash
cd <workbench_full_path>/vagrant
vagrant halt
```


## Edit Ansible inventory file 
Enter IP address for ansible_host we noted at previous steps.

<workbench_full_path>/ansible/inventory
```yaml
development:
  ansible_host: <vagrant_vm_IP>
```

Check ssh key filename and path.

```yaml
development:
  ansible_ssh_private_key_file: ~/.ssh/<vagrant_ssh_key>
```


## On Controller PC: Install Docker on Vagrant VM 

Add your ssh key to ssh agent
```bash
ssh-add ~/.ssh/<vagrant_ssh_key>
```

Run Vagrant VM
```bash
cd <workbench_full_path>/vagrant
vagrant up
```

Run Ansible playbook
```bash
cd <workbench_full_path>/ansible
ansible-playbook installdocker.yml -l development --become-user vagrant
```
Will ask "BECOME password" for Vagrant VM user, enter "vagrant".
Default password for vagrant user is "vagrant". We run Ansible commands on Controller PC, which make changes in Vagrant VM via a ssh connection.

Reboot the Vagrant VM to enable recently made changes.
```bash
cd <workbench_full_path>/vagrant
vagrant reload --provision
```

Test docker installation.
```bash
ssh vagrant@<vagrant_vm_IP>
docker run hello-world
```
Press [CTRL] + [d] to end ssh session.

## On Controller PC: Implement HTTPS

### Obtain your API Key from your Service Provider
- Read your Cloud provider's document and get your DNS API KEY
  - https://doc.traefik.io/traefik/https/acme/#providers

Many lego environment variables can be overridden by their respective _FILE counterpart, which should have a filepath to a file that contains the secret as its value. 

- Save the API key to a file.

- Add this file to your .gitignore file

### Generate Letsencrypt certificates with Lego
```bash
cd <workbench_full_path>/dockerfiles/traefik/
```
Enter values that matches your setup.
```bash
HETZNER_API_KEY_FILE=my_dns_provider_api_key.txt \
lego --email my_email@myserver.com  \
--server=https://acme-staging-v02.api.letsencrypt.org/directory \
--dns <my_dns_provider> \
--accept-tos \
--dns.resolvers "<my_dns_provider_dns_server_1>" \
--dns.resolvers "<my_dns_provider_dns_server_2>" \
--dns.resolvers "8.8.8.8:53" \
--dns-timeout 60 \
--domains *.myserver.com \
--domains myserver.com \
run
```
Terminal output:
```bash
Saved key to <workbench_full_path>/dockerfiles/traefik/.lego/accounts/acme-v02.api.letsencrypt.org/my_email@myserver.com/keys/my_email@myserver.com.key

2024/02/22 16:36:05 Please review the TOS at https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf
Do you accept the TOS? Y/n
```

Y [ENTER]

```bash
2024/02/22 16:37:03 [INFO] acme: Registering account for my_email@myserver.com

Your account credentials have been saved in your Let's Encrypt configuration directory at "<workbench_full_path>/dockerfiles/traefik/.lego/accounts".

You should make a secure backup of this folder now. This
configuration directory will also contain certificates and
private keys obtained from Let's Encrypt so making regular
backups of this folder is ideal.
```

The certificate files must persist between docker sessions, rsync must not delete certificate files.

Lego automaticaly updates certificates. But it will save the latest certificates to docker container storage. If these certificates are saved to development directory, we can prevent unnecassary certification renewals

TODO: Automate downloading Letsencrypt Certificates to Controller PC. 
  - Check status of Letsencrypt certificates on traefik container.
  - Save new certificates from docker container to VPS dockerfiles directory.
  - Download new certificates from VPS to Controller PC. 

### Set related values in docker-compose.yml for traefik

```yaml

services:
  reverse-proxy-development:
    profiles: ["development"]
    ...

    # Add your DNS Auth. API keys here.
    environment:
      - "PROVIDER_API_KEY_FILE=/path/to/file/my_dns_provider_api_key.txt"

```

### Set related values in traefik/traefik.yml
```yaml
providers:
  docker:
    ...

    defaultRule: Host(`traefik.myserver.com:8080`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))
    ...

certificatesResolvers:
  myresolver:
    acme:
      # caServer: https://acme-staging-v02.api.letsencrypt.org/directory
      caServer: "https://acme-v02.api.letsencrypt.org/directory"
      email: "my_email@myserver.com"
      storage: "/traefik/storage/acme.json"

      dnsChallenge:
        # DNS Providers LEGO CLI flag name
        # Detailed information : https://go-acme.github.io/lego/dns/
        provider: "my_dns_provider"
        delayBeforeCheck: "60"

        # Use following DNS servers to resolve the FQDN authority.
        resolvers:
        - "<my_dns_provider_dns_server_1_IP>:53"
        - "<my_dns_provider_dns_server_2_IP>:53"
        - "1.1.1.1:53"
        - "8.8.8.8:53"
        disablePropagationCheck: false
```

### Change file permissions for acme.json
```bash
cd <workbench_full_path>/dockerfiles/traefik/storage
chmod 600 acme.json
```

### Set related values in traefik/dynamic.yml

```yaml
http:
  routers:
  ...

    reverse-proxy-https:
      rule: Host(`traefik.myserver.com`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))
      entryPoints: "traefik"
      service: "api@internal"
      tls:
        certResolver: myresolver
        domains:
          - main: "traefik.myserver.com"

    ping-https:
      rule: Host(`traefik.myserver.com`) && PathPrefix(`/ping`)
      entryPoints: "ping"
      service: ping@internal
      tls:
        certResolver: myresolver
        domains:
          - main: "traefik.myserver.com"

tls:
  ...

  certificates:
    - certFile: /traefik/storage/.lego/certificates/_.myserver.com.crt
      keyFile: /traefik/storage/.lego/certificates/_.myserver.com.key
  ...

```

### Add authentication to Traefik Dashboard

Add an encrypted credential to dockerfiles/traefik/users.txt file

```yaml
cd <workbench_directory>/dockerfiles
printf "<user_name>:$(openssl passwd -apr1 <enter_password>)\n" >> ./traefik/users.txt
```

Enter the user_name, and password as you wish. 


dockerfiles/docker-compose.yml

```yaml
services:
  reverse-proxy-development:
    ...
    volumes:
    # User Credentials
    - "./traefik/users.txt:/etc/traefik/users.txt"
```

dockerfiles/traefik/traefik.yml

```yaml

providers:
  docker:
    ...
 
  file:
    filename: /etc/traefik/dynamic.yml
    watch: true

entryPoints:
  traefik:
    address: ":8080"
    http:
      redirections:
      ...

      middlewares:
        - auth
```

dockerfiles/traefik/dynamic.yml

```yaml
  middlewares:
    auth:
      basicAuth:
        usersFile: "/etc/traefik/users.txt"
```

Now, lets rebuild the project.
```yaml
cd <workbench_directory>/ansible
ansible-playbook dockerrebuild.yml -l development --become-user vagrant
```

Will ask "BECOME password" for Vagrant VM user, enter "vagrant".


### Open sites on a web browser
Open a web browser, and visit the following addresses.

http://<domain_name_1>

http://<domain_name_2>

http://traefik.<domain_name_1>:8082/ping

https://traefik.<domain_name_1>:8080/dashboard/
( The last slash is important , do not omit it. )

These pages must run without problem at this point. Let's modify the index.html , and update the sites.

### Run rsync-auto
Open a new terminal, start rsync-auto.
```bash
cd <workbench_full_path>/vagrant
vagrant rsync-auto
```

### Edit a source file
Related source files are in:
<workbench_full_path>/dockerfiles/app1/data
  - www directory

<workbench_full_path>/dockerfiles/app2/data
  - www directory

Edit <workbench_full_path>/dockerfiles/app1/data/www/index.html file with a text editor , make some changes in content, and save the file. File synch can take a few seconds. Open a web browser, and go to: 'http://<local_domain_name_1>' .

Refresh the page: <kbd>SHIFT</kbd>+<kbd>F5</kbd> function key.
If same page comes, wait for a few seconds and hit <kbd>SHIFT</kbd>+<kbd>F5</kbd> key again. We can see the change at this point.

Development environment installation finished.

### How to stop Vagrant VM

**Stop rsync-auto**
Select the terminal running rsync-auto
CTRL+C on the terminal to stop vagrant rsync-auto

**Stop Vagrant VM**
```bash
cd <workbench_full_path>/vagrant
vagrant halt
```

Now, you can continue to [Production Environment installation](install_prod.md).

[Back to README](../README.md)

-----

### References:
- Install Ubuntu on a VPS server
  - https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-22-04

- Ansible:
  - https://github.com/ansible/ansible/tree/v2.14.0
  - https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
  - https://www.ansible.com/overview/how-ansible-works
  - https://galaxy.ansible.com/geerlingguy/pip
  - https://www.digitalocean.com/community/tutorials/how-to-use-ansible-to-install-and-set-up-docker-on-ubuntu-22-04

- Vagrant
  - https://www.vagrantup.com/downloads
  - https://ostechnix.com/install-and-configure-kvm-in-ubuntu-20-04-headless-server/
  - https://www.qemu.org/
  - https://virt-manager.org/

- Git
  - https://github.com/git-guides/install-git

- Traefik
  - https://doc.traefik.io/traefik/https/acme/