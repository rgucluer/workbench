## Implement HTTPS, and setup Traefik


Comment out domain names in /etc/hosts
```txt
#<vagrant_vm_IP> <domain_name_1>
#<vagrant_vm_IP> demo1.<domain_name_1>
#<vagrant_vm_IP> whoami.<domain_name_1>
#<vagrant_vm_IP> traefik.<domain_name_1>
```

Before applying the following steps, setup  your DNS settings for your domain in your service provider DNS Control panel.
Check with
```bash
$ nslookup <domain_name_1>
```
If it returns
```bash
$ ** server can't find <domain_name_1>: NXDOMAIN
```
than your DNS settings maybe wrong or not propogated yet. Continue after you get a positive result.

If you don't have a lego storage backup, then continue with step "Obtain your API Key ..." .

### If you have a lego backup, restore it:
Copy **storage** directory from backup to dockerfiles/traefik .


### Obtain your API Key from your Service Provider
- Read your Cloud provider's document and get your DNS API KEY
  - https://doc.traefik.io/traefik/https/acme/#providers

Many lego environment variables can be overridden by their respective _FILE counterpart, which should have a filepath to a file that contains the secret as its value. 

- Save the API key to a file. ( dockerfiles/traefik/storage/my_dns_provider_api_key.txt )

### Generate Letsencrypt certificates with Lego
I use Hetzner at this moment, so I do the following to get the certificates. Follow a similar method for your service provider. Follow your service provider's documentation for parameters.

```bash
cd <workbench_full_path>/dockerfiles/traefik/storage
```
Copy the following to a text editor. Change values to match your setup. Copy all text and paste into the terminal above.

```bash
HETZNER_API_KEY_FILE="my_dns_provider_api_key.txt" \
lego --email "my_email@myserver.com"  \
--server=https://acme-v02.api.letsencrypt.org/directory \
--dns <my_dns_provider> \
--accept-tos \
--dns.resolvers "<my_dns_provider_dns_server_1>" \
--dns.resolvers "<my_dns_provider_dns_server_2>" \
--dns.resolvers "8.8.8.8:53" \
--dns-timeout 60 \
--domains "*.myserver.com" \
--domains "myserver.com" \
run
```
Terminal output:
```bash
Saved key to <workbench_full_path>/dockerfiles/traefik/storage/.lego/accounts/acme-v02.api.letsencrypt.org/my_email@myserver.com/keys/my_email@myserver.com.key

2024/02/22 16:36:05 Please review the TOS at https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf
Do you accept the TOS? Y/n
```

Y [ENTER]

```bash
2024/02/22 16:37:03 [INFO] acme: Registering account for my_email@myserver.com

Your account credentials have been saved in your Let's Encrypt configuration directory at "<workbench_full_path>/dockerfiles/traefik/storage/.lego/accounts".

You should make a secure backup of this folder now. This
configuration directory will also contain certificates and
private keys obtained from Let's Encrypt so making regular
backups of this folder is ideal.
```

The certificate files must persist between docker sessions, rsync must not delete certificate files.

Lego can automaticaly updates certificates. But it will save the latest certificates to docker container storage. If these certificates are saved to development directory, we can prevent unnecassary certification renewals.
You can read about how to copy lego storage directory in [this link](lego-certs.md).

Also storage directory will contain private files, make sure you DO NOT commit them to any git like version control service.

Uncomment domain names in /etc/hosts
```txt
<vagrant_vm_IP> <domain_name_1>
<vagrant_vm_IP> demo1.<domain_name_1>
<vagrant_vm_IP> whoami.<domain_name_1>
<vagrant_vm_IP> traefik.<domain_name_1>
```

### Set related values in dockerfiles/compose.yml for traefik

```yaml

services:
  reverse-proxy-development:
    profiles: ["development"]
    .....

    # Add your DNS Auth. API keys here.
    environment:
      - "SERVICE_PROVIDER_API_KEY_FILE=/etc/environment/my_dns_provider_api_key.txt"

```

