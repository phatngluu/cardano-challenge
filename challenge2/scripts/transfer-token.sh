#!/bin/bash

# arguments:
#   utxo (that has tokens)
#   sender wallet address file
#   sender signing key file
#   receiver wallet address file

bodyFile=transfer-tx-body.01
outFile=transfer-tx.01
tokenPolicyFile="nft-mint-policy.plutus"
tokenPolicyId=$(./policyid.sh $tokenPolicyFile)
# Serialize SporesNFT_1 to hexadecimal: 53706f7265734e46545f31
# https://www.rapidtables.com/convert/number/ascii-to-hex.html
value="1 $tokenPolicyId.53706f7265734e46545f31"
senderWalletAddr=$(cat $2)
receiverWalletAddr=$(cat $4)

echo "utxo (tokens): $1"
echo "sender addr: $(cat $2)"
echo "receiver addr: $(cat $4)"
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