#!/bin/bash

# Args:
# - address name

AddressName=$1

cardano-cli address key-gen \
--verification-key-file $AddressName.vkey \
--signing-key-file $AddressName.skey

# Create address
cardano-cli address build \
--payment-verification-key-file $AddressName.vkey \
--out-file $AddressName.addr \
--testnet-magic 1097911063