### Set related values in dockerfiles/traefik/traefik.yml

Related values: 
  - Change "myserver.com" with your domain name.
  - Change "my_dns_provider" with your dns provider. Read https://go-acme.github.io/lego/dns/ .
  - Change "my_email@myserver.com" with your email registered for Letsencrypt .
  - Enter <my_dns_provider_dns_server_1_IP>
  - Enter <my_dns_provider_dns_server_2_IP>

```yaml
providers:
  docker:
    .....

    defaultRule: Host(`traefik.myserver.com:8080`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))
    .....

certificatesResolvers:
  myresolver:
    acme:
      # caServer: https://acme-staging-v02.api.letsencrypt.org/directory
      caServer: "https://acme-v02.api.letsencrypt.org/directory"
      email: "my_email@myserver.com"
      storage: "/traefik/storage/acme.json"
      .....
      
      dnsChallenge:
        # DNS Providers LEGO CLI flag name
        # Detailed information : https://go-acme.github.io/lego/dns/
        # Please read the link above, find your provider in the list.
        # Enter your provider CLI flag name below.
        provider: "my_dns_provider"
        delayBeforeCheck: "60"

        # Use following DNS servers to resolve the FQDN authority.
        resolvers:
        - "<my_dns_provider_dns_server_1_IP>:53"
        - "<my_dns_provider_dns_server_2_IP>:53"
        - "1.1.1.1:53"
        - "8.8.8.8:53"
        disablePropagationCheck: false
```

### Set related values in traefik/dynamic.yml

Related values: 
  - Change "myserver.com" with your domain name.
  - certificates: Enter certFile, and keyFile paths for your domain setup.

```yaml
http:
  routers:
  .....

    reverse-proxy-https:
      rule: Host(`traefik.myserver.com`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))
      entryPoints: 
        - "traefik"
      service: "api@internal"
      tls:
        certResolver: myresolver
        domains:
          - main: "myserver.com"

    ping-https:
      rule: Host(`traefik.myserver.com`) && PathPrefix(`/ping`)
      entryPoints: 
        - "ping"
      service: "ping@internal"
      tls:
        certResolver: myresolver
        domains:
          - main: "myserver.com"

tls:
  .....

  certificates:
    - certFile: /traefik/storage/.lego/certificates/_.myserver.com.crt
      keyFile: /traefik/storage/.lego/certificates/_.myserver.com.key
  .....

```



### Add authentication to Traefik Dashboard

Add an encrypted credential to dockerfiles/traefik/users.txt file

```bash
cd <workbench_directory>/dockerfiles/traefik
```
```bash
printf "<user_name>:$(openssl passwd -apr1 <enter_password>)\n" >> users.txt
```
Enter the user_name, and password as you wish ( without < > angle brackets ).

We entered password openly, so let's clear terminal history. (Password will be encrypted in users.txt). 
Clear terminal history:
```bash
clear
```
```bash
history -c
```
```bash
history -w
```

Check users.txt mapping in dockerfiles/compose.yml

```yaml
services:
  reverse-proxy-development:
    .....
    volumes:
    .....
    # User Credentials
    - "./traefik/users.txt:/etc/traefik/users.txt"
```

Define auth middleware in dockerfiles/traefik/dynamic.yml

```yaml
  middlewares:
    auth:
      basicAuth:
        usersFile: "/etc/traefik/users.txt"
```

Enable auth middleware in dockerfiles/traefik/traefik.yml for traefik entrypoint

```yaml
..... 
entryPoints:
  .....
  traefik:
    address: ":8080"
    http:
      redirections:
      .....

      middlewares:
        - "auth@file"
```

Enable auth middleware for whoami-development service in dockerfiles/compose.yml
```yaml
.....
services:
  whoami-development:
.....
    labels:
    .....
      traefik.http.routers.whoami-https.middlewares: "auth@file"

```


Back to [Development Environment](install-dev-2404.md)

