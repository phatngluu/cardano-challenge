#!/bin/bash

# Arguments
# - path to the script .plutus

cardano-cli address build \
--payment-script-file $1 \
--testnet-magic 1097911063