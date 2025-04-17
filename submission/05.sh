# Create a CSV script that would lock funds until one hundred and fifty blocks had passed
# publicKey=02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277


# 1) Parameters
RELATIVE_BLOCKS=150
PUBKEY="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"

# 2) Convert the block count to 4‑digit hex (big‑endian), padded
HEX_BE=$(printf "%04x" "$RELATIVE_BLOCKS")
#    e.g. "0096"

# 3) Convert to little‑endian by swapping byte pairs
HEX_LE=$(echo "$HEX_BE" | sed -E 's/([0-9a-f]{2})([0-9a-f]{2})/\2\1/')
#    e.g. "9600"

# 4) Push‑data opcode for CSV: length of HEX_LE/2 → 2 bytes = 0x02
PUSH_REL_OP=$(printf "%02x" $(( ${#HEX_LE} / 2 )))
#    e.g. "02"

# 5) Compute the public key hash (HASH160 = RIPEMD160(SHA256(pubkey)))
PKH=$(echo -n "$PUBKEY" \
  | xxd -r -p \
  | openssl sha256 -binary \
  | openssl ripemd160 -binary \
  | xxd -p -c 40)

# 6) Assemble the redeem script hex:
#    [push‑rel][rel‑LE] b2 75           ← CSV then DROP
#    76 a9 14 [PKH] 88 ac              ← P2PKH: DUP HASH160 Push20 PKH EQUALVERIFY CHECKSIG
REDEEM_HEX="${PUSH_REL_OP}${HEX_LE}b27576a914${PKH}88ac"

# 7) Output the script hex
echo "$REDEEM_HEX"

