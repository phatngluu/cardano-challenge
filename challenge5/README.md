# Challenge description
This is a challenge that extends the original ![Lobster Challenge](https://github.com/input-output-hk/lobster-challenge)

# Build Plutus Haskell code
- Clone plutus repo. Checkout tag: alonzo/rc-2
- Enter Nix shell
- Go to the root folder which contains this readme file: `cabal build`

# Build Plutus Haskell to Plutus Core with parameters
At the root folder:
```bash
# Build `apiLobsterScript` to Plutus Core
# nftSymbol: hexa serialized - 4c6f62737465724e4654 (LobsterNFT)
# counterSymbol: hexa serialized - 4c6f6273746572436f756e746572 (LobsterCounter)
# voteSymbol: hexa serialized - 4c6f6273746572566f746573 (LobsterVotes)
# secret number: number - 1999
# total names: number - 1219
# total votes: number - 500
cabal run plutus-lobster 4c6f62737465724e4654 4c6f6273746572436f756e746572 4c6f6273746572566f746573 1999 1219 500

# Build `apiOtherMintScript` and `apiNFTMintScript` to Plutus Core
# utxo (must has ADA only):
#    14865d34c6141f445dde0965f1ef79b31de2ca4e909d289792c8051357ff5ffa#0 (payment4.addr)
cabal run plutus-lobster-tokens 14865d34c6141f445dde0965f1ef79b31de2ca4e909d289792c8051357ff5ffa#0
```

# Deploy files
```bash
# List all UTXOs
./scripts/testnet-utxo-at.sh ../../common/payment4.addr

./scripts/testnet-script-address.sh ./scripts/lobster.plutus

# Minting NFT
# UTXO that has ADA only
#    14865d34c6141f445dde0965f1ef79b31de2ca4e909d289792c8051357ff5ffa#0 (payment4.addr)
./lobster-mint-nft.sh 14865d34c6141f445dde0965f1ef79b31de2ca4e909d289792c8051357ff5ffa#0 ../../common/payment4.addr ../../common/payment4.skey

# Deploy lobster script
#   utxo (NFT) : 0f08ced0888de4d7c4319096f719eaece0c60203a041ac592ea49dac6fbfc426#1 (payment4.addr)
#   utxo (collateral): 0f08ced0888de4d7c4319096f719eaece0c60203a041ac592ea49dac6fbfc426#0
#   wallet address file: ../../common/payment4.addr
#   signing key file ../../common/payment4.skey
./lobster-deploy.sh 0f08ced0888de4d7c4319096f719eaece0c60203a041ac592ea49dac6fbfc426#1 0f08ced0888de4d7c4319096f719eaece0c60203a041ac592ea49dac6fbfc426#0 ../../common/payment4.addr ../../common/payment4.skey
```

# Contribution (Test functionalities)
```bash
# querying protocol parameters
./testnet-query-protocol-parameters.sh


# arguments:
#   utxo collateral (ADA only)
#       e711d764206221bf338ffff9a414b9425c8eb46bf4d2e54db5ab2ba8d412f64a#0 (payment4)    
#   utxo that contains LobsterNFT
#       e711d764206221bf338ffff9a414b9425c8eb46bf4d2e54db5ab2ba8d412f64a#1 (utxo that contain)
#   wallet address file
#       ../../common/payment4.addr
#   signinig key file
#       ../../common/payment4.skey
#   old counter
#       0
#   new counter
#       2
#   old votes
#       0
#   node socket pat
#       /home/steven/cardano/db/node.socket
./lobster-contribute.sh e711d764206221bf338ffff9a414b9425c8eb46bf4d2e54db5ab2ba8d412f64a#0 e711d764206221bf338ffff9a414b9425c8eb46bf4d2e54db5ab2ba8d412f64a#1 ../../common/payment4.addr ../../common/payment4.skey 0 2 0 /home/steven/cardano/db/node.socket
```

TODO: sửa các file shells scripts/lobster* thành testnet