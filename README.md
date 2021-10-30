# Prerequisites
- `cardano-node` and `cardano-cli` must be installed. Challenge solutions use testnet.
- Prepare an address and get fund for it.

# Fetch the fee tariff
```bash
# Directory `cardano-challenge`
cardano-cli query protocol-parameters \
  --testnet-magic 1097911063 \
  --out-file common/protocol.json
```

# Generate address
- Use `cardano-cli` to create new address. Suppose you're at
```bash
# Directory `cardano-challenge`

# Generate keys for verifying and signing
cardano-cli address key-gen \
--verification-key-file common/payment1.vkey \
--signing-key-file common/payment1.skey

# Create address
cardano-cli address build \
--payment-verification-key-file common/payment1.vkey \
--out-file common/payment1.addr \
--testnet-magic 1097911063
```
- Go get fund at: https://testnets.cardano.org/en/testnets/cardano/tools/faucet/ . Check your fund:
```bash
cardano-cli query utxo --address $(cat common/payment1.addr) --testnet-magic 1097911063

                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
dc6c8f062fa611701f24e890aefa89e096ecffa6ae6230a5135d5db31e14b1d1     0        100000000 lovelace + TxOutDatumHashNone
```
**Note**: Please notice that TxHash. You can jump back to Challenge 1.

# Running Plutus repo
```bash
git clone plutus
cd plutus
git checkout tags/alonzo/rc-2
nix-shell
```

# Install `jq` for Ubuntu
```bash
sudo apt install jq
```