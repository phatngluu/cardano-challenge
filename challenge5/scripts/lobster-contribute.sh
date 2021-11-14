#!/bin/bash

# arguments:
#   utxo (wallet)
#   utxo (lobster script)
#   wallet address file
#   signinig key file
#   old counter
#   new counter
#   old votes

bodyFile=lobster-tx-body.03
outFile=lobster-tx.03
nftPolicyFile="nft-mint-policy.plutus"
nftPolicyId=$(./policyid.sh $nftPolicyFile)
otherPolicyFile="other-mint-policy.plutus"
otherPolicyId=$(./policyid.sh $otherPolicyFile)
nftValue="1 $nftPolicyId.5072696d654e4654" # PrimeNFT
counterValue="$6 $otherPolicyId.5072696d65436f756e746572" # PrimeCounter
newVotes=$(($7+1))
votesValue="$newVotes $otherPolicyId.5072696d65566f746573" # PrimeVotes
increaseValue="$(($6-$5)) $otherPolicyId.5072696d65436f756e746572 + 1 $otherPolicyId.5072696d65566f746573"
walletAddr=$(cat $3)
scriptFile=lobster.plutus
scriptAddr=$(./testnet-script-address.sh $scriptFile)

echo "wallet utxo: $1"
echo "script utxo: $2"
echo "bodyfile: $bodyFile"
echo "outfile: $outFile"
echo "nftPolicyfile: $nftPolicyFile"
echo "nftPolicyid: $nftPolicyId"
echo "otherPolicyfile: $otherPolicyFile"
echo "otherPolicyid: $otherPolicyId"
echo "nftValue: $nftValue"
echo "counterValue: $counterValue"
echo "votesValue: $votesValue"
echo "walletAddress: $walletAddr"
echo "scriptFile: $scriptFile"
echo "scriptAddress: $scriptAddr"
echo "signing key file: $4"
echo "old counter: $5"
echo "new counter: $6"
echo "increaseValue: $increaseValue"
echo "old votes: $7"
echo "new votes: $newVotes"
echo

echo "querying protocol parameters"
./testnet-query-protocol-parameters.sh

cardano-cli transaction build \
    --alonzo-era \
    --testnet-magic 1097911063 \
    --tx-in $1 \
    --tx-in $2 \
    --tx-in-script-file $scriptFile \
    --tx-in-datum-value [] \
    --tx-in-redeemer-value [] \
    --tx-in-collateral $1 \
    --tx-out "$scriptAddr + 2034438 lovelace + $nftValue + $counterValue + $votesValue" \
    --tx-out-datum-hash 45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0 \
    --mint "$increaseValue" \
    --mint-script-file $otherPolicyFile \
    --mint-redeemer-value [] \
    --change-address $walletAddr \
    --protocol-params-file testnet-protocol-parameters.json \
    --out-file $bodyFile

# echo "saved transaction to $bodyFile"

# cardano-cli transaction sign \
#     --tx-body-file $bodyFile \
#     --signing-key-file $4 \
#     --testnet-magic 1097911063 \
#     --out-file $outFile

# echo "signed transaction and saved as $outFile"

# cardano-cli transaction submit \
#     --testnet-magic 1097911063 \
#     --tx-file $outFile

# echo "submitted transaction"

# echo
