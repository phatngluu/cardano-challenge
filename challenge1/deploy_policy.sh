#!/bin/bash

# Generate policy ID from the policy script
rm -f policy/policyID
cardano-cli transaction policyid --script-file ./policy/policy.script >> policy/policyID

# Assign variables from script arguments
SenderAddress=$(cat $1)
SenderSigningKeyFile=$2
TxHash=$3
TxIx=$4
Funds=$5

# Variables for readability
Testnet="--testnet-magic 1097911063"
TokenName="CERC20"
TokenAmount="10000000" # 10 milions
PolicyId=$(cat policy/policyID)
Fee="0"
Output="0"

# Build transaction - if this failed, please check above variable
cardano-cli transaction build-raw \
--fee $Fee \
--tx-in $TxHash#$TxIx \
--tx-out $SenderAddress+$Output+"$TokenAmount $PolicyId.$TokenName" \
--mint="$TokenAmount $PolicyId.$TokenName" \
--minting-script-file policy/policy.script \
--out-file CERC20_Tx.raw

# Calculate actual fee
Fee=$(cardano-cli transaction calculate-min-fee --tx-body-file CERC20_Tx.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 $Testnet --protocol-params-file ../common/protocol.json | cut -d " " -f1)

# Recalculate output value
Output=$(expr $Funds - $Fee)

# Rebuild transaction with fee
cardano-cli transaction build-raw \
--fee $Fee \
--tx-in $TxHash#$TxIx \
--tx-out $SenderAddress+$Output+"$TokenAmount $PolicyId.$TokenName" \
--mint="$TokenAmount $PolicyId.$TokenName" \
--minting-script-file policy/policy.script \
--out-file CERC20_Tx.raw

# Sign tx
cardano-cli transaction sign  \
--signing-key-file $SenderSigningKeyFile  \
--signing-key-file policy/policy.skey  \
$Testnet --tx-body-file CERC20_Tx.raw  \
--out-file CERC20_Tx.signed

# Submit transaction
cardano-cli transaction submit --tx-file CERC20_Tx.signed $Testnet