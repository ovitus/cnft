#!/bin/bash
#
# Create node.socket
# Export CARDANO_NODE_SOCKET_PATH
# Download node configurations
# Run specified node network
#
# run-node.sh <mainnet || preprod || preview>

path="$HOME/.local/bin"

network=$1

[[ $# = 1 ]] || { echo "run-node.sh <mainnet || preprod || preview>"; exit; }
[[ $network == "mainnet" ]] ||
[[ $network == "preprod" ]] ||
[[ $network == "preview" ]] || { echo "Network must be either mainnet, preprod or preview"; exit; }

cd $(dirname $0) && mkdir -p ../assets/run-node && cd ../assets/run-node

[[ -f node.socket ]] || touch node.socket

node_socket="export CARDANO_NODE_SOCKET_PATH='$(pwd)/node.socket'" 
grep "$node_socket" ~/.bashrc 1>/dev/null || { sed -i '/CARDANO_NODE_SOCKET_PATH/d' ~/.bashrc; echo "$node_socket" >> ~/.bashrc; }

if [[ -d $network ]] then cd $network; else
  mkdir $network && cd $network
  for json in config db-sync-config submit-api-config topology byron-genesis shelley-genesis alonzo-genesis conway-genesis; do
    curl -O -J https://book.world.dev.cardano.org/environments/$network/$json.json
  done
fi

$path/cardano-node run \
  --topology topology.json \
  --database-path db \
  --socket-path ../node.socket \
  --port 3001 \
  --config config.json
