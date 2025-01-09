# Installation of development environment:

## Requirements:
- Operating System: Ubuntu 24.04 .
- Virtualization enabled.
- For Letsencrypt HTTPS support
  - A valid registered domain name.
- A text editor, or similar application.
  - Some best practices for editing YAML files:
    - Indentation with spaces, tabs are forbidden.
    - Recommended number of spaces for a tab: 2
  
### Variables:
When you see these variables through the document , enter the values valid for your setup.

- Controller PC: Physical PC (Multipass Host, Ansible Controller, Developer PC).
  - local_user: local1
    - The user of your Controller PC. 
  - local_workspace: workspace
    - The directory to store software source code.
  - local_project_dir: workbench
    - This directory holds dswebdocs workbench project
  - workbench_directory: 
    - /home/<local_user>/<local_workspace>/<local_project_dir>
    - /home/local1/workspace/workbench
    - Variable holds the full path to dswebdocs workbench project.

- Virtual Machine (VM): The virtual machine created by Canonical Multipass in Controller PC.
  - vm_user: vmuser
    - Virtual machine user name with sudo privileges .
  - vm_ssh_key: vmuserkey
    - Virtual Machine ssh key
  - vm_instance_name: dwvm
  - vm_hostname: devserver1
  - virtual_machine_IP:
    - Canonical Multipass sets an IP address on the first run of the VM. 

- domain_name_1: myserver.com
- domain_name_2: demo1.myserver.com
- domain_name_3: blog.myserver.com
- Domain names controlled by you. Defined in your /etc/hosts . 

- compose_project_name: myproject
- my_dns_provider: hetzner
- my_dns_provider_dns_server_1_IP: 213.133.100.98
- my_dns_provider_dns_server_2_IP: 88.198.229.192


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

Open a terminal. You need to copy from the codeboxes below, paste into the terminal, and execute with pressing ENTER. Maybe it will be even better if the reader knows about basic GNU/Linux OS usage.

## Update apt packages
We start with updating the Controller PC apt packages.
```bash
sudo apt update
```
```bash
sudo apt upgrade
```
Restart the computer if needed.

## Install Ansible 

Following steps as explained in https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu

