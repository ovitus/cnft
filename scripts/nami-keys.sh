#!/bin/bash
#
# Derive Nami account keys from a 24-word seed phrase
#
# nami-keys.sh <seed phrase file> <network> <ending # in account range>
#
# Key sets will be created for the accounts in the range, starting at index 0

path="$HOME/.local/bin"

seedphrase=$1
network=$2
account=$3

$path/cardano-cli version 1>/dev/null || exit
$path/cardano-wallet version 1>/dev/null || exit
[[ $# = 3 ]] || { echo "nami-keys.sh <seed phrase file> <network> <ending # in account range>"; exit; }
[[ -f $seedphrase ]] || { echo "Seed phrase file does not exist."; exit; }
[[ $(wc $seedphrase | awk '{print $2}') -eq 24 ]] || { echo "Seed phrase must contain 24 words"; exit; }
[[ $network == "mainnet" ]] && net="mainnet"
[[ $network == "preprod" ]] && net="testnet-magic 1"
[[ $network == "preview" ]] && net="testnet-magic 2" || { echo "Network must be either mainnet, preprod or preview"; exit; }
[ $account -eq $account ] 2>/dev/null || { echo "Ending number of the account range must be an integer"; exit; }

seedphrase=$(realpath $seedphrase)

cd $(dirname $0) && mkdir -p ../assets/nami-keys && cd ../assets/nami-keys

nami_keys=$(pwd)

# private key
cat $seedphrase | $path/cardano-wallet key from-recovery-phrase Shelley > root.prv

for account in $(seq 0 $account); do
  cd $nami_keys && mkdir -p $network/$account/{stake,payment}
  
  $path/cardano-wallet key child 1852H/1815H/$account\H/2/0 < root.prv > $network/$account/stake/stake.prv
  $path/cardano-wallet key child 1852H/1815H/$account\H/0/0 < root.prv > $network/$account/payment/payment.prv
 
  cd $network/$account/stake
  
  # stake keys
  $path/cardano-wallet key public --without-chain-code < stake.prv > stake.pub
  
  $path/cardano-cli key convert-cardano-address-key \
    --shelley-stake-key \
    --signing-key-file stake.prv \
    --out-file stake.skey
  
  $path/cardano-cli key verification-key \
    --signing-key-file stake.skey \
    --verification-key-file stake.vkey
  
  $path/cardano-cli key non-extended-key \
    --extended-verification-key-file stake.vkey \
    --verification-key-file stake.vkey
  
  cd ../payment
  
  # payment keys
  $path/cardano-wallet key public --without-chain-code < payment.prv > payment.pub
  
  $path/cardano-cli key convert-cardano-address-key \
    --shelley-payment-key \
    --signing-key-file payment.prv \
    --out-file payment.skey
  
  $path/cardano-cli key verification-key \
    --signing-key-file payment.skey \
    --verification-key-file payment.vkey
  
  $path/cardano-cli key non-extended-key \
    --extended-verification-key-file payment.vkey \
    --verification-key-file payment.vkey
  
  # payment address
  $path/cardano-cli address build \
    --$net \
    --payment-verification-key-file payment.vkey \
    --stake-verification-key-file ../stake/stake.vkey \
    --out-file payment.addr
  
  # public key hash
  $path/cardano-cli address key-hash  \
    --payment-verification-key-file payment.vkey \
    --out-file payment.pkh
  
  echo "Nami $network keys for account $account created in $(pwd)"
done
