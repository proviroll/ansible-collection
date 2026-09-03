# Run a Polkadot node
This role is to spin up a `Polkadot` or `kusama`  full node as a docker container. It also includes the functionality to create daily snapshots of the Polkadot node and upload them to a specified S3 bucket. 
You can pass different `vars` to get the desired outcome e.g `network: kusama`.

## Dependencies
Docker needs to be installed on the host system to use this role.

## How to use the role from the collection?
- Install the collection
- Call the role from the collection in the playbook as below.

```yaml
---
- hosts: 
  name: Depoly Polkadot full node and generate and upload snapshots
  become: true
  roles:
    - role: proviroll.ansible_collection.polkadot_snapshot
  vars:
    aws_access_key: AKIXXXXXXXXXX
    aws_secret_key: Wexxxxxxxxxxxxxxxxxxxx
    network: kusama
    slack_webhook_url: https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXXXXXXXXXX
    polkadot_snapshot_link: 

```

## Link to [default values](./defaults/main.yml)
