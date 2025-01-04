## Make changes in Dswebdocs Workbench for Gatsby production environment

Now, we will make changes in Gatsby blog to run it with Dswebdocs Workbench .

### Uncomment and modify gatsby-production service in dockerfiles/compose.yml

#### Production Environment:
```yaml
.....
services:
  .....
  gatsby-production:
    profiles: ["production"]
    build:
      context: "./gatsby"
      dockerfile: Dockerfile
      args:
        virtual_host: "myserver.com"
    .....
    labels:
      traefik.enable: true
      traefik.http.routers.gatsby-https.rule: "Host(`myserver.com`)"
      .....
      traefik.http.routers.gatsby-https.tls.domains[0].main: "myserver.com"
      ......
```

Now, you can continue to [Rebuild the project](rebuild-prod.md).



