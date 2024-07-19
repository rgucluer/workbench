# Dswebdocs Workbench

Dswebdocs Workbench builds a development environment. A Vagrant VM creates a local development environment that mimics the production VPS(Virtual Private Server). Docker containers isolate running services inside VM/VPS. Ansible automates installation/management tasks. After development we can publish to a VPS with Ansible, and Docker.


Developed on Pop!_OS, and Ubuntu 24.04, so these instructions will work on Ubuntu 22.04, Ubuntu 24.04, and Pop!_OS 22.04. Not tested on other systems at the moment. 


The process is not fully automated. May not be suitable to production use.


You can reach me via rgucluer@gmail.com .

-----

## Installation:
  - [Development Environment](docs/install_dev_2404.md)
  - [Production Environment](docs/install_prod2404.md)

## Letsencrypt
- [Manual certificate related operations](docs/lego_certs.md)

-----

### LICENSE

Copyright 2023 Recep GÜÇLÜER rgucluer@gmail.com

Dswebdocs Workbench is [MIT licensed](LICENSE) .

-----
