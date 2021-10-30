# Introduction
In this solution, I will show **how ERC20 is implemented** with Cardano.
Functionalities are:
- Token minting
- Transfer token
- Balance query

Prerequisites:
- `cardano-node` is running and synced with Testnet.
- `cardano-cli` is installed.
- create a new address with `gen_address.sh` and fund it with faucet.

Please note that, I use `cardano-cli` to create and deploy minting policy, create transaction, query balance. Please refer to the [README](../README.md) of the root of this repo to set up the prerequisites.

# Minting policy & deploy to testnet
Minting policy is like a smart contract. It is used to mint or burn tokens.
## Generate minting policy script
Suppose you're opening terminal at `challenge1` directory. To generate to create minting policy script, run:
```bash
# Working directory: challenge1
./gen_policy.sh

# Check outputs
ls policy
# policy.script  policy.skey  policy.vkey
```
Only person who has the `policy.skey` and `policy.vkey` can sign and verify the transaction to mint new tokens.

## Submit minting policy to the network
In this step, you need an address that has fund to submit transaction. I have prepare an address `payment2` that has fund to test. Let's query the fund (UTXOs) of this address:

```bash
# Working directory: challenge1
cardano-cli query utxo --address $(cat ../common/payment2.addr) --testnet-magic 1097911063

# Example result
#                            TxHash                                 TxIx        Amount
# --------------------------------------------------------------------------------------
# c0feddc565e3fe7c9c8b0bcae155e9dc6583fa52577175e340211d7e70ec0956     0        1000000000 lovelace + TxOutDatumHashNone
```

We can move forward to submit the minting policy script by running `deploy_policy.sh`. In terminal run:
```bash
# ./deploy_policy.sh SenderAddress SenderSigningKeyFile TxHash TxIx Amount_lovelace
./deploy_policy.sh "../common/payment2.addr" "../common/payment2.skey" c0feddc565e3fe7c9c8b0bcae155e9dc6583fa52577175e340211d7e70ec0956 0 1000000000
```

## Check the minted assets
```bash
# Check the minted assets
cardano-cli query utxo --address $(cat ../common/payment2.addr) --testnet-magic 1097911063
#                            TxHash                                 TxIx        Amount
# --------------------------------------------------------------------------------------
# 69875830540ee3dff88464cc6fb50d2c3f7b0c235b6366ab10afc121f012fbbc     0        999818307 lovelace + 10000000 885004fc0e0e6f593878fc61a150ab2672cd04270b7218aae5afc9b8.CERC20 + TxOutDatumHashNone
```

# ERC20 verification
## Check with the explorer
My deployed minting policy CERC20: [885004fc0e0e6f593878fc61a150ab2672cd04270b7218aae5afc9b8](https://testnet.cardanoscan.io/tokenPolicy/885004fc0e0e6f593878fc61a150ab2672cd04270b7218aae5afc9b8) (click to view with Cardano blockchain explorer, it's a bit slow).
![](../img/Screen%20Shot%202021-10-24%20at%2000.24.04.png)

## Token details
Check in explorer: 
[885004fc0e0e6f593878fc61a150ab2672cd04270b7218aae5afc9b8434552433230](https://testnet.cardanoscan.io/token/885004fc0e0e6f593878fc61a150ab2672cd04270b7218aae5afc9b8434552433230?address=addr_test1vzdxjtkg5p9wphgnezpjpvdd496p0w7rs5lfhy8atjwh94cf34m4l)
![](../img/Screen%20Shot%202021-10-27%20at%2001.02.40.png)
## Balance query
Check `payment` UTXO:
```bash
cardano-cli query utxo --address $(cat ../common/payment2.addr) --testnet-magic 1097911063
#                            TxHash                                 TxIx        Amount
# --------------------------------------------------------------------------------------
# 4220a8e5b0cef0e9543001cc3f4c5128726d81376a444316d32c27f3aabb8a0c     1        989640002 lovelace + 9999999 885004fc0e0e6f593878fc61a150ab2672cd04270b7218aae5afc9b8.CERC20 + TxOutDatumHashNone
```

## Token transfer
Transfer 10 token CERC20 from `payment2` to `payment1`.
```bash
# ./transfer.sh SenderAddress SenderSigningKeyFile TxHash TxIx Funds TotalToken PolicyId TransferTokenAmount
./transfer.sh "../common/payment1.addr" "../common/payment2.addr" "../common/payment2.skey" 4220a8e5b0cef0e9543001cc3f4c5128726d81376a444316d32c27f3aabb8a0c 1 989640002 9999999 885004fc0e0e6f593878fc61a150ab2672cd04270b7218aae5afc9b8 10
```
See the transaction on explorer: https://testnet.cardanoscan.io/transaction/a6142b7ffe0b6e1e54deaa6977dcf3203d1eec2e438676c08eda3e1593cc050a
