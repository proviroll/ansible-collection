#!/bin/bash

# --- Solana Safe-Window Auditor (Ansible Edition) ---
# Usage: ./check_safe_window.sh <VALIDATOR_IDENTITY> [SOLANA_BIN_PATH]

VALIDATOR_IDENTITY=$1
if [ -z "$VALIDATOR_IDENTITY" ]; then echo "Usage: $0 <VALIDATOR_IDENTITY> [SOLANA_BIN_PATH]"; exit 1; fi
PREFERED_BIN_PATH=$2
MIN_GAP_SIZE=10000  # Minimum slots (~1 hour)
SLOT_DURATION=0.45  # Average Testnet slot time

# 1. Identify the solana binary
if [ -n "$PREFERED_BIN_PATH" ] && [ -x "$PREFERED_BIN_PATH/solana" ]; then
    SOLANA_PATH="$PREFERED_BIN_PATH/solana"
else
    SOLANA_PATH=$(which solana 2>/dev/null)
    if [ -z "$SOLANA_PATH" ]; then
        # Fallback to home search only if absolutely necessary
        SOLANA_PATH=$(find /home -name solana -type f -executable | grep bin/solana | head -n 1)
    fi
fi

if [ -z "$SOLANA_PATH" ]; then
    echo "Error: Solana CLI not found."
    exit 1
fi

# 2. Fetch current network state
CURRENT_SLOT=$($SOLANA_PATH slot --url https://api.testnet.solana.com 2>/dev/null)
if [ -z "$CURRENT_SLOT" ]; then
    echo "Error: Could not connect to Solana Testnet RPC."
    exit 1
fi

ISO_TIME=$($SOLANA_PATH block-time --url https://api.testnet.solana.com $CURRENT_SLOT | grep Date | awk '{print $2}')
ANCHOR_TIME=$(date -d "$ISO_TIME" +%s 2>/dev/null)

if [ -z "$ANCHOR_TIME" ]; then
    echo "Error: Could not synchronize network clock."
    exit 1
fi

# 3. Fetch and process leader schedule
SCHEDULE=$($SOLANA_PATH leader-schedule --url https://api.testnet.solana.com | grep "$VALIDATOR_IDENTITY" | awk '{print $1}')

if [ -z "$SCHEDULE" ]; then
    echo "No leader slots found for identity: $VALIDATOR_IDENTITY"
    exit 0
fi

LAST_SLOT=$CURRENT_SLOT
FOUND_GAP=0

for SLOT in $SCHEDULE; do
    if [ "$SLOT" -le "$CURRENT_SLOT" ]; then
        LAST_SLOT=$((SLOT + 4))
        continue
    fi

    GAP=$((SLOT - LAST_SLOT))
    
    if [ "$GAP" -ge "$MIN_GAP_SIZE" ]; then
        FOUND_GAP=1
        
        # Calculate timestamps
        START_OFFSET=$(echo "($LAST_SLOT - $CURRENT_SLOT) * $SLOT_DURATION" | bc -l | cut -d. -f1)
        END_OFFSET=$(echo "($SLOT - $CURRENT_SLOT) * $SLOT_DURATION" | bc -l | cut -d. -f1)
        
        START_TS=$((ANCHOR_TIME + START_OFFSET))
        END_TS=$((ANCHOR_TIME + END_OFFSET))
        
        START_UTC=$(date -u -d "@$START_TS" +"%Y-%m-%d %H:%M:%S")
        END_UTC=$(date -u -d "@$END_TS" +"%Y-%m-%d %H:%M:%S")
        
        DURATION_MINS=$(( GAP * 45 / 100 / 60 ))
        
        echo "SAFE WINDOW DETECTED:"
        echo "  START: $START_UTC UTC (Slot $LAST_SLOT)"
        echo "  END:   $END_UTC UTC (Slot $SLOT)"
        echo "  GAP:   $DURATION_MINS minutes ($((DURATION_MINS / 60)) hours)"
        echo ""
    fi
    
    LAST_SLOT=$((SLOT + 4))
done

if [ "$FOUND_GAP" -eq 0 ]; then
    echo "CRITICAL: No gaps larger than 1 hour detected in the remaining epoch."
    exit 1
else
    exit 0
fi
