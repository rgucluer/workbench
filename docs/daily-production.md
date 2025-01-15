# Dswebdocs Workbench daily usage as production environment

### Variables: 
Defined in installation of [Production Environment](install-prod-2404.md)


## Add ssh keys to ssh agent

```bash
ssh-add ~/.ssh/<prod_ssh_key>
ssh-add ~/.ssh/<github_ssh_key>
```

## Switch to production mode

### Edit /etc/hosts file. 
Comment out domain names in /etc/hosts file

```bash
# <virtual_machine_IP> <domain_name_1>
# <virtual_machine_IP> demo1.<domain_name_1>
# <virtual_machine_IP> whoami.<domain_name_1>
# <virtual_machine_IP> traefik.<domain_name_1>

# If you installed a Gatsby blog
#<virtual_machine_IP> <domain_name_3>
```

### Edit dockerfiles/.env file

Uncomment production row, comment out development row.
```ini
COMPOSE_PROJECT_NAME="myproject"
COMPOSE_FILE="compose.yml"
# COMPOSE_PROFILES="development"
COMPOSE_PROFILES="production"
```

### If Gatsby Blog is installed

Run gatsby build
```bash
cd <workbench_directory>/dockerfiles/gatsby
```
```bash
gatsby build
```

## Rebuild the Dswebdocs Workbench:

*** Warning: Backup first ***
*** Warning: All DATA on production server will be deleted. This step will stop all the containers, and delete all the volumes of those containers. You will lose all the state saved in those volumes. ***

Open a new terminal

```bash
cd <workbench_full_path>/ansible
ansible-playbook prod-rebuild.yml
```

Enter BECOME password for <server_user>.

Check
- https://<domain_name_1>
- https://<domain_name_2>
- https://<domain_name_3>
- https://traefik.<domain_name_1>:8082/ping/
- https://traefik.<domain_name_1>:8080/dashboard/
