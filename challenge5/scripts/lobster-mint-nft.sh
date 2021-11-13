#!/bin/bash

# arguments:
#   utxo
#   wallet address file
#   signing key file

bodyFile=lobster-tx-body.01
outFile=lobster-tx.01
nftPolicyFile="nft-mint-policy.plutus"
nftPolicyId=$(./policyid.sh $nftPolicyFile)
# Serialize PrimeNFT to hexadecimal: 5072696d654e4654
# https://www.rapidtables.com/convert/number/ascii-to-hex.html
value="1 $nftPolicyId.5072696d654e4654"
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
    --tx-out $walletAddr+1724100+"$value" \
    --tx-out-datum-hash 45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0 \
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