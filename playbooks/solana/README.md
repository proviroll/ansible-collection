# Solana validator

Solana validator runs under different clients that you can choose from. Mainly [Agave](https://docs.anza.xyz/operations/setup-a-validator) and [Firedancer](https://github.com/firedancer-io/firedancer), with a minimum version requirement.

Also, participants of Solana Delegation Foundation have more specific version requirements, including the validator's client and version, which results in our current setup:

- Version required for Testnet : `Agave v3.1.8` | `Firedancer v0.811.30108`.
- Version required for Mainnet-Beta : `Agave v2.1.13`.

These are specifications for January 2026 and might change. You can check here the latest [Solana Foundation Announcements](https://discordapp.com/channels/428295358100013066/895740485140906054).

## Table of Contents

- [Install Binary 🛠️](#install-binary)
- [Pre-configure ⚙️](#pre-configure)
  - [Create Directories](#create-directories)
  - [Setup Your Validator](#setup-your-validator)
    - [Create Keys](#create-keys)
    - [Set Identity Key](#set-identity-key)
    - [Config](#config)
    - [Balance & Vote Account](#balance--vote-account)
  - [Publish Validator Information](#publish-validator-information)
- [Start the Validator 🚀](#start-the-validator)
- [Upgrade the validator](#upgrade-the-validator)
- [State-sync 🔄](#state-sync)
- [Health & Monitoring 📊](#health--monitoring)
  - [Alerting](#alerting)
  - [RPC Queries](#rpc-queries)
  - [Logs](#logs)
  - [Metrics](#metrics)
  - [Community Overview 🌍](#-community-overview)


## Install binary

This section is for getting started with the desired binary. Refer to the documents below respectively for :

- [Install Agave validator client](./Run-Agave.md#install-agave)
- [Install Firedancer validator client](./Run-Firedancer.md#install-firedancer)

Once the binary is installed, continue with the steps of the current document.

## Pre-configure

### Create directories

These will be directories where the validator manages that config files and the data:
```bash
{validator_directory}/config
{validator_directory}/data/ledger
{validator_directory}/data/accounts
{validator_directory}/data/snapshots
```

### Setup your validator

#### Create Keys

⚠️ **Warning: Perform this action on a trusted computer** 

```bash
# Identity key
solana-keygen new -o validator-keypair.json

# Vote account
solana-keygen new -o vote-account-keypair.json

# Authorized withdrawer
solana-keygen new -o authorized-withdrawer-keypair.json
```

#### Set identity key

**Place the keys on the `config_dir` on the server**
If you check your solana config, your validator keypair is not yet selected to be used. Set it by:
```bash
solana config set --keypair {config_dir}/validator-keypair.json # Adjust path if needed
```

- **Double check config**
```bash
solana config get
# Output
Config File: /home/devops/.config/solana/cli/config.yml
RPC URL: https://api.testnet.solana.com 
WebSocket URL: wss://api.testnet.solana.com/ (computed)
Keypair Path: {config_dir}/validator-keypair.json # Ok
Commitment: confirmed 
```

#### Config

- Set the desired network's endpoint

```bash
# Mainnet-beta
solana config set --url https://api.mainnet-beta.solana.com

# Testnet
solana config set --url https://api.testnet.solana.com

# Devnet
solana config set --url https://api.devnet.solana.com
```

- To re-check the config:
```bash
solana config get
```

#### Balance & Vote account

- **Check the current balance**
```bash
solana balance
# If any error, recheck the config or ensure correct API is used:
solana balance --url https://api.testnet.solana.com/
```

- **request SOL airdrop** (testnet and devnet):
```bash
solana airdrop 1
```
Alternatively, use faucet. Example: [Quicknode - Solana testnet faucet](https://faucet.quicknode.com/solana/testnet).

-**Create vote account** - Add `-ut` for testnet:

```bash
solana create-vote-account -ut \  # '-ut' for testnet
    --fee-payer ./validator-keypair.json \
    ./vote-account-keypair.json \
    ./validator-keypair.json \
    ./authorized-withdrawer-keypair.json

# Output
Signature: 2obHTrHgKQ7L9or11ECb4jwkphqYdp6aaDnJ17pvYBWw18ADmvz5HxVmyLNaFH75AmUxHqyKqYokq19KDjFQyDbs
```

### Publish validator information

```bash
solana validator-info publish --keypair ~/validator-keypair.json <VALIDATOR_INFO_ARGS> <VALIDATOR_NAME>
```

## Start the validator

This step, is proper to each client. Refer to the respective document to:

- [Start Agave Validator](./Run-Agave.md#run-the-validator)
- [Start Firedancer validator](./Run-Firedancer.md#configure-and-start-the-validator)

The rest of the steps can be followed on this mutual document.

## State-sync

The validator will download recent snapshots from peers unless the argument **--no-snapshot-fetch** is specified.

The snapshot finder tool tried to simplify the process (not very recommended):

- Ref : https://github.com/c29r3/solana-snapshot-finder

## Upgrade the validator

#### To Upgrade Agave client

Follow this section : [Here](./Run-Agave.md#upgrade-agave)

#### To Upgrade Firedancer client

Follow this section : [Here](./Run-Firedancer.md#upgrade-firedancer)

## Health & Monitoring

>Note: Once the validator is started, it takes minutes for the RPC enpoint to be up. Generally, until the node gets a first snapshot and starts catching up.

- **Check if the validator is syncing**
```bash
solana catchup --our-localhost 8899
```

- Check **voting activity** and **how much credit is earned per epoch**

```bash
solana vote-account 2paKzeZKpPpSd5kJdoNZ9LTWhHMJXDL3bjMhfRa7xjus --output json

# Output

# Epoch and vote information
{
  "accountBalance": 108211850405,
  "validatorIdentity": "EfeFqTrp6LMYGmL9KKMSTKg9Xtjxn8AJTcjTCaY7bo99",
  "authorizedVoters": {
    "748": "EfeFqTrp6LMYGmL9KKMSTKg9Xtjxn8AJTcjTCaY7bo99"
  },
  "authorizedWithdrawer": "A8GpR2QikRgbZ5Lo6Kq8nRHCpg4zRNB7SipCxyakdfeE",
  "credits": 22970830,
  "commission": 100,
  "rootSlot": 317631440,
  "recentTimestamp": {
    "slot": 317631489,
    "timestamp": 1739547836
  },
  "votes": [
    {
      "latency": 2,
      "slot": 317631441,
      "confirmationCount": 31
    },
    {
      "latency": 1,
      "slot": 317631448,
  ### ... The rest of votes history

  ### Information per epoch:
    {
      "epoch": 747,
      "slotsInEpoch": 432000,
      "creditsEarned": 4082554, # 4.08M Credit earned in Epoch 747
      "credits": 22773993,
      "prevCredits": 18691439,
      "maxCreditsPerSlot": 16
    },
    {
      "epoch": 748,
      "slotsInEpoch": 432000,
      "creditsEarned": 196837,
      "credits": 22970830,
      "prevCredits": 22773993,
      "maxCreditsPerSlot": 16
    }
  ]
}
```

### Alerting

As per our [monitoring setup](../monitoring/README.md), alerting is enabled on `Alertmanager` for critical events regarding the validator.

We have two different set of alert rules :

- **Agave validator Alert rules**

  **`Validator Last Vote vs Cluster Last Vote`**
  - **Formula**: `solana_cluster_last_vote - solana_validator_last_vote`
  - **Threshold**: Alerts if the difference is significant.
  - **Evaluation Time**: 5 minutes.

  **`Fee Payer Balance (Identity)`**
  - **Formula**: `solana_account_balance{address="identity_account"}`
  - **Threshold**: Alerts if balance drops below 0.004 SOL.
  - **Evaluation Time**: Continuous (every few seconds).

  **`Validator Blockheight Increasing`**
  - **Formula**: `rate(solana_node_block_height[5m])`
  - **Threshold**: Alerts if the block height is not increasing (rate <= 0).
  - **Evaluation Time**: 5 minutes.

  **`Validator is Delinquent`**
  - **Formula**: `solana_validator_status{is_delinquent="true"}`
  - **Threshold**: Alerts if the validator is delinquent.
  - **Evaluation Time**: 5 minutes.

- **Firedancer Validator Alert Rules**

  **`Validator Blockheight Progress`**
  - **Formula:** `rate(solana_node_block_height[5m])`
  - **Threshold:** Alerts if the block height rate is below 0.5.
  - **Evaluation Time:** 5 minutes.

  **`Validator Last Vote Progress`**
  - **Formula:** `increase(solana_validator_last_vote[10m])`
  - **Threshold:** Alerts if the increase is below 10 in 10 minutes.
  - **Evaluation Time:** 10 minutes.

  **`Validator Active Status`**
  - **Formula:** `solana_active_validators`
  - **Threshold:** Alerts if the validator is not active.
  - **Evaluation Time:** 5 minutes.

  **`Validator Delinquency (Should Not Be)`**
  - **Formula:** `solana_validator_delinquent`
  - **Threshold:** Alerts if any validator is marked as delinquent.
  - **Evaluation Time:** 5 minutes.

### RPC queries

Ref : [Solana Docs - RPC](https://solana.com/fr/docs/rpc/http)

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

# Current validator's block height
curl -X POST http://127.0.0.1:8899 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getBlockHeight"}' | jq
```

### Logs

When running as a service:

```bash
sudo journalctl -xeu solana.service -f
```

- **For Agave** - Follow log file:
```bash
tail /home/devops/solana-validator/config/agave-validator.log -f
```
The log file can get to 10Gb in one week. Temporary measure for purging log file **without deleting it, otherwise will need to restart solana.service** to create it again:

```bash
# Creating a copy of the log file with current date
cp agave-validator.log "agave-validator.log_$(date +%F)"

# Reset file content
echo "purged" > agave-validator.log
```

### Metrics

- `solana-exporter` metrics:
```bash
curl http://localhost:9999/metrics
```

- Basic `firedancer` metrics:
```bash
curl http://localhost:7999/metrics
```

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

## 🌍 Community Overview

Join the Solana ecosystem through various platforms:

- 💬 **[Solana Discord](https://discord.gg/solana)**
- 🖥️ **[Solana Website](https://solana.com/)** | 🏛️ **[Solana Foundation Website](https://solana.org/)**
- 🔎 **[Solana Explorer](https://explorer.solana.com/)**
- 📖 **[Agave - GitHub repository](https://github.com/anza-xyz/agave)** | **[Agave Docs by Anza.xyz](https://docs.anza.xyz/operations/)**
- 🔥 **[Firedancer GitHub](https://github.com/firedancer-io/firedancer)**

Track validators voting and other stats:

- **[Svt one - Validator Toolkit](https://svt.one/dashboard/2paKzeZKpPpSd5kJdoNZ9LTWhHMJXDL3bjMhfRa7xjus?cluster=testnet)** : If you connect wallet on the website (**We have Not done that**), you can track voting compensation (each time SFDP sends SOL back to cover the voting fees spent)
  [Source - Discord - Delegation Prodram chanel](https://discordapp.com/channels/428295358100013066/849749936916267029/1357496427231711434)
- **[SFDP Required Versions](https://api.solana.org/api/community/v1/sfdp_required_versions?cluster=testnet)** : API endpoint for Solana Foundation Delegation Program version requirements.
- **[SFDP Participants](https://api.solana.org/api/community/v1/sfdp_participants)** : API endpoint for list of SFDP participants.
