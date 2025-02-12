# Solana - Firedancer Setup

## Install Binary and Dependencies

Follow the steps in the official guide to install the necessary binary and dependencies:  
[Installing Firedancer](https://docs.firedancer.io/guide/getting-started.html#installing)

## Configuration `config.toml`

Configure the required parameters in your `config.toml` file by referring to these resources:  
[Configuring Firedancer](https://docs.firedancer.io/guide/configuring.html)  
[GitHub fdctl config templates](https://github.com/firedancer-io/firedancer/tree/main/src/app/fdctl/config)
[GitHub fdctl config parameters](https://docs.firedancer.io/guide/tuning.html)

## Initialize Node

### All Init steps at once

```bash
sudo ./build/native/gcc/bin/fdctl configure init all --config "PATH"/config.toml
```

### Init step by step

- **hugetlbfs**: *Reserves pages for Firedancer.  
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
## Start Validator

```bash
fdctl run --config "PATH"/config.toml
```

## Metrics & Logs

- Logs:
```bash
sudo journalctl -xeu solana.service -f
```

- Metrics:

    - `solana-exporter` metrics:
    ```bash
    curl http://localhost:9999/metrics
    ```

    - Basic `firedancer` metrics:
    ```bash
    curl http://localhost:37999/metrics
    ```
