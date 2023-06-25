#!/bin/bash
#
# Query local tip data of Cardano node
#
# ctip <mainnet || preprod || preview> 

path="$HOME/.local/bin"

[[ $# = 1 ]] || { echo "ctip.sh <mainnet || preprod || preview>"; exit; }
[[ $1 == "mainnet" ]] && net="mainnet"
[[ $1 == "preprod" ]] && net="testnet-magic 1"
[[ $1 == "preview" ]] && net="testnet-magic 2" || { echo "Network must be either mainnet, preprod or preview"; exit; }

$path/cardano-cli query tip --$net
