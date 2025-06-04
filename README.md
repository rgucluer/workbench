# Dswebdocs Workbench

Dswebdocs Workbench builds a development environment. Canonical Multipass creates a virtual machine as a local development environment that mimics the production VPS(Virtual Private Server). Docker containers isolate running services inside VM/VPS. Ansible automates installation/management tasks. After development we can publish to a VPS with Ansible, and Docker.

Developed on Ubuntu 24.04, so these instructions will work on  Ubuntu 24.04. Not tested on other systems at the moment. 


May not be suitable for production use.

-----

## Installation:
- [Development Environment](docs/install-dev-2404.md)
- [Production Environment](docs/install-prod-2404.md)

## Daily Usage
- [Dswebdocs Workbench daily usage as development environment](docs/daily-development.md)
- [Dswebdocs Workbench daily usage as production environment](docs/daily-production.md)

-----

## Other operations:
- Letsencrypt: [Certificate related operations](docs/lego-certs.md)

-----

## LICENSE

Copyright 2023-2025 Recep GÜÇLÜER rgucluer@gmail.com

Dswebdocs Workbench is [MIT licensed](LICENSE) .

-----
