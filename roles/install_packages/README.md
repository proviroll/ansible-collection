# Ansible Role: Install Common Packages and Docker

This role is responsible for managing common packages, Docker, and Docker Compose on a system. It performs the following tasks:

1. **Update and Upgrade All Packages:** If the `upgrade_all_packages` variable is set to `true`, the role updates and upgrades all available packages.

2. **Install Common Apt Packages:** The role installs common apt packages such as `git`, `nano`, `htop`, `gnupg`, `python3`, `apache2-utils`, `rclone`, `aria2`, `jq`, and `python3-pip`.

3. **Install Common Pip Packages:** The role installs common pip packages such as `toml-cli`.

4. **Install Docker:** The role includes the `geerlingguy.docker` role to install Docker.

5. **Install Docker Python Wrapper:** The role installs the `python3-docker` package.

6. **Add Ansible User to Docker Group:** The role adds the `bootstrap_user` to the `docker` group.

7. **Restart Docker Service:** The role restarts the Docker service.

8. **Schedule Daily Prune of Docker:** If the `docker_daily_prune` variable is set to `true`, the role sets up a daily cron job to prune Docker.

9. **Install Docker Compose:** The role installs Docker Compose using the `docker_compose_version` variable to specify the version.

## Requirements

- Ansible 2.9 or higher
- Root access on the target host

## Role Variables

- `upgrade_all_packages`: A boolean that determines whether to update and upgrade all available packages.
- `bootstrap_user`: The user to add to the `docker` group.
- `docker_daily_prune`: A boolean that determines whether to set up a daily cron job to prune Docker.
- `docker_compose_version`: The version of Docker Compose to install.

## Dependencies

- `geerlingguy.docker`: This role is used to install Docker.
