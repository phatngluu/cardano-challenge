#!/bin/bash

# Arguments
# - sender address file
# - sender signing key file
# - tx hash 
# - tx ix 
# - funds in tx
# - policy script file
# - metadata file
# - slot number (see in policy script file)

# # Assign variables from script arguments
SenderAddress=$(cat $1)
SenderSigningKeyFile=$2
TxHash=$3
TxIx=$4
Funds=$5
PolicyScript=$6
Metadata=$7
SlotNumber=$8

# Variables for readability
Testnet="--testnet-magic 1097911063"
PolicyId=$(cardano-cli transaction policyid --script-file $PolicyScript)
TokenName="TVIV"
Fee="0"
Output="0"
ProtocolFile=../common/protocol.json
TokenAmount="1"
echo "PolicyId $PolicyId"
echo "SenderAddress $SenderAddress"
echo "SenderSigningKeyFile $SenderSigningKeyFile"
echo "TxHash $TxHash"
echo "TxIx $TxIx"
echo "Funds $Funds"
echo "PolicyScript $PolicyScript"
echo "Metadata $Metadata"
echo "SlotNumber $SlotNumber"

mkdir -p tx

cardano-cli transaction build-raw \
--fee $Fee  \
--tx-in $TxHash#$TxIx  \
--tx-out $SenderAddress+$Output+"$TokenAmount $PolicyId.$TokenName" \
--mint="$TokenAmount $PolicyId.$TokenName" \
--minting-script-file $PolicyScript \
--metadata-json-file $Metadata  \
--invalid-hereafter $SlotNumber \
--out-file tx/NFT_Tx.raw

# Calculate actual fee
Fee=$(cardano-cli transaction calculate-min-fee --tx-body-file tx/NFT_Tx.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 $Testnet --protocol-params-file $ProtocolFile | cut -d " " -f1)
echo "Estimated fee: $Fee"

# Recalculate output value
Output=$(expr $Funds - $Fee)
echo "Output: $Output"

# Rebuild transaction with fee
cardano-cli transaction build-raw \
--fee $Fee  \
--tx-in $TxHash#$TxIx  \
--tx-out $SenderAddress+$Output+"$TokenAmount $PolicyId.$TokenName" \
--mint="$TokenAmount $PolicyId.$TokenName" \
--minting-script-file $PolicyScript \
--metadata-json-file $Metadata  \
--invalid-hereafter $SlotNumber \
--out-file tx/NFT_Tx.raw

# Sign tx
cardano-cli transaction sign  \
--signing-key-file $SenderSigningKeyFile  \
--signing-key-file policy/policy.skey  \
$Testnet --tx-body-file tx/NFT_Tx.raw  \
--out-file tx/NFT_Tx.signed

# Submit transaction
cardano-cli transaction submit --tx-file tx/NFT_Tx.signed $Testnet