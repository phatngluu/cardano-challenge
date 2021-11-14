# Build Plutus Haskell code
- Clone plutus repo. Checkout tag: alonzo/rc-2
- Enter Nix shell
- Go to the root folder which contains this readme file: `cabal build`

# Build Plutus Haskell to Plutus Core with parameters
## Serialized to hexadecimal
https://www.rapidtables.com/convert/number/ascii-to-hex.html
```bash
# CERC20
434552433230
```
# Build .plutus
At the root folder:
```bash
cabal run challenge1
```

# Minting token (test functionalities)
- At `cardano-challenge`, run `NETWORK=testnet docker-compose up` to spin up node and wallet backend API.
- There are two ways to mint a token: cardano-cli or wallet backend API.
## Using CLI (must use when the minting policy has not yet deployed)
```bash
# Find UTXO (that contains ADA only)
./testnet-utxo-at.sh ../../common/payment4.addr

# Mint token
# Arguments:
#   utxo (wallet)
#   wallet address file
#   signinig key file
#   token amount 
./mint-token.sh \
4ca6ec0b281c19782307cfee3661bf7bc9fb85c3c7827648e99e80011c5ddf61#0 \
../../common/payment4.addr \
../../common/payment4.skey 3
```

# Check ERC20 functionalities
## Balance query
Minted tokens are stored in a UTXO in user wallet address. We can check it by using the shell script:
```bash
./testnet-utxo-at.sh ../../common/payment4.addr
```
Or, using Cardanoscan blockchain explorer: [addr_test1vqquurd5cglaqfnnusnsfy3w0u6r20hpa4hf9x75evnmhxgwcrdas](https://testnet.cardanoscan.io/tokenholdings/addr_test1vqquurd5cglaqfnnusnsfy3w0u6r20hpa4hf9x75evnmhxgwcrdas)
![](../../cardano-challenge/img/Screen%20Shot%202021-11-14%20at%2012.43.42.png)
## Token details
Token details is shown in Cardanoscan: [fda1b6b487bee2e7f64ecf24d24b1224342484c0195ee1b7b943db50434552433230](https://testnet.cardanoscan.io/token/fda1b6b487bee2e7f64ecf24d24b1224342484c0195ee1b7b943db50434552433230)
![](../../cardano-challenge/img/Screen%20Shot%202021-11-14%20at%2012.47.18.png)
## Token transfer
Transfer 1 tokens CERC20 from `payment4` to `payment1`.
```bash
./transfer-token.sh 0034868a098fe17f59af839df8e03a6e2bec752e210183faaa29d4341f987e0d#1 ../../common/payment4.addr ../../common/payment4.skey ../../common/payment1.addr 1
```
See the transaction on explorer: https://testnet.cardanoscan.io/transaction/72d754e34b70242f266b2e72ec28be8f95037034888d907a7f3a8eec6df4c5d9
![](../../cardano-challenge/img/Screen%20Shot%202021-11-14%20at%2014.00.46.png)