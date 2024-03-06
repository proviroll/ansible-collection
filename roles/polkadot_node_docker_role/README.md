# Run a Polkadot node
This role is to spin up a Polkadot node as a docker container. 
You can pass different flags to get the desired outcome e.g full node, archive node, validator node and light node. 


## Dependecies
Docker needs to be installed

## How to use the role from the collection?
- Install the collection
- Call the role from the collection in the playbook as below.

```yaml
---
- hosts: all
  name: Deploy and start polkadot
  become: true
  roles:
    - role: chainsafe.general.polkadot_node_docker_role
```

## Link to [default values](./defaults/main.yml)
