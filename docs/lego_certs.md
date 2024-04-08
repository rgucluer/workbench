### Installation
We did the Letsencrypt related installation steps while [installing development environment](docs/install_dev.md).

### Copy storage directory from Vagrant VM to Controller PC

On Controller PC:
```bash
cd <workbench_directory>/dockerfiles/traefik
rsync -a vagrant@<vagrant_vm_IP>:/home/vagrant/dockerfiles/traefik/storage/ ./storage
```

### Copy storage directory from container to VPS

On VPS:
```bash
cd ~/dockerfiles/traefik
docker cp traefik-production:/traefik/storage/ ./storage
```

### Copy storage directory from VPS to Controller PC

On Controller PC:
```bash
cd <workbench_directory>/dockerfiles/traefik
rsync -avz <server_user>@<server_ip>:dockerfiles/traefik/storage/ ./storage
```

