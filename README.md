# Dswebdocs Workbench

Dswebdocs Workbench builds a development environment similar to a production server. A Vagrant VM creates a local development environment that mimics the production VPS(Virtual Private Server). Docker containers isolate running services inside VM/VPS. Ansible automates installation/management tasks.


Developed on Pop!_OS, so these instructions will work on Ubuntu 22.04, and Pop!_OS 22.04 without problem(hopefully). Not tested on other systems at the moment.


The process is not fully automated, will automate more as I learn.
May not be suitable to production use, it is in a really early stage. 


Dswebdocs Workbench creates two static sites with nginx. When files on controller pc changes, files on the container also changes. (On development environment only.)


I am open to suggestions. You can reach me via rgucluer@gmail.com .

-----

## Installation:
  - [Development Environment](docs/install_dev.md)
  - [Production Environment](docs/install_prod.md)

-----

### LICENSE

Copyright 2023 Recep GÜÇLÜER rgucluer@gmail.com

Dswebdocs Workbench is [MIT licensed](LICENSE) .

-----
