# Ansible Role: Bootstrap Groups and Users

This role is responsible for managing users and groups on a system. It performs the following tasks:

1. **Switch to Root User:** The role starts by switching to the `root` user to ensure it has the necessary permissions to perform its tasks.

2. **Change GID and UID:** The role logs out the current user and changes their GID and UID to `62000` (this ID is chosen to make sure it won't be taken by a different user).

3. **Create Application User and Group:** The role creates an `application_user` group and user with a GID and UID of `1000` (the same value as the main application container).

4. **Create Additional Users:** The role creates additional users specified in the `bootstrap_user` and `backup_user` variables. These users are added to the `application_user` group and the `sudo` group. The role also adds SSH keys for these users and configures sudo access.

5. **Remove Old SSH Keys:** The role removes SSH keys from the `bootstrap_user` and `backup_user` that are no longer authorized.

6. **Set Hostname:** The role sets the hostname of the target machine to match the `inventory_hostname`.

7. **Update /etc/hosts:** The role adds an entry to the `/etc/hosts` file for the `inventory_hostname`.

8. **Setup Firewall Rules:** If the `setup_firewall` variable is set to `true`, the role includes the `geerlingguy.firewall` role to set up firewall rules.

9. **Update SSH Configuration:** The role updates the SSH configuration to disable root login and password authentication.

10. **Delete Initial User:** Finally, the role deletes the initial user if it's not the `bootstrap_user`.

## Requirements

- Ansible 2.9 or higher
- Root access on the target host

## Role Variables

- `ansible_user`: The current user.
- `application_user`: The name of the application user and group to create.
- `bootstrap_user`: The name of the main user to create.
- `backup_user`: The name of the backup user to create.
- `github_user_pubkeys`: The GitHub usernames to fetch public keys from.
- `old_github_user_pubkeys`: The old GitHub usernames whose public keys should be removed.
- `setup_firewall`: A boolean that determines whether to set up firewall rules.

## Dependencies

- `geerlingguy.firewall`: This role is used to set up firewall rules if `setup_firewall` is `true`.
