#!/bin/bash

# Args
# - Token name
# - IPFS HASH

tokenname=$1
ipfs_hash=$2
metadatafile=metadata/$(echo $tokenname)-meta.json

mkdir -p metadata
rm -f $metadatafile

echo "{" >> $metadatafile
echo "  \"721\": {" >> $metadatafile 
echo "    \"$(cat policy/policyID)\": {" >> $metadatafile 
echo "      \"$(echo $tokenname)\": {" >> $metadatafile
echo "        \"description\": \"Implementation of ERC721\"," >> $metadatafile
echo "        \"name\": \"CERC721\"," >> $metadatafile
echo "        \"id\": \"1\"," >> $metadatafile
echo "        \"image\": \"ipfs://$(echo $ipfs_hash)\"" >> $metadatafile
echo "      }" >> $metadatafile
echo "    }" >> $metadatafile 
echo "  }" >> $metadatafile 
echo "}" >> $metadatafile