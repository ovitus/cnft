#!/bin/bash

cd $(dirname $0) && . tx.env

CNFTValidator_utxo=""
acct0_utxo=""
asset_id0=""
refscript_utxo=""

$path/cardano-cli transaction build \
  --babbage-era \
  --$net \
  --tx-in $acct0_utxo \
  --tx-in $CNFTValidator_utxo \
  --spending-tx-in-reference $refscript_utxo \
  --spending-plutus-script-v2 \
  --spending-reference-tx-in-inline-datum-present \
  --spending-reference-tx-in-redeemer-file unit.json \
  --required-signer $acct0_skey \
  --tx-in-collateral $acct0_utxo \
  --tx-out "$acct0_addr + 1 $asset_id0 + 2000000" \
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
