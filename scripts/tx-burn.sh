#!/bin/bash

! [[ $# -eq 0 ]] && [[ $1 != "-dr" ]] && { echo tx-_.sh [-dr: Dry run]; exit; }

cd $(dirname $0) && . tx.env

acct0_utxo=""
acct0_utxo_collat=""
asset_id0=""
asset_ud1=""

$path/cardano-cli transaction build \
  --babbage-era \
  --$net \
  --tx-in $acct0_utxo \
  --tx-in $acct0_utxo_collat \
  --tx-in-collateral $acct0_utxo_collat \
  --change-address $acct0_addr \
  --mint "-1 $asset_id0 + -1 $asset_id1" \
  --mint-script-file CNFTMintingPolicy.plutus \
  --mint-redeemer-file unit.json \
  --out-file tx.body \

[[ $1 == "-dr" ]] && exit

$path/cardano-cli transaction sign \
  --$net \
  --tx-body-file tx.body \
  --signing-key-file $acct0_skey \
  --out-file tx.signed

$path/cardano-cli transaction submit \
  --$net \
  --tx-file tx.signed
