#!/bin/bash
#
# Query UTxOs from:
#
# account addresses
# CNFTValidator.addr
# refscript.addr

cd $(dirname $0) && . tx.env

echo "                           TxHash                                 TxIx        Amount"
echo "--------------------------------------------------------------------------------------"

for account in {0..23}; do
  [ -d $keys/$network/$account ] || break
  echo "Account $account"
  $path/cardano-cli query utxo \
    --address $(cat $keys/$network/$account/payment/payment.addr) \
    --$net | tail -n+3
  echo
  cat $keys/$network/$account/payment/payment.addr
  echo
  echo "PKH $(cat $keys/$network/$account/payment/payment.pkh)"
  echo
done

[[ -f CNFTValidator.plutus ]] || exit

echo "CNFTValidator"
$path/cardano-cli query utxo \
  --address $(cat CNFTValidator.addr) \
  --$net | tail -n+3
echo
cat CNFTValidator.addr
echo
echo

echo "RefScript"
$path/cardano-cli query utxo \
  --address $(cat refscript.addr) \
  --$net | tail -n+3
echo
cat refscript.addr
echo
