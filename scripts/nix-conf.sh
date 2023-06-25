echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf
echo "substituters  = https://cache.iog.io https://iohk.cachix.org https://cache.nixos.org/" >> /etc/nix/nix.conf
echo "trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" >> /etc/nix/nix.conf
