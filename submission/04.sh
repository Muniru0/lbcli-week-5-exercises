# Create a CLTV script with a timestamp of 1495584032 and public key below:
# publicKey=02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277

# 1) Parameters
LOCKTIME_DEC=1495584032
PUBKEY="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"

# 2) Convert decimal locktime to 8‑hex‑digit big‑endian
LOCKTIME_HEX_BE=$(printf "%08x" "$LOCKTIME_DEC")
#    e.g. "5924cd20"

# 3) Reverse bytes to little‑endian
#    Split into byte pairs and reverse order
LOCKTIME_HEX_LE=$(echo "$LOCKTIME_HEX_BE" \
  | sed -E 's/([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})/\4\3\2\1/')
#    e.g. "20cd2459"

# 4) Compute the push‑bytes opcode for the locktime (byte length = 4 → 0x04)
PUSH_LOCKTIME_OP=$(printf "%02x" $(( ${#LOCKTIME_HEX_LE} / 2 )))

# 5) Compute the push‑pubkey opcode (pubkey is 33 bytes → 0x21)
PUSH_PUBKEY_OP=$(printf "%02x" $(( ${#PUBKEY} / 2 )))

# 6) Assemble the redeem script hex:
#    <push-locktime> <locktime-le> OP_CHECKLOCKTIMEVERIFY OP_DROP
#    <push-pubkey> <pubkey> OP_CHECKSIG
REDEEM_SCRIPT_HEX="${PUSH_LOCKTIME_OP}${LOCKTIME_HEX_LE}b175${PUSH_PUBKEY_OP}${PUBKEY}ac"

# 7) Output the result
# echo
# echo "=== CLTV Redeem Script ==="
# echo "Locktime (dec)      : $LOCKTIME_DEC"
# echo "Big‑endian hex      : $LOCKTIME_HEX_BE"
# echo "Little‑endian hex   : $LOCKTIME_HEX_LE"
# echo
# echo "Redeem script (hex):"
# echo "$REDEEM_SCRIPT_HEX"
# echo

# 8) Decode via bitcoin-cli (regtest) for human‑readable
# echo "=== Decoded via decodescript ==="
bitcoin-cli -regtest decodescript "$REDEEM_SCRIPT_HEX"
# echo