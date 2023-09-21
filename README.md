# Dswebdocs Workbench

Dswebdocs builds a development environment similar to a production server. A Vagrant VM creates a local development environment that mimics the production VPS(Virtual Private Server). Docker containers isolate running services inside VM/VPS. Ansible automates installation/management tasks.


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

Copyright 2023 Recep GÜÇLÜER (rgucluer@gmail.com)


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at


> [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)


Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

-----
