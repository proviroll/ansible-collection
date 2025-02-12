Ref : [Github](https://github.com/firedancer-io/firedancer) | [Firedancer.io - Docs](https://docs.firedancer.io/)

- Install & Build.
```bash
$ git clone --recurse-submodules https://github.com/firedancer-io/firedancer.git
$ cd firedancer
$ git checkout v0.305.20111 # Version required by latest delegation program announcment for Testnet validators

# Run script to install system packages and compile library dependencies.
$ ./deps.sh
```

- Success output
```bash
...
make: Leaving directory '/home/devops/solana-firedancer/firedancer/opt/git/s2n/x86'
[+] Successfully installed s2n-bignum
[~] Done!
```

>Note: For some reason, had to **install `rust`, `rustup` and `cargo`** and then build this latest version (after the execution of the dependencies install script)

- Continue. **The build requires about 32GB free memory or can return errors**.
```bash
$ make -j fdctl solana
```

- Successful install & Check version
```bash
# Check Firedancer version
$ ./build/native/gcc/bin/fdctl --version

# Output
0.305.20111

# Solana version
$ ./build/native/gcc/bin/solana --version

# Output
solana-cli 0.305.20111 (src:78eefec7; feat:3039680930, client:Firedancer)
```

- Create config file :

```conf
user = "devops"

[gossip]
    entrypoints = [
      "entrypoint.testnet.solana.com:8001",
      "entrypoint2.testnet.solana.com:8001",
      "entrypoint3.testnet.solana.com:8001",
    ]

[consensus]
    identity_path = "/home/firedancer/validator-keypair.json"
    vote_account_path = "/home/firedancer/vote-keypair.json"

    known_validators = [
        "5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on",
        "dDzy5SR3AXdYWVqbDEkVFdvSPCtS9ihF5kJkHCtXoFs",
        "Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN",
        "eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ",
        "9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv",
    ]

[rpc]
    port = 8899
    full_api = true
    private = true

[reporting]
    solana_metrics_config = "host=https://metrics.solana.com:8086,db=tds,u=testnet_write,p=c4fa841aa918bf8274e3e2a44d77568d9861b3ea"
```

- Initialization:

```bash
$ sudo ./build/native/gcc/bin/fdctl configure init all --config "PATH"/config.toml
```

> **Firedancer requires priviledged right for some components.**
>**Running any fdctl configure command may make permanent changes to the system.**


- Starting the validator

```bash
sudo ./build/native/gcc/bin/fdctl run --config "PATH"/config.toml
```


# Solana Validator Alerts Overview

## **Validator Last Vote vs Cluster Last Vote**
- **Formula**: `solana_cluster_last_vote - solana_validator_last_vote`
- **Threshold**: Alerts if the difference is significant.
- **Evaluation Time**: 5 minutes.

## **Fee Payer Balance (Identity)**
- **Formula**: `solana_account_balance{address="identity_account"}`
- **Threshold**: Alerts if balance drops below 0.004 SOL.
- **Evaluation Time**: Continuous (every few seconds).

## **Validator Blockheight Increasing**
- **Formula**: `rate(solana_node_block_height[5m])`
- **Threshold**: Alerts if the block height is not increasing (rate <= 0).
- **Evaluation Time**: 5 minutes.

## **Validator is Delinquent**
- **Formula**: `solana_validator_status{is_delinquent="true"}`
- **Threshold**: Alerts if the validator is delinquent.
- **Evaluation Time**: 5 minutes.

## Other alerts Alerts:
- **Missed Slots**: If missed slots exceed a threshold.
- **Epoch Progress**: If epoch progress stagnates.
- **Active Stake**: If active stake drops below a critical threshold (e.g., 10,000 SOL).
- **Cluster Health**: Alerts if the validator's health status changes.
