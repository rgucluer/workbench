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
nvm install 20
```

```cmd
nvm use v20
nvm alias default v20
```

```cmd
node -v
v20.17.0
```

```cmd
nvm which v20
/home/local1/.nvm/versions/node/v20.17.0/bin/node
```

-----
References:
- Node Version Manager: https://github.com/nvm-sh/nvm
