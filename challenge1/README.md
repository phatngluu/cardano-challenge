# Generate policy script
Suppose you're at `challenge1` directory. Let's execute below commands to create minting policy script:
```bash
mkdir policy

# Generate keys for minting policy
cardano-cli address key-gen \
--verification-key-file policy/policy.vkey \
--signing-key-file policy/policy.skey

# Create empty policy script
touch policy/policy.script && echo "" > policy/policy.script

# Generate policy script with contents
echo "{" >> policy/policy.script 
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script 
echo "  \"type\": \"sig\"" >> policy/policy.script 
echo "}" >> policy/policy.script
```

We now have script that defines the **policy verification key** as a witness to **sign** the minting transaction. Only person who has the `policy.skey` can sign the transaction to mint token.

# Submit minting policy to the network
In this step, you need an address that has fund to submit transaction. Navigate to this repository README to create new address and get your fund.
After you go get your fund in an address, you have this UTXO:
```
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
dc6c8f062fa611701f24e890aefa89e096ecffa6ae6230a5135d5db31e14b1d1     0        100000000 lovelace + TxOutDatumHashNone
```
We can move forward to submit the minting policy script.
```bash
# Generate policy ID from the policy script
cardano-cli transaction policyid --script-file ./policy/policy.script >> policy/policyID

# Variables
Testnet="testnet-magic 1097911063"
TokenName="CERC20"
TokenAmount="10000000" # 10 milions
SenderAddress=$(cat ../common/payment1.addr)
TxHash="dc6c8f062fa611701f24e890aefa89e096ecffa6ae6230a5135d5db31e14b1d1"
TxIx="0"
Funds="100000000"
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

# Calculate fee again
Fee=$(cardano-cli transaction calculate-min-fee --tx-body-file CERC20_Tx.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 --$Testnet --protocol-params-file ../common/protocol.json | cut -d " " -f1)

# Recalculate output
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
--signing-key-file ../common/payment1.skey  \
--signing-key-file policy/policy.skey  \
--$Testnet --tx-body-file CERC20_Tx.raw  \
--out-file CERC20_Tx.signed

# Submit transaction
cardano-cli transaction submit --tx-file CERC20_Tx.signed --$Testnet

# Check the minted assets
cardano-cli query utxo --address $(cat ../common/payment1.addr) --testnet-magic 1097911063
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
6e990787e2404e839b159c8ceacb588c42231c7fbcbaf2374296cf26179e6807     0        99818307 lovelace + 10000000 4fc7e62895d4bab83d87153e5a99c2c77cadd7654ebe4399950019bd.CERC20 + TxOutDatumHashNone
```
Check with the explorer: https://testnet.cardanoscan.io/transaction/6e990787e2404e839b159c8ceacb588c42231c7fbcbaf2374296cf26179e6807?tab=tokenmint

The script policy CERC20: https://testnet.cardanoscan.io/tokenPolicy/4fc7e62895d4bab83d87153e5a99c2c77cadd7654ebe4399950019bd
![img](../img/Screen%20Shot%202021-10-24%20at%2000.24.04.png)