#!/bin/bash

cd $(dirname $0) && . tx.env

CNFTValidator_utxo=""
acct1_utxo=""
asset_id0=""
refscript_utxo=""

$path/cardano-cli transaction build \
  --babbage-era \
  --$net \
  --tx-in $acct1_utxo \
  --tx-in $CNFTValidator_utxo \
  --spending-tx-in-reference $refscript_utxo \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file unit.json \
  --tx-in-collateral $acct1_utxo \
  --tx-out "$acct0_addr + 200000000" \
  --tx-out "$acct1_addr + 1 $asset_id0 + 2000000" \
  --change-address $acct1_addr \
  --out-file tx.body

[[ $1 == "-dr" ]] && exit

$path/cardano-cli transaction sign \
  --$net \
  --tx-body-file tx.body \
  --signing-key-file $acct1_skey \
  --out-file tx.signed

$path/cardano-cli transaction submit \
  --$net \
  --tx-file tx.signed
