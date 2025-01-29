# Solana

- [Anza.xyz Docs - Deploy Agave validator](https://docs.anza.xyz/operations/setup-a-validator/)

- [Medium Docs](https://medium.com/rahasak/deploy-solana-test-network-with-docker-418622c4f566)

## Install binary / Run solana container

Ref : [Anza.xyz docs - Solana install tools](https://docs.anza.xyz/cli/install#use-solanas-install-tool).

```bash
curl -sSfL https://release.anza.xyz/v2.1.5/install
... 
export PATH="/home/devops/.local/share/solana/install/active_release/bin:$PATH" to /home/devops/.profile
Close and reopen your terminal to apply the PATH changes or run the following in your existing shell:
  
export PATH="/home/devops/.local/share/solana/install/active_release/bin:$PATH"
# Check version
solana --version
solana-cli 2.1.5 (src:4da190bd; feat:288566304, client:Agave)
```

- Run validator container:
```bash
cd /home/devops/solana-validator

docker run -dit --name solana-validator-init \
-v $(pwd):/root \
  -p 8899:8899 \
  solanalabs/solana:v1.18.26 \
  /bin/sh
```

- Check version

```bash
solana --version
```

- **Configure validator network communication**. For `Testnet` and `mainnet-beta` endpoints:

```bash
solana config set --url https://api.testnet.solana.com
solana config set --url https://api.mainnet-beta.solana.com
```

- Generate keys (3 keypairs):
```bash
solana-keygen new -o ./validator-keypair.json

solana-keygen new -o ./vote-account-keypair.json

solana-keygen new -o ./authorized-withdrawer-keypair.json
```

- Verify your public key:

```bash
solana-keygen verify <public_key> ASK
```

- Set validator keypair file:

```bash
solana config set --keypair /home/sol/keypairs/validator-keypair.json
```

**Check config**:
```bash
solana config get
```

- Create vote account:

```bash
# Mainnet-beta
solana create-vote-account <ACCOUNT_KEYPAIR> <IDENTITY_KEYPAIR> <WITHDRAWER_PUBKEY> --commission <PERCENTAGE> --config <FILEPATH>
# Testnet
solana create-vote-account -ut <ACCOUNT_KEYPAIR> <IDENTITY_KEYPAIR> <WITHDRAWER_PUBKEY> --commission <PERCENTAGE> --config <FILEPATH>
```
- Check balance
**for the next action vote account creation (transaction), you can request airdrop only for testnet and devnet.**

``` bash
solana balance

solana airdrop 5
```

- Start validator

```bash
cd /home/devops/solana-validator

sudo docker run -dit \
  --network host \
  -v $(pwd):/root \
  -v /mnt/snapshots:/snapshot \
  --name solana-agave-validator \
  --env PATH=/root/.local/share/solana/install/releases/stable-40aee13cd02255930dc78b5ccd1d1fcda9d5bb15/solana-release/bin:$PATH \
  --workdir /root \
  cb82c92878b0 \
  agave-validator \
  --ledger /root/ledger \
  --identity /root/keypairs/validator-keypair.json \
  --known-validator 2E2JPuFhjkQvEJEeNGqVSwGLJa5GoFqabQTutGjg1bzw \
  --known-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
  --known-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
  --known-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
  --known-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
  --dynamic-port-range 8000-8020 \
  --entrypoint entrypoint.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
  --expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
  --wal-recovery-mode skip_any_corrupted_record \
  --limit-ledger-size 50000000 \
  --full-rpc-api \
  --no-voting \
  --no-os-network-limits-test \
  --rpc-bind-address 0.0.0.0 \
  --rpc-port 8899 \
  
#   --only-known-rpc
```

## Tips and queries

- Default config dir:

```bash
/root/.config/solana/
```
- Check RPC is up, Example query Solana version:

```bash
  curl -X POST http://localhost:8899 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1,"method":"getVersion","params":[]}' | jq
```
**Output**:
```json
{"jsonrpc":"2.0","result":{"feature-set":3241752014,"solana-core":"1.18.26"},"id":1}
```

- Set commission
```bash
solana vote-update-commission --fee-payer ~/.config/solana/id.json <VOTE_ACCT_PUBKEY> 8 ASK
```

- Verify balance

```bash
solana balance
```

Request 1 SOL airdrop (testnet and devnet only):
```bash
solana airdrop 1
solana airdrop <sol token value> –-url https://api.testnet.solana.com
```
- Identify validator's pubkey
```bash
solana-keygen pubkey /home/sol/keypairs/validator-keypair.json
```

- Check validator's pubkey is in active in the Solana gossip protocol:

```bash
solana gossip | grep <pubkey>
```

- Example Output:
```bash
139.178.68.207  | 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on | 8001   | 8004  | 139.178.68.207:80     | 1.14.17 | 3488713414
```

- Check syncing

```bash
solana catchup --url https://api.mainnet-beta.solana.com --our-localhost 8899
```

```bash
curl -X POST http://localhost:8899 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1, "method":"getBlockHeight"}'
```
## Stake and validate

- Stake Tokens, which will activate in the next epoch

- Verify the validator is among SOlana validators with command:

```bash
solana validators | grep <pubkey>
```
## State-Sync

The node will download a snapshot automatically. Make sure you have enough `--known-validators` specified , or remove `--only-known-rpc` flag so that it fetches peers automatically.

If you prefere it not to:

1. Add the following arguments to the node starting command:
```bash
--no-snapshot-fetch
```
2. Get snapshots :

you can download it from a known source, Example :
Ref : https://gist.github.com/MyBlueLotus/2ff5e9fd901ec1cb59d8fa24f115b857

Or, choose the address of one known validator, and look for IP and port to manually download snapshots.

Example `known validator address 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on`:

```bash
solana gossip | grep 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on
# Output:
139.178.68.207  | 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on | 8001   | 8004  | 139.178.68.207:80     | 1.10.27 | 1425680972

# Use the port and IP to fetch both snapshots:
wget --trust-server-names http://139.178.68.207:80/snapshot.tar.bz2
wget --trust-server-names http://139.178.68.207:80/incremental-snapshot.tar.bz2
```

Place the snapshots in the respective location, re-check you arguments and re-start the validator.
