#!/bin/bash
#
# Generate generic account keys
#
# key-gen.sh <network> <ending # in account range>
#
# Key sets will be created for the accounts in the range, starting at index 0

path="$HOME/.local/bin"

network=$1
account=$2

[[ $# != 2 ]] && echo "key-gen.sh <network> <ending # in account range>" && exit
[[ $network == "mainnet" ]] && net="mainnet"
[[ $network == "preprod" ]] && net="testnet-magic 1"
[[ $network == "preview" ]] && net="testnet-magic 2" || (echo "Network must be either mainnet, preprod or preview" && exit)
! [ $account -eq $account ] 2>/dev/null && echo "Ending number of the account range must be an integer" && exit

cd $(dirname $0) && mkdir -p ../assets/generic-keys && cd ../assets/generic-keys

generic_keys=$(pwd)

for account in $(seq 0 $account); do
  cd $generic_keys && mkdir -p $network/$account/{stake,payment}
  
  cd $network/$account/stake
  
  # stake keys
  $path/cardano-cli stake-address key-gen \
    --verification-key-file stake.vkey \
    --signing-key-file stake.skey
  
  cd ../payment

  # payment keys
  $path/cardano-cli address key-gen \
    --verification-key-file payment.vkey \
    --signing-key-file payment.skey
  
  # payment address
  $path/cardano-cli address build \
    --payment-verification-key-file payment.vkey \
    --stake-verification-key-file ../stake/stake.vkey \
    --$net \
    --out-file payment.addr

  # public key hash
  $path/cardano-cli address key-hash  \
    --payment-verification-key-file payment.vkey \
    --out-file payment.pkh
  
  echo "Generic $network keys for account $account created in $(pwd)"
done
