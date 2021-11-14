#!/bin/bash

# arguments:
#   utxo
#   wallet address file
#   signing key file
#   serialized hexadecimal token name

bodyFile=lobster-tx-body.01
outFile=lobster-tx.01
nftPolicyFile="nft-mint-policy.plutus"
nftPolicyId=$(./policyid.sh $nftPolicyFile)
# Serialize to hexadecimal
# https://www.rapidtables.com/convert/number/ascii-to-hex.html
tokenName=$4
# note that value is ONE
value="1 $nftPolicyId.$tokenName"
walletAddr=$(cat $2)

echo "utxo: $1"
echo "bodyFile: $bodyFile"
echo "outFile: $outFile"
echo "nftPolicyFile: $nftPolicyFile"
echo "nftPolicyId: $nftPolicyId"
echo "value: $value"
echo "walletAddress: $walletAddr"
echo "signing key file: $3"
echo

echo "querying protocol parameters"
./testnet-query-protocol-parameters.sh

echo

cardano-cli transaction build \
    --alonzo-era \
    --testnet-magic 1097911063 \
    --tx-in $1 \
    --tx-in-collateral $1 \
    --tx-out $walletAddr+5000000+"$value" \
    --mint "$value" \
    --mint-script-file $nftPolicyFile \
    --mint-redeemer-value [] \
    --change-address $walletAddr \
    --protocol-params-file testnet-protocol-parameters.json \
    --out-file $bodyFile

echo "saved transaction to $bodyFile"

cardano-cli transaction sign \
    --tx-body-file $bodyFile \
    --signing-key-file $3 \
    --testnet-magic 1097911063 \
    --out-file $outFile

echo "signed transaction and saved as $outFile"

cardano-cli transaction submit \
    --testnet-magic 1097911063 \
    --tx-file $outFile

echo "submitted transaction"

echo