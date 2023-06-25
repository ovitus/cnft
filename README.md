
                              .  .  .
                            .  o o o  .
                              o 0 0 o
                           . o 0   0 o .
                              o 0 0 o
                            .  o o o  .
                              .  .  .
                     
                              Cardano
                                NFT

Non-Fungible Tokens are tokens that can only exist once. 
To acheive this requires a minting policy script that can be true for just one transaction.
The idea provided by IOHK is to refer to something unique on the blockchain. 
An Unspent Transaction Output represents the unspent output of a previous transaction that can be used as input for a new transaction. 
Transaction hash and index determine a UTxO. 
Once consumed, it is never seen again in the history of the blockchain. 

Lars Brünjes, director of education at IOG, goes into further depth about it: 

  https://www.youtube.com/watch?v=9kW-z_RuwEY

A diagram showing how I used this idea to create my own minting policy along with a sales contract validator:

         ________________________.________________________
  
      |                                                     |
      |                   Minting Policy                    |
      |                                                     |
      |                                                     |
      |  + TxOutRef parameter:                              |
      |                                                     |
      |    - Transaction hash and index of output           |
      |                                                     |
      |        Uniquely identifies the UTxO                 |
      |                                                     |
      |                                                     |
      |  + Minting conditions:                              |
      |                                                     |
      |    - Consumes a specific TxOutRef argument          |
      |                                                     |
      |        UTxO's uniqueness makes it so the minting    |
      |        transaction can never occur again, creating  |
      |        a non-fungible token                         |
      |                                                     |
      |                         AND                         |
      |                                                     |
      |    - Only one of each TokenName/AssetName is minted |
      |                                                     |
      |        Multiple NFTs can be created with the same   |
      |        CurrencySymbol/PolicyID                      |
      |                                                     |
      |                         OR                          |
      |                                                     |
      |    - Only one of each TokenName/AssetName is burned |
      |                                                     |
      |                                                     |
      |  * ASCII art can be restricted to 32 bytes in       |
      |    order to fit as a TokenName/AssetName onchain    |
      |                                                     |
         _________________________________________________

         ________________________.________________________
  
      |                                                     |
      |              Sales Contract Validator               |
      |                                                     |
      |                                                     |
      |  + CNFTDatum data type fields:                      |
      |      { sellers   :: [(PubKeyHash, Integer)]         |
      |      , buyer     :: PubKeyHash                      |
      |      , buyerBool :: Bool                            |
      |      }                                              |
      |                                                     |
      |    - "sellers" is a list of tuples each containing  |
      |       a PublicKeyHash and a value to be paid in     |
      |       Lovelace                                      |
      |                                                     |
      |         Allows collaborators to be paid any ratio   |
      |         of the total value of an NFT                |
      |                                                     |
      |    - "buyer" is a PublicKeyHash, relevant if        |
      |       "buyerBool" is true                           |
      |                                                     |
      |                                                     |
      |  + Validation conditions:                           |
      |                                                     |
      |    - Transaction is signed by a seller's            |
      |      PublicKeyHash                                  |
      |                                                     |
      |        To retract and delist assets                 |
      |                                                     |
      |                         OR                          |
      |                                                     |
      |    - Buyer is specified, transaction is signed by   |
      |      specified buyer's PublicKeyHash and value is   |
      |      paid to sellers                                |
      |                                                     |
      |        For offers (after relist) or commissioned    |
      |        work                                         | 
      |                         OR                          |
      |                                                     |
      |    - Value is paid to listed sellers                |
      |                                                     |
      |        Must be greater than or equal to specified   |
      |        values                                       |
      |                                                     |
         _________________________________________________ 


Prerequisites:

1.  Clone this repository, it's a cabal project and along with the Plutus Tx code there are a few useful bash scripts provided, mostly wrappers around cardano-cli and cardano-node.
    Three directories in cnft to be aware of:
```    
      src:     Haskell code
      scripts: Bash scripts
      assets:  file output
```
2.  If setting up a virtual machine, provision atleast 50 GB of disk space for everything here.
    My specifications:  
```
      Debian 12
      4 core CPU @ 4.7GHz
      16GB RAM
```
    I suppose more memory might be needed if using mainnet or running a stake pool. I was using the preview testnet, minting NFTs and submitting sales contracts to the blockchain.

3.  Follow this guide to install the latest version of carano-node and cardano-cli:

      https://developers.cardano.org/docs/get-started/installing-cardano-node

    Note that it places the binaries in $HOME/.local/bin, that's also where my scripts look, so keep them there.
    The plutus-apps Nix environment uses older versions so I made my scripts specific rather than use the global commands.

4.  Run the preview testnet node with "run-node.sh preview".

    Open a separate session and query the tip with "ctip.sh preview".
    It will show sync progress and local tip data of the Cardano node.

5.  Install the Nix package manager.
    It will allow the creation of an isolated development environment with all the required Plutus dependencies:

      https://nixos.org/download.html

    Run "nix-conf.sh" to configure IOHK Nix substituters, the remote binary caches.

6.  If using a Nami wallet, we need cardano-wallet to derive the keys.
    Clone the cardano-wallet repository:

      https://github.com/cardano-foundation/cardano-wallet

    Run "nix-build -A cardano-wallet" in the cardano-wallet directory.
    Copy the command result/bin/cardano-wallet to $HOME/.local/bin alongside the other binaries.

