# Challenge description
This is a challenge that extends the original ![Lobster Challenge](https://github.com/input-output-hk/lobster-challenge)

# Build Plutus Haskell code
- Clone plutus repo. Checkout tag: alonzo/rc-2
- Enter Nix shell
- Go to the root folder which contains this readme file: `cabal build`

# Build Plutus Haskell to Plutus Core with parameters
## Serialized to hexadecimal
https://www.rapidtables.com/convert/number/ascii-to-hex.html
```bash
# LobsterPrimeNFT
5072696d654e4654
# LobsterPrimeCounter
5072696d65436f756e746572
# LobsterPrimeVotes
5072696d65566f746573
```

At the root folder:
```bash
# Nix shell at challenge5
# Build `apiLobsterScript` to Plutus Core
# nftSymbol: hexa serialized - 5072696d654e4654 (PrimeNFT)
# counterSymbol: hexa serialized - 5072696d65436f756e746572 (PrimeCounter)
# voteSymbol: hexa serialized - 5072696d65566f746573 (PrimeVotes)
# secret number: number - 582757474857012117487873
# total names: number - 1219
# total votes: number - 500
cabal run plutus-lobster \
5072696d654e4654 \
5072696d65436f756e746572 \
5072696d65566f746573 \
582757474857012117487873 1219 500

# Build `apiOtherMintScript` and `apiNFTMintScript` to Plutus Core
# utxo collateral (must has ADA only), NFT is mint once and utxo is only used one time.
cabal run plutus-lobster-tokens  \
9768394e6055d9ae18dddbb5d0ddc17bec8fb9fef06a6890aa6d4de2cf777b10#0

# Deploy files
# Exit nix shell
cd scripts
# List all UTXOs
./testnet-utxo-at.sh ../../common/payment4.addr

# Minting NFT
# UTXO we used above
#    9768394e6055d9ae18dddbb5d0ddc17bec8fb9fef06a6890aa6d4de2cf777b10#0 (payment4.addr)
./lobster-mint-nft.sh \
9768394e6055d9ae18dddbb5d0ddc17bec8fb9fef06a6890aa6d4de2cf777b10#0 \
../../common/payment4.addr ../../common/payment4.skey

# Deploy lobster script
#   utxo (NFT) : 23b748a6e0fc3f8fd64e3e0094af41bf42b174a7863313576564ae3eccb5da1e#1 (payment4.addr)
#   utxo (collateral): 23b748a6e0fc3f8fd64e3e0094af41bf42b174a7863313576564ae3eccb5da1e#0
#   wallet address file: ../../common/payment4.addr
#   signing key file ../../common/payment4.skey
./lobster-deploy.sh  \
23b748a6e0fc3f8fd64e3e0094af41bf42b174a7863313576564ae3eccb5da1e#1 \
23b748a6e0fc3f8fd64e3e0094af41bf42b174a7863313576564ae3eccb5da1e#0 \
../../common/payment4.addr ../../common/payment4.skey
```

# Contribution (Test functionalities)
```bash
# querying protocol parameters
./testnet-query-protocol-parameters.sh


# arguments:
#   utxo collateral (ADA only)
#       940eeb785519d4add326e259d61d2dacc96420e7ba1daf0503278091a4fa33fa#0 (payment4)    
#   utxo that contains LobsterNFT
#       7d1cc2d524040287d1610a34ad6f46a7b023936881d1f93a4a27cba079b02d34#1 (utxo that contain)
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
./lobster-contribute.sh \
eb7e3c14d2cd4cb9ee27719e815e564c7972a26b2d5c85d304ba8d26835cef82#0 \
7d1cc2d524040287d1610a34ad6f46a7b023936881d1f93a4a27cba079b02d34#1 \
../../common/payment3.addr ../../common/payment3.skey \
0 31 0 /home/steven/cardano/db/node.socket
```