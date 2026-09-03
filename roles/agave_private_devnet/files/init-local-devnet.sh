#!/bin/bash

set -euo pipefail

# Local devnet configuration
GENESIS_CONFIG_DIR="/tmp/genesis-config"
LEDGER_DIR="/ledger"
ACCOUNTS_DIR="/accounts"
CONFIG_DIR="/root/.config/solana"

echo "🚀 Initializing Local Solana Devnet..."

# Create directories
mkdir -p "$GENESIS_CONFIG_DIR"
mkdir -p "$LEDGER_DIR"
mkdir -p "$ACCOUNTS_DIR"
mkdir -p "$CONFIG_DIR"

# Generate all deterministic keys for the cluster
echo "🔑 Using pre-existing keys for the cluster (already copied from secret)..."

# Keys should already be available in CONFIG_DIR (copied by entrypoint script)
# Verify all keys are present
if [ ! -f "$CONFIG_DIR/id.json" ]; then
    echo "❌ Bootstrap identity not found!"
    exit 1
fi

# Get the pubkeys for genesis (bootstrap only)
BOOTSTRAP_IDENTITY=$(solana-keygen pubkey "$CONFIG_DIR/id.json")
BOOTSTRAP_VOTE=$(solana-keygen pubkey "$CONFIG_DIR/vote-account.json")
BOOTSTRAP_STAKE=$(solana-keygen pubkey "$CONFIG_DIR/stake-account.json")
FAUCET_PUBKEY=$(solana-keygen pubkey "$CONFIG_DIR/faucet.json")

# Get current validator info (for logging)
VALIDATOR_IDENTITY=$(solana-keygen pubkey "$CONFIG_DIR/id.json")
VOTE_PUBKEY=$(solana-keygen pubkey "$CONFIG_DIR/vote-account.json")
STAKE_PUBKEY=$(solana-keygen pubkey "$CONFIG_DIR/stake-account.json")

echo "🔑 Bootstrap Identity: $BOOTSTRAP_IDENTITY"
echo "🗳️  Bootstrap Vote: $BOOTSTRAP_VOTE"
echo "🥩 Bootstrap Stake: $BOOTSTRAP_STAKE"
echo " Faucet Pubkey: $FAUCET_PUBKEY"

# Check if genesis has already been created
if [ -f "$LEDGER_DIR/genesis.bin" ]; then
    echo "🔄 Genesis already exists, skipping genesis creation..."
    echo "📋 Using existing genesis at: $LEDGER_DIR/genesis.bin"
else
    # Create a local genesis configuration with bootstrap validator only
    echo "⚙️  Creating genesis configuration with bootstrap validator..."

    # Change to writable directory (ConfigMap mounts are read-only)
    cd "$GENESIS_CONFIG_DIR" || { echo "❌ Failed to change to $GENESIS_CONFIG_DIR directory"; exit 1; }

    echo "⚙️  Downloading core BPF programs..."
    if [ -f "/scripts/fetch-core-bpf.sh" ]; then
      # Source the scripts from /scripts but run in writable directory
      bash /scripts/fetch-core-bpf.sh
      if [[ -r core-bpf-genesis-args.sh ]]; then
        CORE_BPF_GENESIS_ARGS=$(cat core-bpf-genesis-args.sh)
      fi
    else
      echo "❌ fetch-core-bpf.sh not found at /scripts/fetch-core-bpf.sh"
      echo "❌ Cannot proceed without core BPF programs"
      exit 1
    fi

    echo "⚙️  Downloading SPL programs..."
    if [ -f "/scripts/fetch-spl.sh" ]; then
      bash /scripts/fetch-spl.sh
      if [[ -r spl-genesis-args.sh ]]; then
        SPL_GENESIS_ARGS=$(cat spl-genesis-args.sh)
      fi
    else
      echo "❌ fetch-spl.sh not found at /scripts/fetch-spl.sh"
      echo "❌ Cannot proceed without SPL programs"
      exit 1
    fi

    # Run genesis creation from the directory with downloaded programs
    # (solana-genesis needs to find the .so files relative to current directory)
    # Create genesis config - followers will join later
    # Use longer epoch to ensure proper leader schedule generation
    solana-genesis \
        --ledger "$LEDGER_DIR" \
        --faucet-pubkey "$FAUCET_PUBKEY" \
        --faucet-lamports 1000000000000000 \
        --bootstrap-validator "$BOOTSTRAP_IDENTITY" "$BOOTSTRAP_VOTE" "$BOOTSTRAP_STAKE" \
        --bootstrap-validator-lamports 5000000000000 \
        --bootstrap-validator-stake-lamports 5000000000000 \
        --slots-per-epoch 432000 \
        --ticks-per-slot 64 \
        --cluster-type development \
        $CORE_BPF_GENESIS_ARGS \
        $SPL_GENESIS_ARGS

    echo "✅ Genesis configuration created!"
fi

# Set up solana config for local cluster
echo "🔧 Configuring Solana CLI for local cluster..."
solana config set --url http://127.0.0.1:8899
solana config set --keypair "$CONFIG_DIR/id.json"

echo "📁 Configuration summary:"
echo "  - Ledger: $LEDGER_DIR"
echo "  - Accounts: $ACCOUNTS_DIR"
echo "  - Config: $CONFIG_DIR"
echo "  - Validator Identity: $VALIDATOR_IDENTITY"
echo "  - Faucet: $FAUCET_PUBKEY"

echo "🎯 Local devnet initialization complete!"
