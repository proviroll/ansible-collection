# Solana Firedancer validators

This document outlines the binary installation and starting command of the `Firedancer validator client`.

For the validator setup, please refere to the main document : [Solana validator setup](./README.md) 

Ref : [Github](https://github.com/firedancer-io/firedancer) | [Firedancer.io - Docs](https://docs.firedancer.io/)

## Install Firedancer

Ref : [Installing Firedancer](https://docs.firedancer.io/guide/getting-started.html#installing).

- **Clone the repository and install dependencies**
```bash
git clone --recurse-submodules https://github.com/firedancer-io/firedancer.git
cd firedancer
git checkout v0.305.20111 # Testnet required version by delegation program February 2025

# Run script to install system packages and compile library dependencies.
./deps.sh
```

- **Build the binaries Firedancer & Solana**
**The build requires about 32GB free memory or can return errors**

```bash
$ make -j fdctl solana
```

- **Successful install & Check version**
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

## Configure and start the validator

### Configure

For `Agave` validator, configurations are passed through multiple arguments to the starting command. For `Firedancer`, it's under a separate config file.

- **Create config file**

Refs : [Configuring Firedancer](https://docs.firedancer.io/guide/configuring.html)  | [GitHub fdctl config templates](https://github.com/firedancer-io/firedancer/tree/main/src/app/fdctl/config)  | [GitHub fdctl config parameters](https://docs.firedancer.io/guide/tuning.html)

**`{validator_dir/config/config.toml}`:**
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

### Initialization

- **Initialization**
```bash
$ sudo ./build/native/gcc/bin/fdctl configure init all --config "PATH"/config.toml
```

> **Firedancer requires priviledged right for some components.**
>**Running any fdctl configure command may make permanent changes to the system.**

Instead of running `fdctl init All`, you can run it's steps in separate commands:

- **hugetlbfs**: *Reserves pages for Firedancer (Must run after each reboot).  
```bash
sudo fdctl configure init hugetlbfs
```

- **sysctl**: Configures required kernel parameters for optimal performance.
```bash  
sudo fdctl configure init sysctl
```

- **ethtool-channels**: Sets the correct number of network channels on the device.
```bash  
sudo fdctl configure init ethtool-channels
```

- **ethtool-gro**: Disables generic-receive-offload on the network device.
```bash  
sudo fdctl configure init ethtool-gro
```

- **ethtool-loopback**: Disables tx-udp-segmentation on the loopback device.
```bash  
sudo fdctl configure init ethtool-loopback
```

### Start & Run

```bash
sudo ./build/native/gcc/bin/fdctl run --config "PATH"/config.toml
```

## Logs & Troubbleshooting

#### Logs

- Firedancer service logs

```bash
sudo journalctl -xeu solana.service -f
```

- Solana exporter logs

```bash
curl http://localhost:9999/metrics
```
#### Troubbleshoot

- Error : **Validator stopped voting**

    - Check logs of Solana service and solana-exporter
    - Check fee payer balance, if not enough fees, validator will not vote

    ```bash
    # From server
    solana balance

    # From trusted computer
    ## Testnet
    solana balance {fee-payer address / identity_pubkey} --url https://api.testnet.solana.com/
    ## Mainnet-Beta
    solana balance {fee-payer address / identity_pubkey} --url https://api.mainnet-beta.solana.com/
    ```

- Error: **Validator skipped blocks**

    - Check network interface errors
    ```bash
    # Get network errors metric
    curl http://localhost:9100/metrics | grep -i node_network_receive_errs_total

    # Example errors

    node_network_receive_errs_total{device="docker0"} 0
    node_network_receive_errs_total{device="enp8s0f0"} 1789
    node_network_receive_errs_total{device="enp8s0f1"} 0
    node_network_receive_errs_total{device="lo"} 0
    ```

    - RDMA driver should be disabled

        - Handled through ansible task:
        ```yaml
        - name: Ensure irdma driver is disabled  
          shell: rmmod irdma  
          become: yes  
        ```
        - Example if not disabled (Validator wouldn't start)
        ```bash
        # Commands for interface enp8s0f0
        sudo dmesg -T | grep -i 'enp8s0f0'
        sudo journalctl -k | grep -i 'enp8s0f0'

        # Example error if any
        [Tue Feb 11 15:00:21 2025] ice 0000:08:00.0 enp8s0f0: Cannot change channels when RDMA is active
        ```

## Resources

- [Firedancer GitHub Repository](https://github.com/firedancer-io/firedancer)
- [Firedancer Documentation](https://docs.firedancer.io/)
