# Installation
We did the Letsencrypt related installation steps while [installing development environment](install_dev.md).

We use Multipass, which sync the files in background. If you don't use multipass you can use the following commands to sync files:

## Copy lego storage directory from Virtual Machine to Controller PC

### Copy lego storage directory from container to Virtual Machine

On Virtual Machine:
```bash
cd ~/dockerfiles/traefik
docker cp traefik-development:/traefik/storage/ ./
```

### Copy lego storage directory from Virtual Machine to Controller PC

On Controller PC:
```bash
cd <workbench_directory>/dockerfiles/traefik
rsync -avz vmuser@<virtual_machine_IP>:dockerfiles/traefik/storage/ ./
```

### Change file permissions
On Controller PC:
```bash
cd <workbench_directory>/dockerfiles/traefik/storage
chmod 600 acme.json
```

## Copy lego storage directory from Virtual Private Server to Controller PC

### Copy lego storage directory from container to Virtual Private Server (VPS)

On VPS:
```bash
cd ~/dockerfiles/traefik
docker cp traefik-production:/traefik/storage/ ./
```

### Copy lego storage directory from VPS to Controller PC

On Controller PC:
```bash
cd <workbench_directory>/dockerfiles/traefik
rsync -avz -e 'ssh -p <server_ssh_port>' <server_user>@<server_ip>:dockerfiles/traefik/storage ./
```

