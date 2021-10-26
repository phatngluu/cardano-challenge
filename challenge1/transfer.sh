#!/bin/bash

# Assign variables from script arguments
ReceiverAddress=$(cat $1)
SenderAddress=$(cat $2)
SenderSigningKeyFile=$3
TxHash=$4
TxIx=$5
Funds=$6
TotalToken=$7
PolicyId=$8
TransferTokenAmount=$9

echo $ReceiverAddress
echo $SenderAddress
echo $SenderSigningKeyFile
echo $TxHash
echo $TxIx
echo $Funds
echo $TotalToken
echo $PolicyId
echo $TransferTokenAmount

RemainingTokenAmount=$(expr $TotalToken - $TransferTokenAmount)
echo $RemainingTokenAmount

MinimumLovelace="10000000"
Remaining=$(expr $Funds - $MinimumLovelace)
echo "Remaining: " $Remaining

cardano-cli transaction build-raw \
--fee 0 \
--tx-in $TxHash#$TxIx \
--tx-out $ReceiverAddress+$MinimumLovelace+"$TransferTokenAmount $PolicyId.CERC20" \
--tx-out $SenderAddress+$Remaining+"$(expr $TotalToken - $TransferTokenAmount) $PolicyId.CERC20" \
--out-file tx/Transfer_Tx.raw

Fee=$(cardano-cli transaction calculate-min-fee --tx-body-file tx/Transfer_Tx.raw --tx-in-count 1 --tx-out-count 2 --witness-count 1 --testnet-magic 1097911063 --protocol-params-file ../common/protocol.json | cut -d " " -f1)

Remaining=$(expr $Funds - $MinimumLovelace - $Fee)
echo "Remaining: " $Remaining

cardano-cli transaction build-raw \
--fee $Fee \
--tx-in $TxHash#$TxIx \
--tx-out $ReceiverAddress+$MinimumLovelace+"$TransferTokenAmount $PolicyId.CERC20" \
--tx-out $SenderAddress+$Remaining+"$(expr $TotalToken - $TransferTokenAmount) $PolicyId.CERC20" \
--out-file tx/Transfer_Tx.raw

cardano-cli transaction sign \
--signing-key-file $SenderSigningKeyFile \
--testnet-magic 1097911063 \
--tx-body-file tx/Transfer_Tx.raw \
--out-file tx/Transfer_Tx.signed

cardano-cli transaction submit --tx-file  tx/Transfer_Tx.signed --testnet-magic 1097911063