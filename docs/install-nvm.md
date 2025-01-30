## Install nvm and node with ansible on Controller PC

### Install nvm 

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

Close all open terminals. Open a new terminal
```bash
command -v nvm
```
If the result is "nvm" then nvm installation is complete.

### Install Node

```cmd
nvm install 21
```

```cmd
nvm alias default v21
```

```cmd
node -v
v21.7.3
```

```cmd
nvm which 21
/home/local1/.nvm/versions/node/v21.7.3/bin/node
```

[Back to Installation of Development Environment](install-dev-2404.md#add-a-gatsby-blog-to-the-dswebdocs-workbench)


-----
References:
- Node Version Manager: https://github.com/nvm-sh/nvm
