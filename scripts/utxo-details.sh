#!/bin/bash
#
# UTxO details as JSON output
#
# utxo-details.sh <utxo>

path="$HOME/.local/bin"

[[ $# != 1 ]] && echo "utxo-details.sh <utxo>" && exit

$path/cardano-cli query utxo \
  --tx-in $1 \
  --testnet-magic 2 \
  --out-file utxo-details.json 

[[ -f utxo-details.json ]] && cat utxo-details.json && rm utxo-details.json
