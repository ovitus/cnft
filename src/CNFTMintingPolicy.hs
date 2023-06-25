{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE TemplateHaskell     #-}

module CNFTMintingPolicy where

import Plutus.Script.Utils.Typed
         ( mkUntypedMintingPolicy
         )
import Plutus.Script.Utils.V2.Contexts
         ( TxOutRef (..)
         , txInInfoOutRef  
         , txInfoInputs
         , txInfoMint
         )
import Plutus.V1.Ledger.Value
         ( flattenValue
         )
import Plutus.V2.Ledger.Api
         ( MintingPolicy
         , ScriptContext
         , mkMintingPolicyScript
         , scriptContextTxInfo
         , unsafeFromBuiltinData
         , TxInfo
         )
import PlutusTx 
         ( applyCode
         , compile
         , liftCode
         )
import PlutusTx.Prelude
         ( ($)
         , (&&)
         , (.)
         , (<)
         , (==)
         , (||)
         , Bool (..)
         , all
         , any
         , traceIfFalse
         )

-- Plutus Tx minting policy
{-# INLINABLE cnftMintingPolicy' #-}
cnftMintingPolicy' :: TxOutRef -> () -> ScriptContext -> Bool
cnftMintingPolicy' utxo _ ctx =

  specifiedUTxO && mintedOne || burnedOne

  where

    info :: TxInfo
    info = scriptContextTxInfo ctx

    specifiedUTxO :: Bool
    specifiedUTxO = traceIfFalse "Specified UTxO was not consumed" $ 
      any (\i -> txInInfoOutRef i == utxo) $ txInfoInputs info

    mintedOne :: Bool
    mintedOne = traceIfFalse "Quantity minted was not 1" $ 
      all (\(_, _, val) -> val ==  1) $ flattenValue $ txInfoMint info

    burnedOne :: Bool
    burnedOne = traceIfFalse "Quantity burned was not -1" $  
      all (\(_, _, val) -> val == -1) $ flattenValue $ txInfoMint info

-- Untyped Plutus Core compiler
cnftMintingPolicy :: TxOutRef -> MintingPolicy
cnftMintingPolicy utxo = mkMintingPolicyScript $ $$(compile [|| wrap ||]) `applyCode` liftCode utxo
  where wrap = mkUntypedMintingPolicy . cnftMintingPolicy'
