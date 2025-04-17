# Create a CSV script that would lock funds until one hundred and fifty blocks had passed
# publicKey=02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277


# 1) Parameters
RELATIVE_BLOCKS=150
PUBKEY="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"

# 2) Convert 150 to hex (big‑endian), ensure even length
HEX_BE=$(printf "%x" "$RELATIVE_BLOCKS")
if (( ${#HEX_BE} % 2 )); then
  HEX_BE="0$HEX_BE"
fi
# e.g. "96"

# 3) For numbers ≤ 0x7f, minimal‐push is one byte little‐endian = same two hex chars
HEX_LE="$HEX_BE"
# e.g. "96"

# 4) Compute push‑data opcode for 1 byte → 0x01
PUSH_REL_OP=$(printf "%02x" $(( ${#HEX_LE} / 2 )))

# 5) Compute push‑pubkey opcode for 33 bytes → 0x21
PUSH_PUB_OP=$(printf "%02x" $(( ${#PUBKEY} / 2 )))

# 6) Assemble redeem script hex:
#    [push‑150][150‐LE][OP_CHECKSEQUENCEVERIFY][OP_DROP]
#    [push‑pubkey][pubkey][OP_CHECKSIG]
#
#    OP_CHECKSEQUENCEVERIFY = 0xb2
#    OP_DROP               = 0x75
#    OP_CHECKSIG           = 0xac
REDEEM_HEX="${PUSH_REL_OP}${HEX_LE}b275${PUSH_PUB_OP}${PUBKEY}ac"

# 7) Output results
# echo
# echo "=== CSV Redeem Script ==="
# echo "Relative blocks (dec) : $RELATIVE_BLOCKS"
# echo "Big‑endian hex        : $HEX_BE"
# echo "Little‑endian hex     : $HEX_LE"
# echo
# echo "Redeem script (hex):"
# echo "$REDEEM_HEX"
# echo

# 8) Decode via bitcoin-cli (regtest) for human‑readable form
# echo "=== decodescript output ==="
bitcoin-cli -regtest decodescript "$REDEEM_HEX"
