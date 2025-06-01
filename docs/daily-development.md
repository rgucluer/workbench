# Dswebdocs Workbench daily usage as development environment

We use the Controller PC to execute the following operations.

## Add ssh key to ssh agent
```bash
ssh-add ~/.ssh/vmuserkey
```

## Switch to development mode

## Run Multipass
```bash
multipass start <vm_instance_name>
```

## List Virtual Machine
```bash
multipass list
```
Note the IP of the Virtual Machine.


### Edit /etc/hosts file. 
Enter IP address of Virtual Machine for your development domains

/etc/hosts
```bash
<virtual_machine_IP> traefik.<domain_name_1>
<virtual_machine_IP> whoami.<domain_name_1>
<virtual_machine_IP> demo1.<domain_name_1>
<virtual_machine_IP> <domain_name_1>
```

### Edit dockerfiles/.env file

Uncomment development row, comment out production row.
```
COMPOSE_PROJECT_NAME="myproject"
COMPOSE_FILE="compose.yml"
COMPOSE_PROFILES="development"
# COMPOSE_PROFILES="production"
```

### Change content
Modify one of the files below:
  - dockerfiles/app1/data/www/index.html
  - dockerfiles/app2/data/www/index.html

After modification, wait a few seconds. 

Check, update the page (Shift + F5):
https://<domain_name_1>

## You can rebuild the Dswebdocs Workbench:

```bash
cd <workbench_full_path>/ansible
```
```bash
ansible-playbook dev-rebuild.yml
```

BECOME password is for virtual machine user vmuser.

Check
- https://<domain_name_1>
- https://<domain_name_2>
- https://traefik.<domain_name_1>:8082/ping/
- https://traefik.<domain_name_1>:8080/dashboard/
- https://whoami.<domain_name_1>

( Press [Shift]+[F5] if necessary )

## End of the day
### Stop Virtual Machine
```bash
multipass stop <vm_instance_name>
```

-----

If you want deploy changes to production, read [Dswebdocs Workbench daily usage as production environment](daily-production.md).
