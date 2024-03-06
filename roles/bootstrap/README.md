# Bootstrap a new machine
This role is to initialize a new machine. At high level it will execute below actions:
- setup `devops` and `loginbackup` users and groups
- Add public SSH keys from Github endpoint to those users
- Removes public SSH keys of old users
- Disable root and password based SSH login
- set the hostname same as inventory name of the machine

## Dependecies
no


## How to use the role from the collection?
- Install the collection
- Call the role from the collection in the playbook as below.

```yaml
---
- hosts: all
  gather_facts: false
  name: Bootstrap machine
  become: true
  roles:
    - role: chainsafe.general.bootstrap
```

### Adding and removing SSH key of a user to/from a machine
Ensure that user added the public key to his/her GH account. (check https://github.com/user1.keys)

To add the SSH key, add the username to the below variable.

```yaml
github_user_pubkeys:
  - user1 
```

To remove the SSH key, add the username to the below variable.

```yaml
old_github_user_pubkeys:
  - old-user1
```


## Link to [default values](./defaults/main.yml)
