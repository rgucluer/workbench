## Docker Compose Settings

Development and production environments differ in storage settings. Development environment uses Docker bind mounts. Bind mounts enable transfer of file changes to the related Docker container. In production this is not needed, also include security risks. 

Docker Compose Profiles seperate development and production environments in compose.yml.

### Check the current environment

Check the current environment in <workbench_directory>/dockerfiles/.env file. Uncomment development row, comment out production row.
```ini
COMPOSE_PROFILES="development"
# COMPOSE_PROFILES="production"
```

### Enter your domain address in compose.yml
<workbench_directory>/dockerfiles/compose.yml
```yaml
services:
  .....
  reverse-proxy-development:
    profiles: ["development"]
    build:
    .....
      args:
        virtual_host: "myserver.com"
  .....
  whoami-development:  
  .....
    labels:
      traefik.enable: true
      traefik.http.routers.whoami-https.rule: "Host(`whoami.myserver.com`)"
      .....
      traefik.http.routers.whoami-https.tls.domains[0].main: "whoami.myserver.com"
  .....
  app1-development:
    profiles: ["development"]
    build:
    .....
      args:
        virtual_host: "myserver.com"
    .....
    labels:
      .....
      traefik.http.routers.app1-https.rule: "Host(`myserver.com`)"
      .....
      traefik.http.routers.app1-https.tls.domains[0].main: "myserver.com"
```

### Enter a second domain address in compose.yml
<workbench_directory>/dockerfiles/compose.yml
```yaml
services:
  .....

  app2-development:
    profiles: ["development"]
    build:
      .....
      args:
        virtual_host: "demo1.myserver.com"
  .....
  labels:
    .....
    traefik.http.routers.app2-https.rule: "Host(`demo1.myserver.com`)"
    .....
    traefik.http.routers.app2-https.tls.domains[0].main: "demo1.myserver.com"
```

Back to [Development Environment installation ](install-dev-2404.md#docker-compose-settings)
