#!/bin/bash

# Make new directory to store policy's data
mkdir policy

# Generate verification and signing keys for minting policy
cardano-cli address key-gen \
--verification-key-file policy/policy.vkey \
--signing-key-file policy/policy.skey

# Create empty policy script
touch policy/policy.script

# Generate policy script with contents
echo "{" >> policy/policy.script 
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script 
echo "  \"type\": \"sig\"" >> policy/policy.script 
echo "}" >> policy/policy.script