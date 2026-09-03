#!/bin/bash

# More compatible error handling
set -e  # Exit on error
set -u  # Exit on undefined variable

echo "🔄 Starting Solana validator directory reset..."

# Define directories to process
VALIDATOR_DIRS=(
  "/mnt/bootstrap"
  "/mnt/follower1"
  "/mnt/follower2"
)

# Function to reset directories for a validator
reset_validator_dirs() {
  local base_dir=$1
  echo "🗑️ Resetting directories for $(basename $base_dir)..."

  # Check if directories exist before deleting
  if [ -d "$base_dir/accounts" ] || [ -d "$base_dir/config" ] || [ -d "$base_dir/ledger" ]; then
    echo "   Removing existing directories..."
    sudo rm -rf "$base_dir/accounts" "$base_dir/config" "$base_dir/ledger"
  else
    echo "   No existing directories found."
  fi

  # Create new directory structure
  echo "   Creating new directory structure..."
  mkdir -p "$base_dir/accounts/accounts"
  mkdir -p "$base_dir/config"
  mkdir -p "$base_dir/ledger"

  # Set permissions
  echo "   Setting permissions..."
  chmod -R 755 "$base_dir/accounts"
  chmod -R 755 "$base_dir/config"
  chmod -R 755 "$base_dir/ledger"

  echo "✅ Reset complete for $(basename $base_dir)"
  echo
}

# Process each validator directory
for dir in "${VALIDATOR_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    reset_validator_dirs "$dir"
  else
    echo "⚠️ Directory $dir does not exist, skipping..."
  fi
done

echo "🎉 All validator directories have been reset!"
echo "📁 Directory structure:"
echo "  /validator/accounts/accounts"
echo "  /validator/config"
echo "  /validator/ledger"
echo "  (where validator is bootstrap, follower1, or follower2)"
echo
echo "⚠️ Note: You will need to restart the validator pods to use the new directory structure."
