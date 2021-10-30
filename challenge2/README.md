# Introduction
In this solution, I will show **how ERC721 (NFT) is minted** Cardano.
Functionalities are:
- Token minting
- Transfer token
- Query tokens of an address (natively supported)

Prerequistes as challenge 1.
# Minting policy & deployment
For this solution, we will choose the following constraints to make a token unique:
- There should be only one defined signature allowed to mint (or burn) the NFT.
- The signature will expire in 10000 slots from now to leave the room if we screw something up.
- Each minting policy script is only for one NFT
## Generate minting policy
Suppose you're opening terminal at `challenge2` directory. To generate minting policy script, run:
```bash
# Working directory: challenge2
./gen_policy.sh

# Check outputs
ls policy
# policy.script  policy.skey  policy.vkey policyID
```
Only person who has the `policy.skey` and `policy.vkey` can sign and verify the transaction to mint new tokens. And the minting script will be expired after 1000s. (=> non-fungible assurance).


## Generate NFT metadata
NFT metadata contains information about your NFT. To generate metadata file, run:
```bash
# ./gen_nft_metadata NFT_NAME IPFS_HASH
./gen_nft_metadata.sh TVIV QmNdN48mkK5tn1ZLn268efGywGBHcNzyw47YrDVfFKPfhA

# Check outputs
ls metadata
# TVIV-meta.json
```

## Submiting minting policy
In this step, you need an address that has fund to submit transaction. I have prepare an address `payment4` that has fund to test. Let's query the fund (UTXOs) of this address:

```bash
# Working directory: challenge2
cardano-cli query utxo --address $(cat ../common/payment4.addr) $MAGIC
#                            TxHash                                 TxIx        Amount
# --------------------------------------------------------------------------------------
# 243fbf583475854ebe7d1579c412d99b354c913445ac73804ab3f14584caee75     0        1000000000 lovelace + TxOutDatumHashNone
```

We can move forward to submit the minting policy script by running `deploy_policy.sh`. In terminal run:
```bash
./deploy_policy.sh ../common/payment4.addr ../common/payment4.skey 243fbf583475854ebe7d1579c412d99b354c913445ac73804ab3f14584caee75 0 1000000000 ./policy/policy.script ./metadata/TVIV-meta.json 41234981

# PolicyId d9a46b5f085732000747271d5feb09105e0c506d3f85d25592688994
# SenderAddress addr_test1vqquurd5cglaqfnnusnsfy3w0u6r20hpa4hf9x75evnmhxgwcrdas
# SenderSigningKeyFile ../common/payment4.skey
# TxHash 243fbf583475854ebe7d1579c412d99b354c913445ac73804ab3f14584caee75
# TxIx 0
# Funds 1000000000
# PolicyScript ./policy/policy.script
# Metadata ./metadata/TVIV-meta.json
# SlotNumber 41234981
# Estimated fee: 191681
# Output: 999808319
# Transaction successfully submitted.
```

## Check the minted NFT
```bash
cardano-cli query utxo --address $(cat ../common/payment4.addr) $MAGIC                           TxHash                                 TxIx        Amount--------------------------------------------------------------------------------------
fa9e752f989018915bdf732fc5909190a2fb497c18282bd11cada9b555d7809a     0        999808319 lovelace + 1 d9a46b5f085732000747271d5feb09105e0c506d3f85d25592688994.TVIV + TxOutDatumHashNone
```

# ERC721 verification
# Check with explorer
My deployed minting policy CERC721: [d9a46b5f085732000747271d5feb09105e0c506d3f85d25592688994](https://testnet.cardanoscan.io/tokenPolicy/d9a46b5f085732000747271d5feb09105e0c506d3f85d25592688994)
![](..//img/Screen%20Shot%202021-10-30%20at%2021.45.41.png)


## Token details
Check in explorer: [d9a46b5f085732000747271d5feb09105e0c506d3f85d2559268899454564956](https://testnet.cardanoscan.io/token/d9a46b5f085732000747271d5feb09105e0c506d3f85d2559268899454564956)

![](../img/Screen%20Shot%202021-10-30%20at%2021.42.33.png)

## Balance query
```bash
cardano-cli query utxo --address $(cat ../common/payment4.addr) $MAGIC                           TxHash                                 TxIx        Amount--------------------------------------------------------------------------------------
fa9e752f989018915bdf732fc5909190a2fb497c18282bd11cada9b555d7809a     0        999808319 lovelace + 1 d9a46b5f085732000747271d5feb09105e0c506d3f85d25592688994.TVIV + TxOutDatumHashNone
```

## Token transfer
Transfer as native token. Refer to challenge 1 to see how to transfer NFT token.