## Docker Compose Settings

Development and production environments differ in storage settings. Development environment uses Docker bind mounts. Bind mounts enable transfer of file changes to the related Docker container. In production this is not needed, also include security risks.

Docker Compose Profiles seperate development and production environments in compose.yml.

### On Controller PC: Check the current environment

Check the current environment in <workbench_directory>/dockerfiles/.env file. Uncomment production row, comment out development row.
```ini
# COMPOSE_PROFILES="development"
COMPOSE_PROFILES="production"
```

### On Controller PC: Enter your domain address in compose.yml
<workbench_directory>/dockerfiles/compose.yml
```yaml
services:
  .....
  reverse-proxy-production:
    profiles: ["production"]
    build:
    ....
      args:
        virtual_host: "myserver.com"

  app1-production:
    profiles: ["production"]
    build:
    ....
      args:
        virtual_host: "myserver.com"
  labels:
    .....
    traefik.http.routers.app1-https.rule: "Host(`myserver.com`)"
    .....
    traefik.http.routers.app1-https.tls.domains[0].main: "myserver.com"
```


**Enter a second domain address in compose.yml**
<workbench_directory>/dockerfiles/compose.yml
```yaml
services:
  ...

  app2-production:
    profiles: ["production"]
    build:
      ...
      args:
        virtual_host: "demo1.myserver.com"
  ...
  labels:
    ...
    traefik.http.routers.app2-https.rule: "Host(`demo1.myserver.com`)"
    ...
    traefik.http.routers.app2-https.tls.domains[0].main: "demo1.myserver.com"
```

### On Controller PC: Uncomment and enter domain address in compose.yml
If Gatsby blog is installed then uncomment the related section in compose.yml and enter domain address .
<workbench_directory>/dockerfiles/compose.yml
```yaml
  gatsby-production:
    profiles: ["production"]
    build:
      .....
      args:
        virtual_host: "blog.myserver.com"
  .....
  labels:
    .....
    traefik.http.routers.gatsby-https.rule: "Host(`blog.myserver.com`)"
    .....
    traefik.http.routers.gatsby-https.tls.domains[0].main: "blog.myserver.com"
    .....
```

Back to [Install Production Environment](install-prod-2404.md#docker-compose-settings)