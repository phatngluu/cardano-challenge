# Build Plutus Haskell code
- Clone plutus repo. Checkout tag: alonzo/rc-2
- Enter Nix shell
- Go to the root folder which contains this readme file: `cabal build`

# Build Plutus Haskell to Plutus Core with parameters
Cardano uses UTXO model, once the TX is spent, it cannot be reused again. We take an advantage of it to bring NFT to Cardano => Create a minting policy that validates an UTXO is used or not. 
However, because minting policy can only once. For a new token, you have to build minting policy with a new UTXO.
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
cabal run challenge2 6a338d95bee82facee9c9eff209deddd8a77f1fa712c3abbd04607ea6eb7792d#0
```

# Minting token (test functionalities)
- At `cardano-challenge`, run `NETWORK=testnet docker-compose up` to spin up node and wallet backend API.
- There are two ways to mint a token: cardano-cli or wallet backend API.
## Using CLI (must use when the minting policy has not yet deployed)
Remember to change token name corresponding to the token name you used in the Challenge2.hs file (token name must be converted to serialized hexadecimal).
```bash
# Minting NFT
#   UTXO we used above
#       0034868a098fe17f59af839df8e03a6e2bec752e210183faaa29d4341f987e0d#0 (payment4.addr)
#   Token name (serialized hexadecimal): https://www.rapidtables.com/convert/number/hex-to-ascii.html
./lobster-mint-nft.sh \
6a338d95bee82facee9c9eff209deddd8a77f1fa712c3abbd04607ea6eb7792d#0 \
../../common/payment4.addr ../../common/payment4.skey 53706f7265734e46545f31
```

# Check ERC721 functionalities
## Balance query
Minted tokens are stored in a UTXO in user wallet address. We can check it by using the shell script:
```bash
./testnet-utxo-at.sh ../../common/payment4.addr
# --------------------------------------------------------------------------------------
# 6a338d95bee82facee9c9eff209deddd8a77f1fa712c3abbd04607ea6eb7792d     0        24829331 lovelace + TxOutDatumNone
# 6a338d95bee82facee9c9eff209deddd8a77f1fa712c3abbd04607ea6eb7792d     1        1724100 lovelace + 1 6830f388c7702f0dbcc40b8fc0529395e0796c94043e57afe96b866c.5072696d654e4654 + TxOutDatumHash ScriptDataInAlonzoEra "45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0"
```
Or, using Cardanoscan blockchain explorer: [addr_test1vqquurd5cglaqfnnusnsfy3w0u6r20hpa4hf9x75evnmhxgwcrdas](https://testnet.cardanoscan.io/tokenholdings/addr_test1vqquurd5cglaqfnnusnsfy3w0u6r20hpa4hf9x75evnmhxgwcrdas)
![](../../cardano-challenge/img/Screen%20Shot%202021-11-14%20at%2018.30.21.png)
## Token details
Token details is shown in Cardanoscan: [fc587c0c3ec3fd182fe9639160be979ce2abc76b7d17b2256659715953706f7265734e46545f31](https://testnet.cardanoscan.io/token/fc587c0c3ec3fd182fe9639160be979ce2abc76b7d17b2256659715953706f7265734e46545f31)
![](../../cardano-challenge/img/Screen%20Shot%202021-11-14%20at%2018.32.38.png)
## Token transfer
Transfer 1 tokens CERC20 from `payment4` to `payment1`.
```bash
./transfer-token.sh 557f601df98466bf7fada041543f9c290ee5589cd4d5b0cb4ef0ec8b5932ddd7#1 ../../common/payment4.addr ../../common/payment4.skey ../../common/payment1.addr
```
See the transaction on explorer: https://testnet.cardanoscan.io/transaction/72d754e34b70242f266b2e72ec28be8f95037034888d907a7f3a8eec6df4c5d9
![](../../cardano-challenge/img/Screen%20Shot%202021-11-14%20at%2014.00.46.png)