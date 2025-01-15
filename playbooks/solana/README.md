# Solana

- Ref: https://solana.com/fr/developers/guides/getstarted/solana-test-validator
- Clear Doc : https://www.helius.dev/blog/how-to-set-up-a-solana-validator

- Deploy Agave validator (considere for mainnet-beta): https://docs.anza.xyz/operations/setup-a-validator/
https://www.youtube.com/watch?v=7Hmkaj-5QUU&list=PLilwLeBwGuK78yjGBZwYhTf7rao0t13Zw&index=1

- Other : https://medium.com/rahasak/deploy-solana-test-network-with-docker-418622c4f566

- Run validator container:

```bash
# Mainnet-beta

cd /home/devops/solana-valdiator

docker run -d --name solana-validator \
  -v $(pwd):/root \
  -p 8899:8899 \
  solanalabs/solana:v1.18.26 solana-validator \
  --expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
  --ledger /root/ledger \
  --identity /root/validator-keypair.json \
  --our-validator /root/validator-keypair.json \
  --our-localhost 8899 \
  --only-known-rpc \
  --known-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
  --known-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
  --known-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
  --known-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
  --full-rpc-api \
  --no-voting \
  --rpc-port 8899 \
  --rpc-bind-address 0.0.0.0 \
  --private-rpc \
  --dynamic-port-range 8000-8020 \
  --entrypoint entrypoint.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
  --expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
  --wal-recovery-mode skip_any_corrupted_record \
  --limit-ledger-size 50000000 \
  --no-snapshot-fetch

# Testnet
docker run -d --name solana-validator \
  -v $(pwd):/mnt \
  -p 8899:8899 \
  solanalabs/solana:v1.18.26 solana-validator \
  --identity /root/validator-keypair.json \
  --vote-account /root/vote-account-keypair.json \
  --known-validator 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on \
  --known-validator 7XSY3MrYnK8vq693Rju17bbPkCN3Z7KvvfvJx4kdrsSY \
  --known-validator Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN \
  --known-validator 9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv \
  --only-known-rpc \
  --log /root/solana-validator.log \
  --ledger /mnt/ledger \
  --accounts /mnt/accounts \
  --rpc-port 8899 \
  --dynamic-port-range 8000-8020 \
  --entrypoint entrypoint.testnet.solana.com:8001 \
  --entrypoint entrypoint2.testnet.solana.com:8001 \
  --entrypoint entrypoint3.testnet.solana.com:8001 \
  --expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
  --wal-recovery-mode skip_any_corrupted_record \
  --limit-ledger-size
```

- Default config dir for `solanalabs/solana:v1.18.26`:

```bash
/root/.config/solana/
```
- Check RPC is up, Example query Solana version:

```bash
curl -X POST http://localhost:8899 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1,"method":"getVersion","params":[]}'
```
**Output**:
```json
{"jsonrpc":"2.0","result":{"feature-set":3241752014,"solana-core":"1.18.26"},"id":1}
```

- By default, valdiator connects to mainnet-beta.

**Check config**:
```bash
solana config get
```

**Configure validator** to communicate with a default network. For `Testnet` and `mainnet-beta` endpoints:

```bash
solana config set --url https://api.testnet.solana.com
solana config set --url https://api.mainnet-beta.solana.com

# When running your own node you can set it as --url if needed for queries:
solana config set --url http://localhost:8899
```

- Generate keys (3 keypairs):
```bash
solana-keygen new -o /root/validator-keypair.json

solana-keygen new -o /root/vote-account-keypair.json

solana-keygen new -o /root/authorized-withdrawer-keypair.json
```

- Verify your public key:

```bash
solana-keygen verify <public_key> ASK

- Set validator keypair file:

```bash
solana config set --keypair /root/validator-keypair.json
```
- Create vote account:

```bash
solana create-vote-account <ACCOUNT_KEYPAIR> <IDENTITY_KEYPAIR> <WITHDRAWER_PUBKEY> --commission <PERCENTAGE> --config <FILEPATH>
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

- Identify valdiator's pubkey
```bash
solana-keygen pubkey /home/sol/validator-keypair.json
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

## Stake and validate

- Stake Tokens, which will activate in the next epoch

- Verify the validator is among SOlana validators with command:

```bash
solana validators | grep <pubkey>
```
## State-Sync

Using snapshot finder:

- Mainnet

```bash
mkdir snapshotfinder
cd snapshotfinder
mkdir ledger
sudo chmod 777 -R ./ledger

sudo docker pull c29r3/solana-snapshot-finder:latest
sudo docker run -it --rm -v ./ledger:/solana/snapshot --user $(id -u):$(id -g) c29r3/solana-snapshot-finder:latest --snapshot_path /solana/snapshot
```
