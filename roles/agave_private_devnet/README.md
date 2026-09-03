# Agave Private Devnet

`agave_private_devnet` deploys a small, isolated Solana development cluster using the Agave validator client. It configures the host, installs the required binaries, creates genesis on the bootstrap node, starts validator services, and can start a bounded faucet service.

This role is for development and testing environments. It is not a replacement for the production operational guidance published by Agave.

## What the role manages

- A dedicated operating-system user and data directories.
- Validator binaries and host-level tuning.
- Bootstrap and follower node configuration.
- Genesis creation on the bootstrap node.
- Validator identity, vote, stake, and faucet keypair files.
- An optional faucet service on the bootstrap node.

When no key values are provided, the role generates development keypairs on each target. Generated keys stay on the target hosts and are never stored in this repository. To reuse existing keys, provide their contents through your own encrypted secret-management system at run time.

## Prerequisites

- Ubuntu 24.04 target nodes.
- SSH access and sudo privileges for the Ansible user.
- An inventory with one bootstrap node and any number of follower nodes.
- Reachable validator, RPC, and configured dynamic UDP ports between cluster nodes.

Start from `tests/inventory_private_devnet.ini.example`, copy it outside the repository, and replace the placeholder addresses:

```ini
[private_devnet]
bootstrap-node ansible_host=192.0.2.10 solana_role=bootstrap
follower-node ansible_host=192.0.2.11 solana_role=follower
```

The addresses above are documentation-only examples.

## Key handling

The default workflow is intentionally keyless from Ansible's perspective. Leave these variables empty and the role creates development keypairs locally:

- `solana_identity_key`
- `solana_vote_key`
- `solana_stake_key`
- `solana_faucet_key`

If you supply any of them, inject the value at run time from an encrypted vault or secret manager outside this repository. Do not place a JSON keypair, password, or vault file in the collection directory, an inventory, or a committed variable file.

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `solana_role` | `follower` | Set to `bootstrap` for exactly one node. |
| `solana_image_tag` | `stable` | Agave image tag used to extract binaries. |
| `faucet_enabled` | `true` | Starts the faucet only on the bootstrap node. |
| `faucet_port` | `9900` | Faucet listener port. |
| `solana_dynamic_port_range` | `8000-8020` | Dynamic validator port range. |
| `solana_quic_port` | `34455` | Primary QUIC UDP port. |
| `solana_extra_args` | See defaults | Additional validator arguments. |

Review `defaults/main.yml` before deployment. Port ranges and resource limits must match your firewall and host capacity.

## Deploy

Create an inventory outside this repository, then run:

```bash
ansible-playbook -i /path/to/private-devnet.ini playbooks/deploy_private_devnet.yml
```

Verify basic cluster health from a node after deployment:

```bash
solana validators --url http://localhost:8899
solana slot --url http://localhost:8899
```

## Troubleshooting

If a follower cannot discover the bootstrap node, first check network reachability for gossip, RPC, QUIC, and the configured dynamic range. If validators skip slots, inspect host CPU latency, disk performance, and the configured proof-of-history timing parameters.

For a destructive reset of a development environment, stop the services and remove only the data directory you explicitly configured. A reset deletes the local ledger and locally generated keypairs.
