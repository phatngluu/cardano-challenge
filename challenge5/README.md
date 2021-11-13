# Challenge description
This is a challenge that extends the original ![Lobster Challenge](https://github.com/input-output-hk/lobster-challenge)

# Build Plutus Haskell code
- Clone plutus repo. Checkout tag: alonzo/rc-2
- Enter Nix shell
- Go to the root folder which contains this readme file: `cabal build`

# Build Plutus Haskell code to .plutus core
At the root folder:
```bash
# Build LobsterVoteCountScript to Plutus Core
# nftSymbol: hexa serialized - 4c6f62737465724e4654 (LobsterNFT)
# counterSymbol: hexa serialized - 4c6f6273746572436f756e746572 (LobsterCounter)
# voteSymbol: hexa serialized - 4c6f6273746572566f746573 (LobsterVotes)
# secret number: number - 1999
# total names: number - 1219
# total votes: number - 500
cabal run plutus-lobster 4c6f62737465724e4654 4c6f6273746572436f756e746572 4c6f6273746572566f746573 1999 1219 500

# Build LobsterTokens to PlutusCore
# address payment4.addr
# utxo: fa9e752f989018915bdf732fc5909190a2fb497c18282bd11cada9b555d7809a#0
cabal run plutus-lobster-tokens fa9e752f989018915bdf732fc5909190a2fb497c18282bd11cada9b555d7809a#0
```

# Deploy files
```bash
# List all UTXOs
./scripts/testnet-utxo-at.sh ../../common/payment4.addr

./scripts/testnet-script-address.sh ./scripts/lobster.plutus

# Minting NFT
# UTXO that has ADA only
./lobster-mint-nft.sh fa9e752f989018915bdf732fc5909190a2fb497c18282bd11cada9b555d7809a#0 ../../common/payment4.addr ../../common/payment4.skey


```

TODO: sửa các file shells scripts/lobster* thành testnet