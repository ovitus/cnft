#!/bin/bash

cd $(dirname $0) && . tx.env

acct0_utxo0=""
acct0_utxo1=""
asset_id0=""
asset_id1=""

$path/cardano-cli transaction build \
  --babbage-era \
  --$net \
  --tx-in $acct0_utxo0 \
  --tx-in $acct0_utxo1 \
  --tx-out "$cnftvalidator_addr + 1 $asset_id0 + 2000000" \
  --tx-out-inline-datum-file bicycle-dat.json \
  --tx-out "$cnftvalidator_addr + 1 $asset_id1 + 2000000" \
  --tx-out-inline-datum-file pikachu-dat.json \
  --tx-out "$refscript_addr + 15000000" \
  --tx-out-reference-script-file CNFTValidator.plutus \
  --change-address $acct0_addr \
  --out-file tx.body

[[ $1 == "-dr" ]] && exit

$path/cardano-cli transaction sign \
  --$net \
  --tx-body-file tx.body \
  --signing-key-file $acct0_skey \
  --out-file tx.signed

$path/cardano-cli transaction submit \
  --$net \
  --tx-file tx.signed
