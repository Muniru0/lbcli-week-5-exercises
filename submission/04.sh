# Create a CLTV script with a timestamp of 1495584032 and public key below:
# publicKey=02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277


# 1) Parameters
LOCKTIME_DEC=1495584032
PUBKEY="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"

#
# 2) Convert locktime → 8‑hex BE, then to LE
#
LOCKTIME_HEX_BE=$(printf '%08x' "$LOCKTIME_DEC")
# e.g. "5924cd20"
LOCKTIME_HEX_LE=$(echo "$LOCKTIME_HEX_BE" \
  | sed -E 's/([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})/\4\3\2\1/')
# e.g. "20cd2459"

# 3) Compute push‑bytes opcode for locktime (4 bytes → 0x04)
PUSH_LOCKTIME_OP=$(printf '%02x' $(( ${#LOCKTIME_HEX_LE} / 2 )))

#
# 4) Compute PubKeyHash (HASH160 of PubKey)
#
PKH=$(echo -n "$PUBKEY" \
  | xxd -r -p \
  | openssl sha256 -binary \
  | openssl ripemd160 -binary \
  | xxd -p -c 40)
# e.g. "1e51fcdc14be9a148bb0aaec9197eb47c83776fb"

REDEEM_SCRIPT_HEX="${PUSH_LOCKTIME_OP}${LOCKTIME_HEX_LE}b17576a914${PKH}88ac"


echo "$REDEEM_SCRIPT_HEX"
