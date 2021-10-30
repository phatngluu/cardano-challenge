#!/bin/bash

# No args

# Make new directory to store policy's data
rm -f policy/*
mkdir -p policy

# Generate verification and signing keys for minting policy
cardano-cli address key-gen \
--verification-key-file policy/policy.vkey \
--signing-key-file policy/policy.skey

# Create empty policy script
touch policy/policy.script

# Generate policy script with contents
echo "{" >> policy/policy.script
echo "  \"type\": \"all\"," >> policy/policy.script 
echo "  \"scripts\":" >> policy/policy.script 
echo "  [" >> policy/policy.script 
echo "   {" >> policy/policy.script 
echo "     \"type\": \"before\"," >> policy/policy.script 
echo "     \"slot\": $(expr $(cardano-cli query tip --testnet-magic 1097911063 | jq .slot?) + 10000)" >> policy/policy.script
echo "   }," >> policy/policy.script 
echo "   {" >> policy/policy.script
echo "     \"type\": \"sig\"," >> policy/policy.script 
echo "     \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"" >> policy/policy.script 
echo "   }" >> policy/policy.script
echo "  ]" >> policy/policy.script 
echo "}" >> policy/policy.script

# Generate policy ID from the policy script
rm -f policy/policyID
cardano-cli transaction policyid --script-file ./policy/policy.script >> policy/policyID