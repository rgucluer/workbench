## Implement HTTPS, and setup Traefik for production environment

We created the Letsencrypt certificates while installing development environment.

### Set related values in dockerfiles/compose.yml for traefik

```yaml

services:
  reverse-proxy-production:
    profiles: ["production"]
    .....

    # Add your DNS Auth. API keys here.
    environment:
      - "SERVICE_PROVIDER_API_KEY_FILE=/etc/environment/my_dns_provider_api_key.txt"

```

### Add authentication to Traefik Dashboard

We created the users.txt before, we can use it. users.txt is copied to Docker image during image building process. (TODO: Implement a more secure way to use passwords.)


Back to [Production Environment installation](install-prod-2404.md#implement-https-and-setup-traefik)

