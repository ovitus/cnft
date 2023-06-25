# !/bin/bash
#
# Non fungible token information:
#
# asset ID
# unhexed name 
# byte size
# metadata

xxd --version > /dev/null 2>&1 || exit

hd () { head -c -1 $1 | xxd -p | tr -d '\n'; }

cd $(dirname $0) && . tx.env

echo "CurrencySymbol/PolicyID                                  TokenName/AssetName"
echo "--------------------------------------------------------------------------------------"

for ascii in *.ascii; do
  [[ -f $ascii ]] || continue
  echo "$(cat CNFTMintingPolicy.id).$(head -c -1 $ascii | xxd -p | tr -d '\n';)"
  echo "                                                         $(cat $ascii | sed '$! s/$/\\n/' | tr -d '\n')"
  echo "                                                         $(hd $ascii | wc | awk '{print $3/2}') B"
  echo
done

echo "Metadata"
cat metadata.json
