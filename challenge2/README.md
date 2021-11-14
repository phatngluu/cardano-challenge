# Build Plutus Haskell code
- Clone plutus repo. Checkout tag: alonzo/rc-2
- Enter Nix shell
- Go to the root folder which contains this readme file: `cabal build`

# Build Plutus Haskell to Plutus Core with parameters
Cardano uses UTXO model, once the TX is spent, it cannot be reused again. We take an advantage of it to bring NFT to Cardano => Create a minting policy that validates an UTXO is used or not. 
However, because minting policy can only once. For a new token, you have to build minting policy with a new UTXO.
If you want to test this challenge, you have to rename the NFT (SporesNFT_2) in `Challenge2` file and change the corresponding serialized token name (53706f7265734e46545f32).
Let's build the policy for specific UTXO below:
## Choose UTXO
```bash
# First find a collateral (has ADA only) UTXO in your wallet address
./testnet-utxo-at.sh ../../common/payment4.addr
# For example, this UTXO:
#                            TxHash                                 TxIx        Amount
# --------------------------------------------------------------------------------------
# 6a338d95bee82facee9c9eff209deddd8a77f1fa712c3abbd04607ea6eb7792d     0        24829331 lovelace + TxOutDatumNone
```
## Build .plutus
Every .plutus is used only once. If you want to mint another NFT. You have to go to Challenge2.hs to modify token name. It's a drawback at this moment.
At the root folder:
```bash
# Build `apiNFTMintScript` to Plutus Core
cabal run challenge2 557f601df98466bf7fada041543f9c290ee5589cd4d5b0cb4ef0ec8b5932ddd7#0
```

# Minting token (test functionalities)
- At `cardano-challenge`, run `NETWORK=testnet docker-compose up` to spin up node and wallet backend API.
- There are two ways to mint a token: cardano-cli or wallet backend API.
## Using CLI (must use when the minting policy has not yet deployed)
Remember to change token name corresponding to the token name you used in the Challenge2.hs file (token name must be converted to serialized hexadecimal).
```bash
# Minting NFT
#   UTXO we used above
#   wallet addr file
#   signing key file
#   Token name (serialized hexadecimal): https://www.rapidtables.com/convert/number/hex-to-ascii.html
./lobster-mint-nft.sh \
557f601df98466bf7fada041543f9c290ee5589cd4d5b0cb4ef0ec8b5932ddd7#0 \
../../common/payment4.addr ../../common/payment4.skey 53706f7265734e46545f32
```

# Check ERC721 functionalities
## Balance query
Minted tokens are stored in a UTXO in user wallet address. We can check it by using the shell script:
```bash
./testnet-utxo-at.sh ../../common/payment4.addr
#                            TxHash                                 TxIx        Amount
# --------------------------------------------------------------------------------------
# fc5efa5ded05ac3737085c65a205cb39a4ba0bde171c48531b616f04ddfe9180     0        17295437 lovelace + TxOutDatumNone
# fc5efa5ded05ac3737085c65a205cb39a4ba0bde171c48531b616f04ddfe9180     1        5000000 lovelace + 1 9831e529753c5590c0b36bd703bab69370350f2f59ab647cc3a05888.53706f7265734e46545f32 + TxOutDatumNone
```
Or, using Cardanoscan blockchain explorer: [addr_test1vqquurd5cglaqfnnusnsfy3w0u6r20hpa4hf9x75evnmhxgwcrdas](https://testnet.cardanoscan.io/tokenholdings/addr_test1vqquurd5cglaqfnnusnsfy3w0u6r20hpa4hf9x75evnmhxgwcrdas)
![](../../cardano-challenge/img/Screen%20Shot%202021-11-14%20at%2019.08.46.png)
## Token details
Token details is shown in Cardanoscan: [9831e529753c5590c0b36bd703bab69370350f2f59ab647cc3a0588853706f7265734e46545f32](https://testnet.cardanoscan.io/token/9831e529753c5590c0b36bd703bab69370350f2f59ab647cc3a0588853706f7265734e46545f32)
![](../../cardano-challenge/img/Screen%20Shot%202021-11-14%20at%2019.10.00.png)
## Token transfer
Transfer `SporesNFT_2` token from `payment4` to `payment1`.
```bash
./transfer-token.sh fc5efa5ded05ac3737085c65a205cb39a4ba0bde171c48531b616f04ddfe9180#1 ../../common/payment4.addr ../../common/payment4.skey ../../common/payment1.addr 53706f7265734e46545f32
```