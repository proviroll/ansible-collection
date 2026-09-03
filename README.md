# Proviroll Ansible Collection

Reusable Ansible roles and playbooks for operating blockchain nodes and supporting infrastructure. This repository contains reusable automation only. It does not include production inventories, credentials, private keys, vault files, or environment-specific service configuration.

## Contents

- `roles/` contains independently reusable roles for node software, system configuration, monitoring, and related services.
- `playbooks/` contains example orchestration entry points.
- `tests/` contains redacted example inventory material where available.

The `agave_private_devnet` role deploys an isolated Agave-based Solana development cluster. It can generate its own local validator keys, or receive externally managed keys at run time. No key material is included in this repository.

## Getting started

Clone the repository and install the declared Ansible collections:

```bash
git clone https://github.com/proviroll/ansible-collection.git
cd ansible-collection
ansible-galaxy collection install -r requirements.yml
```

Create an inventory outside this repository, or begin with a redacted example in `tests/`. Supply environment-specific variables through your preferred secret-management system. Do not commit inventory files, vault files, tokens, passwords, or keypairs.

Run a playbook with an explicit inventory:

```bash
ansible-playbook -i /path/to/inventory.ini playbooks/deploy_private_devnet.yml
```

Before applying a role to a real environment, review its defaults, required variables, network exposure, storage requirements, and any upstream software documentation.

## Security

Treat inventories and variable files as deployment configuration. Store secrets in an encrypted secret manager or Ansible Vault outside this repository, restrict file permissions, and rotate any credential that is accidentally committed elsewhere before publishing a fork.

## License

See [LICENSE](LICENSE).
