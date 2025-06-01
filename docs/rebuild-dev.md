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

Back to [Development Environment](install-dev-2404.md#rebuild-the-project)
