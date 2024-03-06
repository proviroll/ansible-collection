# Loki role

This role will run a loki server in a docker container.

## Dependencies
Docker needs to be installed on the host system to use this role.

## Role Variables

Default variables are defined in [defaults/main.yaml](defaults/main.yaml)

## Example Playbook

With a target group of hosts called `all` , your playbook could look like this:

```yaml
- hosts: all
  become: true
  roles:
    - role: chainsafe.general.loki
```