Distribution name for Ubuntu 24.04 is noble (https://launchpad.net/ubuntu/+ppas)

To mitigate a problem we must enter sudo password once:
```bash
sudo ls
```
Now, we can continue:
```bash
wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
```
If it seems to hold with a blinking cursor:
  - Resize the terminal window it reveals a message "Overwrite? (y/N)"
    - Enter "y" and press [ENTER].

```bash
echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu noble main" | sudo tee /etc/apt/sources.list.d/ansible.list
```
```bash
sudo apt install ansible -y
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
```
```bash
git clone  https://github.com/dswebdocs/workbench.git
```
## Create a ssh key pair for workbench

```bash
cd ~/.ssh
```
```bash
ssh-keygen -C vmuser -f vmuserkey
```
It will ask for a passphraze, you can enter one, or skip it by pressing <kbd>ENTER</kbd> . ( You will need this passphraze later, keep it safe. )

Make key pair readable/writable only by the user: 
```bash
chmod u=wr-,g=---,o=--- ~/.ssh/vmuserkey*
```
Don't forget the "*" at the end.

Add ssh key to ssh agent:
```bash
ssh-add ~/.ssh/vmuserkey
```

## [Install Canonical Multipass](install-multipass.md)
[Install Canonical Multipass](install-multipass.md) to manage VMs.

## [Docker Compose Settings](docker-compose.md)
Edit [Docker Compose Settings](docker-compose.md) to fit our setup.

## Edit /etc/hosts file
Add the following rows to the /etc/hosts file with a text editor. You must run the text editor with sudo privileges. virtual_machine_IP is the IP we noted before (multipass list).
```bash
sudo nano /etc/hosts
```
Add the following rows to the file.
```txt
<virtual_machine_IP> <domain_name_1>
<virtual_machine_IP> demo1.<domain_name_1>
<virtual_machine_IP> whoami.<domain_name_1>
<virtual_machine_IP> traefik.<domain_name_1>
```
<kbd>CTRL</kbd> + <kbd>o</kbd> to Save.

<kbd>CTRL</kbd> + <kbd>x</kbd> to Exit.

Web browser is directed to this virtual machine when we enter http://<local_domain_name_1> to the address bar. We will do it later, not now.


### Test Virtual Machine ssh login 

```bash
ssh vmuser@<virtual_machine_IP>
```

Will ask "Are you sure you want to continue connecting (yes/no/[fingerprint])?" , write  "yes" and press <kbd>ENTER</kbd> .

If you set a passphraze for your ssh key, it may ask for the passphraze.
( It won't ask for a passphraze, if you add your ssh key to ssh-agent beforehand. )

Now, we are in the Virtual Machine. To exit from ssh session, press <kbd>CTRL</kbd>+<kbd>D</kbd>.

Now, we are back in Controller PC .

### Stop Virtual Machine
multipass stop <vm_instance_name>
```bash
multipass stop dwvm
```

## Edit Ansible inventory file 
Enter IP address for virtual machine we noted at previous steps. Check ssh key filename path, and ansible_user.

<workbench_full_path>/ansible/inventory
```yaml
---
prod_servers:
.....
dev_servers:
  hosts:
    development:
      ansible_host: <virtual_machine_IP>
      .....
      ansible_user: vmuser
      .....
      ansible_ssh_private_key_file: "/home/<local_user>/.ssh/vmuserkey"
.....
```

## Install Docker on Virtual Machine

### On Controller PC: 

Run Virtual Machine
```bash
multipass start dwvm
```

Run Ansible playbook
```bash
cd <workbench_full_path>/ansible
```
```bash
ansible-playbook dev-installdocker.yml
```
Will ask "BECOME password" for Virtual Machine user.
We run Ansible commands on Controller PC, which make changes in VM via a ssh connection.

Reboot the VM to enable recently made changes.
```bash
multipass restart dwvm
```

Test docker installation.
Add ssh key to ssh agent:
```bash
ssh-add ~/.ssh/vmuserkey
```
```bash
ssh vmuser@<virtual_machine_IP>
```
```bash
docker run hello-world
```
Press [CTRL] + [d] to end ssh session.

## [Implement HTTPS, and setup Traefik](https-traefik.md)

## [Rebuild the project](rebuild-dev.md) 
After implementing https, and setup Traefik we can [rebuild the project](rebuild-dev.md) .

## Open sites on a web browser
Open a web browser, and visit the following addresses.

http://<domain_name_1>

http://<domain_name_2>

http://traefik.<domain_name_1>:8082/ping

https://traefik.<domain_name_1>:8080/dashboard/
( The last slash is important , do not omit it. )

These pages must run without problem at this point. Let's modify the index.html , and update the sites.

Edit <workbench_full_path>/dockerfiles/app1/data/www/index.html file with a text editor , make some changes in content, and save the file. File synch can take a few seconds. Open a web browser, and go to: 'http://<local_domain_name_1>' .

Refresh the page: <kbd>SHIFT</kbd>+<kbd>F5</kbd> function key.
If same page comes, wait for a few seconds and hit <kbd>SHIFT</kbd>+<kbd>F5</kbd> key again. We can see the change at this point.

Development environment installation finished.

### Stop Virtual Machine

```bash
multipass stop <vm_instance_name>
```

Now, you can continue to [Production Environment installation](install-prod-2404.md).

Or, you can ...

## [Add a Gatsby Blog to the Dswebdocs Workbench](install-gatsby.md)

[Back to README](../README.md)

TODO: 
  - Automate downloading Letsencrypt Certificates from production server to Controller PC. 
  - Automatic status check of Letsencrypt certificates on traefik container.

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

- Multipass
  - https://multipass.run/docs
  - https://www.qemu.org/

- Git
  - https://github.com/git-guides/install-git

- Traefik
  - https://doc.traefik.io/traefik/https/acme/

- Gatsby
  - Documentation https://www.gatsbyjs.com/docs 

