# Solana Agave validator

This document outlines the binary installation and starting command of the `Agave validator client`.

For the validator setup, please refere to the main document : [Solana validator setup](./README.md) 

- [Anza.xyz Docs - Deploy Agave validator](https://docs.anza.xyz/operations/setup-a-validator/)

## Install & update binary

### Install Agave

```bash
sh -c "$(curl -sSfL https://release.anza.xyz/v2.1.13/install)"
# Make sure to handle PATH update
export PATH="/home/devops/.local/share/solana/install/active_release/bin:$PATH"
```

- Check active version:
```bash
solana --version

# Output
solana-cli 2.1.13 (src:336796a7; feat:607245837, client:Agave)
```

### Update Agave

**Make sure you're target version is the one currently recommended by the network**.
Or you can simply run the same previous `**Install**` process, with the new version tag.
```bash
agave-install update
```
---
## Run the validator

```bash
sudo apt update
```
### System tuning

- Setup service

```bash
sudo bash -c "cat >/etc/sysctl.d/21-agave-validator.conf <<EOF
# Increase UDP buffer sizes
net.core.rmem_default = 134217728
net.core.rmem_max = 134217728
net.core.wmem_default = 134217728
net.core.wmem_max = 134217728

# Increase memory mapped files limit
vm.max_map_count = 1000000

# Increase number of allowed open file descriptors
fs.nr_open = 1000000
EOF"
```

```bash
sudo sysctl -p /etc/sysctl.d/21-agave-validator.conf
```

- Increase systemd and session file limit
```bash
# Add the line
LimitNOFILE=1000000 # [Service] section of /etc/systemd/system.conf
# Or add the line:
DefaultLimitNOFILE=1000000 # To [Manager] section of /etc/systemd/system.conf

# Reload daemon
sudo systemctl daemon-reload
```
- Increase process file descriptor count limit

```bash
sudo bash -c "cat >/etc/security/limits.d/90-solana-nofiles.conf <<EOF
# Increase process file descriptor count limit
* - nofile 1000000
EOF"
```

>**Close all open sessions (log out then, in again)**

## Initialization

- Init validator **Mainnet-beta example**
```bash
#!/bin/bash
agave-validator \
--identity {{ config_dir }}/validator-keypair.json \
--vote-account {{ config_dir }}/vote-account-keypair.json \
--ledger {{ data_dir }}/ledger \
--accounts {{ data_dir }}/accounts \
--snapshots {{ data_dir }}/snapshots
--expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
--entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
--rpc-port 8899
```

## Start the validator

- The `agave-validator` startup command with recommended arguments, set up in a startup script:

```bash
touch {{ config_dir }}/validator.sh
chmod +x {{ config_dir }}/validator.sh
nano {{ config_dir }}/validator.sh

# Content
#!/bin/bash
exec agave-validator \
    --identity /home/devops/solana-validator/.config/validator-keypair.json \
    --vote-account {{ config_dir }}/vote-account-keypair.json \
    --ledger {{ data_dir }}/ledger \
    --accounts {{ data_dir }}/accounts \
    --snapshots {{ data_dir }}/snapshots \
    --maximum-full-snapshots-to-retain 1 \
    --maximum-incremental-snapshots-to-retain 2 \
    --log {{ data_dir }}/agave-validator.log \
    --rpc-port 8899 \
    --dynamic-port-range 8000-8020 \
    --only-known-rpc \
    --known-validator 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on \
    --known-validator 7XSY3MrYnK8vq693Rju17bbPkCN3Z7KvvfvJx4kdrsSY \
    --known-validator Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN \
    --known-validator 9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv \
    --entrypoint entrypoint2.testnet.solana.com:8001 \
    --entrypoint entrypoint3.testnet.solana.com:8001 \
    --expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
    --wal-recovery-mode skip_any_corrupted_record \
```
- More arguments:
```bash
  --no-snapshot-fetch # Use this arg if you already have snapshot, else, the validator with download it from peers
  --full-rpc-api # TO have all RPC functionalities (we run a private RPC)
  --limit-ledger-size 50000000 # Limit ledger stored data
  --no-voting # If you want the validator to not vote for blocks
```

- Verify validator is working

```bash
{config_dir}/validator.sh

ps aux | grep agave-validator

tail -f {data_dir}/agave-validator.log
```

### Resources  

- [Agave Docs](https://docs.anza.xyz/operations/setup-a-validator/)  
- [Agave GitHub](https://github.com/anza-xyz/agave)  
- [Solana Forum - Agave](https://forums.solana.com/)  
