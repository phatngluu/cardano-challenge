#!/bin/bash

# Arguments
# - path to script file .plutus

cardano-cli transaction policyid \
--script-file $1
