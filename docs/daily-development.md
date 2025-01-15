# Dswebdocs Workbench daily usage as development environment

We use the Controller PC to execute the following operations.

## Add ssh key to ssh agent
```bash
ssh-add ~/.ssh/vmuserkey
```

## Switch to development mode

### Edit /etc/hosts file. 
Enter IP address of Virtual Machine for your development domains

/etc/hosts
```bash
<virtual_machine_IP> <domain_name_1>
<virtual_machine_IP> demo1.<domain_name_1>
<virtual_machine_IP> whoami.<domain_name_1>
<virtual_machine_IP> traefik.<domain_name_1>

# If you installed a Gatsby blog
<virtual_machine_IP> <domain_name_3>
```

### Edit dockerfiles/.env file

Uncomment development row, comment out production row.
```ini
COMPOSE_PROJECT_NAME="myproject"
COMPOSE_FILE="compose.yml"
COMPOSE_PROFILES="development"
# COMPOSE_PROFILES="production"
```

## Run Multipass
```bash
multipass start <vm_instance_name>
```

### Change content
Modify one of the files below:
  - dockerfiles/app1/data/www/index.html
  - dockerfiles/app2/data/www/index.html

After modification, wait a few seconds. 

Check, update the page (Shift + F5):
https://<domain_name_1>

For a Gatsby blog:
- Run gatsby develop
```bash
cd <workbench_directory>/dockerfiles/gatsby
```
```bash
gatsby develop
```
- Change content of dockerfiles/gatsby/content/blog/my-second-post/index.md

- After modification, wait a few seconds. 
- Check http://localhost:8000/my-second-post/
- Stop gatsby develop with pressing CTRL+C

```bash
gatsby build
```
This build step updates content we see over domain name.


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
- https://<domain_name_3>
- https://traefik.<domain_name_1>:8082/ping/
- https://traefik.<domain_name_1>:8080/dashboard/
- https://whoami.<domain_name_1>

## End of the day
### Stop Virtual Machine
```bash
multipass stop <vm_instance_name>
```

-----

If you want deploy changes to production, read [Dswebdocs Workbench daily usage as production environment](docs/daily-production.md).