# node_exporter role

This role will run [node exporter](https://github.com/prometheus/node_exporter) in a docker container to collect host system metrics.

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
    - role: chainsafe.general.node_exporter
```