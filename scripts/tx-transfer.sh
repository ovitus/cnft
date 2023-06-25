#!/bin/bash

cd $(dirname $0) && . tx.env

acct0_utxo=""

$path/cardano-cli transaction build \
  --babbage-era \
  --$net \
  --tx-in $acct0_utxo \
  --tx-out "$acct1_addr + 1500000000" \
  --change-address $acct2_addr \
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
