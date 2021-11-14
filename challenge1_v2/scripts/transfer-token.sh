#!/bin/bash

# arguments:
#   utxo (collateral)
#   utxo (that has tokens)
#   sender wallet address file
#   sender signing key file
#   receiver wallet address file
#   token amount to be transferred

bodyFile=transfer-tx-body.01
outFile=transfer-tx.01
tokenPolicyFile="token-mint-policy.plutus"
tokenPolicyId=$(./policyid.sh $tokenPolicyFile)
# Serialize PrimeNFT to hexadecimal: 5072696d654e4654
# https://www.rapidtables.com/convert/number/ascii-to-hex.html
value="$5 $tokenPolicyId.434552433230"
senderWalletAddr=$(cat $2)
receiverWalletAddr=$(cat $4)

echo "utxo (tokens): $1"
echo "sender addr: $(cat $2)"
echo "receiver addr: $(cat $4)"
echo "tokens amt to be transferred: $5"
echo "val: $value"
echo "signing key file: $3"
echo

echo "querying protocol parameters"
./testnet-query-protocol-parameters.sh

echo

cardano-cli transaction build \
    --alonzo-era \
    --testnet-magic 1097911063 \
    --tx-in $1 \
    --tx-out $receiverWalletAddr+1344798+"$value" \
    --tx-out $senderWalletAddr+1344798+"2 $tokenPolicyId.434552433230" \
    --change-address $senderWalletAddr \
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