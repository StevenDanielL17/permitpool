#!/bin/bash
source .env

echo "======================================"
echo "   MEMPOOL STATUS CHECKER"
echo "======================================"
echo ""

EXPECTED_NONCE=182
WAIT_START=$(date +%s)

echo "Start time: $(date)"
echo "Expected clear time: ~15-20 minutes"
echo ""

while true; do
    CURRENT_NONCE=$(cast nonce $OWNER_ADDRESS --rpc-url sepolia 2>/dev/null)
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - WAIT_START))
    ELAPSED_MIN=$((ELAPSED / 60))
    
    echo -ne "\r⏱️  Waiting... ${ELAPSED_MIN} min elapsed | Current nonce: ${CURRENT_NONCE} | Expected: ${EXPECTED_NONCE}+  "
    
    if [ "$CURRENT_NONCE" -gt "$EXPECTED_NONCE" ]; then
        echo ""
        echo ""
        echo "======================================"
        echo "✅ MEMPOOL CLEARED!"
        echo "======================================"
        echo ""
        echo "Nonce moved from $EXPECTED_NONCE to $CURRENT_NONCE"
        echo "The stuck transaction has been processed or dropped."
        echo ""
        echo "🚀 Ready to issue license!"
        echo ""
        echo "Run: ./FINAL_ISSUE_LICENSE.sh"
        echo ""
        exit 0
    fi
    
    sleep 30  # Check every 30 seconds
done
