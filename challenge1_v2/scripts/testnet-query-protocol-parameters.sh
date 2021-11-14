#!/bin/bash

# Please make sure you have exported your socket path
# It is located in your cardano node source folder at: cardano/db/node.socket
# export CARDANO_NODE_SOCKET_PATH=/home/steven/cardano/db/node.socket
cardano-cli query protocol-parameters \
--testnet-magic 1097911063 \
--out-file "testnet-protocol-parameters.json"