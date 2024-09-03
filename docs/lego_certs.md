### Installation
We did the Letsencrypt related installation steps while [installing development environment](install_dev.md).

### Copy storage directory from container to Vagrant VM

On Vagrant VM:
```bash
cd ~/dockerfiles/traefik
docker cp traefik-development:/traefik/storage/ ./
```

### Copy storage directory from Vagrant VM to Controller PC

On Controller PC:
```bash
cd <workbench_directory>/dockerfiles/traefik
rsync -avz vagrant@<vagrant_vm_IP>:dockerfiles/traefik/storage/ ./
```

### Change file permissions
On Controller PC:
```bash
cd <workbench_directory>/dockerfiles/traefik/storage
chmod 600 acme.json
```

### Copy storage directory from container to VPS 

On VPS:
```bash
cd ~/dockerfiles/traefik
docker cp traefik-production:/traefik/storage/ ./
```

### Copy storage directory from VPS to Controller PC

On Controller PC:
```bash
cd <workbench_directory>/dockerfiles/traefik
rsync -avz -e 'ssh -p <server_ssh_port>' <server_user>@<server_ip>:dockerfiles/traefik/storage ./
```

