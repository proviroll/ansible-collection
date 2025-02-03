# Solana validator - Setup

- [Anza.xyz Docs - Deploy Agave validator](https://docs.anza.xyz/operations/setup-a-validator/)

## Create directories

```bash
mkdir -p /home/devops/solana-validator/config
mkdir -p /home/devops/solana-validator/data/ledger
mkdir -p /home/devops/solana-validator/data/accounts
mkdir -p /home/devops/solana-validator/data/snapshots
```

## Install or update binary

>Using `agave-validator v2.0.24` as per the:  [Solana Discord Channel - latest testnet announcment](https://discordapp.com/channels/428295358100013066/594138785558691840/1334550076323794955)

### Install :

```bash
sh -c "$(curl -sSfL https://release.anza.xyz/v2.0.24/install)"

#Log out and in again, use 'source ~/.profile' or 'export PATH'. Output:
downloading v2.0.24 installer
  ✨ 2.0.24 initialized
Adding 
export PATH="/home/devops/.local/share/solana/install/active_release/bin:$PATH" to /home/devops/.profile

Close and reopen your terminal to apply the PATH changes or run the following in your existing shell:
  
export PATH="/home/devops/.local/share/solana/install/active_release/bin:$PATH"
```

- Check active version:
```bash
solana --version

# Output
solana-cli 2.0.24 (src:336796a7; feat:607245837, client:Agave)
```

- Update binary
**Make sure you're target version is currently recommended by the network**
```bash
agave-install update
```

### Setup your validator

#### Config

- Set the desired network's endpoint

```bash
solana config set --url https://api.testnet.solana.com

# Other networks
https://api.mainnet-beta.solana.com
https://api.devnet.solana.com
```

- To re-check your config:
```bash
solana config get
```

#### Create Keys

**:warning: Perform this action on a trusted computer** 

```bash
# Identity key
solana-keygen new -o validator-keypair.json

# Vote account
solana-keygen new -o vote-account-keypair.json

# Authorized withdrawer
solana-keygen new -o authorized-withdrawer-keypair.json
```

#### Set identity key

If you check your solana config, your validator keypair is not yet selected to be used. Set it by:
```bash
solana config set --keypair ./validator-keypair.json # Adjust path if needed
```

- Double check config:
```bash
solana config get
# Output
Config File: /home/devops/.config/solana/cli/config.yml
RPC URL: https://api.testnet.solana.com 
WebSocket URL: wss://api.testnet.solana.com/ (computed)
Keypair Path: ./validator-keypair.json # Ok
Commitment: confirmed 
```

#### Balance & Vote account

- Check the current balance by executing:
```bash
solana balance
# If any error, recheck the config or ensure correct API is used:
solana balance --url https://api.testnet.solana.com/
```

- For testnet and devnet only, you can request SOL Tokens:
```bash
solana airdrop 1
```
Alternatively, you can find here example faucet: [Quicknode - Solana testnet faucet](https://faucet.quicknode.com/solana/testnet).

- Create vote account **Add -ut for testnet**:

```bash
solana create-vote-account -ut \  # '-ut' for testnet
    --fee-payer ./validator-keypair.json \
    ./vote-account-keypair.json \
    ./validator-keypair.json \
    ./authorized-withdrawer-keypair.json

# Output
Signature: 2obHTrHgKQ7L9or11ECb4jwkphqYdp6aaDnJ17pvYBWw18ADmvz5HxVmyLNaFH75AmUxHqyKqYokq19KDjFQyDbs
```

>**Make sure your `authorized-withdrawer-keypair.json` is stored in a safe place.
>
>If you have chosen to create a keypair on disk, you should first backup the keypair and then delete it from your local machine.**


## Run the valdiator

```bash
sudo apt update
```
### Hard Drive setup

Currently hosting `Ledger` and `Accounts` directories on the base filesystem.
For reference, The validator documentation consists of Mounting 2 different drives for  `Ledger` and `Accounts` folders as it follows:

```bash
# After needed formatting, mount disks respectively
sudo mount /dev/nvme0n1 /mnt/ledger
sudo mount /dev/nvme1n1 /mnt/accounts
```
For detailed information, refere to  : [Anza.xyz docs - Setup a validator : Herd drive setup](https://docs.anza.xyz/operations/setup-a-validator#hard-drive-setup)

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

## Create A Validator Startup Script

```bash
touch /home/devops/solana-validator/config/validator.sh
chmod +x /home/devops/solana-validator/config/validator.sh

nano /home/devops/solana-validator/config/validator.sh

# Content
#!/bin/bash
exec agave-validator \
    --identity /home/devops/solana-validator/.config/validator-keypair.json \
    --vote-account /home/devops/solana-validator/.config/vote-account-keypair.json \
    --ledger /home/devops/solana-validator/data/ledger \
    --accounts /home/devops/solana-validator/accounts \
    --no-snapshot-fetch \
    --snapshots /home/devops/solana-validator/data/snapshots
    --maximum-full-snapshots-to-retain 1 \
    --maximum-incremental-snapshots-to-retain 2 \
    --log /home/devops/solana-validator/agave-validator.log \
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
    --limit-ledger-size \
    --no-voting
```
<!-- 
agave-validator \
  --no-os-network-limits-test \
  --dynamic-port-range 8000-8020 \
  --full-rpc-api \ 
  --limit-ledger-size 50000000 \
-->

- Init validator
```bash
#!/bin/bash
agave-validator \
--identity /home/devops/solana-validator/.config/validator-keypair.json \
--vote-account /home/devops/solana-validator/.config/vote-account-keypair.json \
--ledger /home/devops/solana-validator/data/ledger \
--accounts /home/devops/solana-validator/accounts \
--snapshots /home/devops/solana-validator/data/snapshots \
--expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
--entrypoint entrypoint2.testnet.solana.com:8001 \
--rpc-port 8899
```

- Verify valdiator is working

```bash
/home/devops/solana-validator/config/validator.sh

ps aux | grep agave-validator

tail -f /home/devops/solana-validator/agave-validator.log
```

## State-sync

To avoid errors of download, snapshot-finder helps find, test and chose peers with best download speed and snapshots availability.

Ref : https://github.com/c29r3/solana-snapshot-finder

```bash
mkdir snapshot-finder
cd snapshot-finder

sudo apt-get update \
&& sudo apt-get install python3-venv git -y \
&& git clone https://github.com/c29r3/solana-snapshot-finder.git \
&& cd solana-snapshot-finder \
&& python3 -m venv venv \
&& source ./venv/bin/activate \
&& pip3 install -r requirements.txt

# Testnet
python3 snapshot-finder.py --snapshot_path /home/devops/solana-validator/data/ledger -r http://api.testnet.solana.com
```
### Warnings & Errors

```log
I0131 22:14:16.497823       1 slots.go:100] slot has not advanced at 315160701, skipping
```

### Health
```bash
# Prompt validators public key
solana address

# Similar to solana-gossip, you should see your validator in the list of cluster nodes
curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getClusterNodes"}' http://api.testnet.solana.com | jq | grep EfeFqTrp6LMYGmL9KKMSTKg9Xtjxn8AJTcjTCaY7bo99
# If your validator is properly voting, it should appear in the list of `current` vote accounts. If staked, `stake` should be > 0
curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getVoteAccounts"}' http://api.testnet.solana.com | jq | grep EfeFqTrp6LMYGmL9KKMSTKg9Xtjxn8AJTcjTCaY7bo99
# Returns the current leader schedule
curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getLeaderSchedule"}' http://api.testnet.solana.com | jq
# Returns info about the current epoch. slotIndex should progress on subsequent calls.
curl -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getEpochInfo"}' http://api.testnet.solana.com | jq

# Current valdiator's block height
curl -X POST http://127.0.0.1:8899 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getBlockHeight"}' | jq
```

### Metrics

- Start solana exporter

```bash
docker run -dit --name solana-exporter \
-v /home/devops/solana-exporter/data:/root \
-v /home/devops/solana-exporter/exporter:/exporter \
--network host  \
mcamou/solana-exporter:b8fcc7c170049d5c9c34ea57b9f2fcb3a0b5044d \
--rpcURI http://localhost:8899/ \  # Validator's RPC Endpoint
-votepubkey G24BnEhTgXbFdHu2tXGRNdxbwrGZx9jXWVroDyNuqdQp \
-addr :9999 # Exporter's listen address

# Query
curl http://localhost:9999/metrics

# Logs
docker logs solana-exporter
```

```bash
# Exporter CLI help
# Test container image : mcamou/solana-exporter:b8fcc7c170049d5c9c34ea57b9f2fcb3a0b5044d
flag provided but not defined: -nodekey
Usage of /app:
  -add_dir_header
    	If true, adds the file directory to the header of the log messages
  -addr string
    	Listen address (default ":8080")
  -alsologtostderr
    	log to standard error as well as files
  -http_timeout int
    	HTTP timeout in seconds (default 60)
  -log_backtrace_at value
    	when logging hits line file:N, emit a stack trace
  -log_dir string
    	If non-empty, write log files in this directory
  -log_file string
    	If non-empty, use this log file
  -log_file_max_size uint
    	Defines the maximum size a log file can grow to. Unit is megabytes. If the value is 0, the maximum file size is unlimited. (default 1800)
  -logtostderr
    	log to standard error instead of files (default true)
  -one_output
    	If true, only write logs to their native severity level (vs also writing to each lower severity level
  -rpcURI string
    	Solana RPC URI (including protocol and path)
  -skip_headers
    	If true, avoid header prefixes in the log messages
  -skip_log_headers
    	If true, avoid headers when opening log files
  -stderrthreshold value
    	logs at or above this threshold go to stderr (default 2)
  -v value
    	number for the log level verbosity
  -vmodule value
    	comma-separated list of pattern=N settings for file-filtered logging
  -votepubkey string
    	Validator vote address (will only return results of this address)
```