7.  Install xxd to do hex dumps on TokenNames/AssetNames.

8.  Clone the plutus-apps repository:

      https://github.com/input-output-hk/plutus-apps

    In the plutus-apps repository directory run "git checkout tags/v1.1.0". I tried using the latest (v1.2.0 at this time) but was receiving errors creating the environment.

    Run "nix-shell" in the plutus-apps directory.
    It will take a while to download and install all the packages from the Nix store.

9.  While in this Nix environment, go back into the cnft directory and we can begin building the Plutus scripts and interacting with the blockchain.

*   I used imagemagick to convert ASCII text to PNG images and gimp to add RGB noise.
    Credit goes to ChatGPT for designing the ASCII art for which I reappropriated as a proof of concept. 
    Although I did find the same artwork of the bike here:

      https://www.asciiart.eu/sports-and-outdoors/cycling


Plutus:

1.  Execute the Plutus Tx program with "cabal run" in the main cnft directory.
    This will compile the logic in CNFTMintingPolicy.hs and CNFTValidator.hs into Untyped Plutus Core and serialize it using CBOR encoding.
    The UPLC code can be interpreted on-chain by the Cardano blockchain.
    It will also create JSON files for the datums and redeemer.

2.  Either generate generic account key sets or derive them from your Nami seed phrase. 
    Example script commands to create preview accounts 0, 1 and 2:

      generic-keys.sh preview 2
      
      nami-keys.sh seedphrase.prv preview 2
      
    Be careful in exposing your Nami recovery phrase and private keys, use appropriate security measures. 
    If testing, it's safer to generate new generic keys.

3.  Load the accounts with ADA from the Testnets faucet:

      https://docs.cardano.org/cardano-testnet/tools/faucet

    There's a rate limit so you you'll need to split the amount between accounts or use a VPN.

4.  Query UTxOs from the Nami/generic accounts, CNFTValidator and reference script addresses with query-utxos.sh.

5.  Use tx-mint.sh as a template for setting up the minting transaction.
    Start by copying a UTxO from account 0 into the variable for tx-in.
    
6.  The same UTxO used for the minting transaction input must be specified as a TxOutRef argument in Main.hs. 
    The Plutus contract will check that this specifc UTxO was consumed in order to validate.

7.  Also in Main.hs is the ability to create JSON files for the datum using the custom data type CNFTDatum.
    In the sales contract validator, the datum specifies the public key hashes of sellers along with a value for each to be paid in Lovelace.
    Other options are available to specify a buyer, refer to the diagram above.

8.  After the changes are made, CNFTMintingPolicy must recompile, execute "cabal run" from the main cnft directory again.

9.  Find the asset IDs with asset-ids.sh and copy whichever ones that'll be minted into tx-mint.sh.
    ASCII art and metadata can be created with tx.env, it's also where many of the variables are sourced.
    Multiple NFTs to be minted with the same CurrencySymbol/PolicyID.

10. Do a dry run of tx-mint.sh with the "-dr" option.
    If all goes well, sign and submit the transaction.

11. To put the NFTs for sale, use tx-sell.sh.
    It will create a reference script of the sales contract on a locked address.
    Note the datums being made inline, which were the ones created from Main.hs.
    Because these are placed onchain, the buyer doesn't need to provide either a script or datum file and reduces their purchase transaction fees.
    Copy the UTxO with the NFTs and asset IDs from account 0 into the appropriate variables.
    Also provide another UTxO from account 0 with additional ADA to pay for the fees of this transaction.
    Do a dry run and then sign and submit.

12. To purchase the NFT, use tx-buy.
    The transaction will need to follow the logic defined by the sales contract validator and the datum it references.
    So if it requires payment to multiple public key hashes, the transaction output will need to reflect that.
    If a specific buyer is required, the buyer will need to provide their signing key, this type of transaction is exemplified in tx-commissioned-collab.sh.

*   The ASCII text I've used are all close to 32 bytes, which is the maximum size for Cardano TokenNames/AssetNames.
    This allows the ASCII art to exist onchain, not just as a pointer to an IPFS file, although I provided an image for that too in the metadata.
    The hexidecimal representing the tokenname can be reversed back to text:
```    
    echo 42696379636c650a2020205f5f6f0a205f205c3c5f0a285f292f285f29 | xxd -r -p
    Bicycle
       __o
     _ \<_
    (_)/(_)
    
    echo 50696b616368750a285c5f5f2f290a286f5e2e5e290a7a285f282229282229 | xxd -r -p
    Pikachu
    (\__/)
    (o^.^)
    z(_(")(")
```
Here's a video of myself explaining and doing the Plutus transactions, it isn't perfect and somewhat outdated already, but does the job:
https://vimeo.com/838663738


That's it for my demonstration of minting and selling NFTs on the Cardano blockchain.
I appreciate the inherrent immutable nature of this technology and hope for its longevity.
Perhaps it can be the virtual equivalent to carving symbols into stone for posterity to discover and decipher.
With nodes that persist through time and space, providing a resilient time capsule, an archive to our collective culture and ideas.
Well preserved digital footprints for the archaeologists of the future.

Now that I have a process for creating NFTs, I may update this repository with more tokenized art going forward.
I might also eventually look into creating a decentralized application with a GUI frontend or auction validator. 
Thanks to Emurgo for the helpful curriculum, I will consider taking future courses with them.
