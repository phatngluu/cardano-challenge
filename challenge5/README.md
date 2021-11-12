# Challenge description
This is a challenge that extends the original Lobster Challenge: 

# Build Plutus Haskell code
Enter Nix shell
At the root folder: `cabal build`

# Build Plutus Haskell code to .plutus core
At the root folder:
```bash
# Build LobsterVoteCountScript to Plutus Core
# nftSymbol: hexa - FA
# otherSymbol: hexa - FB
# secret number: number - 1999
# total names: number - 1219
# total votes: number - 500
cabal run plutus-lobster FA FB 1999 1219 500

# Build LobsterTokens to PlutusCore
# address 
# utxo: fa9e752f989018915bdf732fc5909190a2fb497c18282bd11cada9b555d7809a#0
cabal run plutus-lobster-tokens fa9e752f989018915bdf732fc5909190a2fb497c18282bd11cada9b555d7809a#0
```

# Scripts file
```bash
./scripts/testnet-utxo-at.sh ~/codekeeper/cardano-challenge/common/payment4.addr

./scripts/testnet-script-address.sh ./scripts/lobster.plutus



```

TODO: sửa các file shells scripts/lobster* thành testnet