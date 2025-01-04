## Rebuild the project - Development Environment

### On Controller PC:

```bash
multipass start dwvm
```

```bash
cd <workbench_directory>/ansible
```
```bash
ansible-playbook dev-rebuild.yml
```
Will ask "BECOME password" for Virtual Machine user.
