#!/bin/bash

# arguments:
#   utxo (wallet)
#   wallet address file
#   signinig key file
#   token amount 

bodyFile=token-mint-tx-body.03
outFile=token-mint-tx.03
mintingPolicyFile="token-mint-policy.plutus"
mintingPolicyId=$(./policyid.sh $mintingPolicyFile)
mintingValue="$4 $mintingPolicyId.434552433230" # CERC20
walletAddr=$(cat $2)

echo "wallet utxo: $1"
echo "walletAddr: $walletAddr"
echo "bodyfile: $bodyFile"
echo "outfile: $outFile"
echo "mintingPolicyfile: $mintingPolicyFile"
echo "mintingPolicyid: $mintingPolicyId"
echo "mintingValue: $mintingValue"
echo

echo "querying protocol parameters"
./testnet-query-protocol-parameters.sh

cardano-cli transaction build \
    --alonzo-era \
    --testnet-magic 1097911063 \
    --tx-in $1 \
    --tx-in-collateral $1 \
    --tx-out "$walletAddr + 5000000 lovelace + $mintingValue" \
    --mint "$mintingValue" \
    --mint-script-file $mintingPolicyFile \
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
