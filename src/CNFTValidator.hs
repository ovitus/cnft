{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE TemplateHaskell     #-}

module CNFTValidator where

import Plutus.Script.Utils.Typed
         ( mkUntypedValidator
         )
import Plutus.V1.Ledger.Value
         ( geq
         )
import Plutus.V2.Ledger.Api
         ( PubKeyHash (..)
         , ScriptContext
         , TxInfo
         , Validator
         , adaSymbol
         , adaToken
         , mkValidatorScript
         , scriptContextTxInfo
         , singleton
         )
import Plutus.V2.Ledger.Contexts
         ( txSignedBy
         , valuePaidTo
         )
import PlutusTx 
         ( applyCode
         , compile
         , liftCode
         , unstableMakeIsData
         )
import PlutusTx.Prelude     
         ( ($)
         , (&&)
         , (.)
         , (||)
         , Bool (..)
         , Integer
         , all
         , any
         , fst
         , snd
         , traceIfFalse
         )

data CNFTDatum = CNFTDatum
    { sellers   :: [(PubKeyHash, Integer)]
    , buyer     :: PubKeyHash
    , buyerBool :: Bool
    }

unstableMakeIsData ''CNFTDatum

-- Plutus Tx validator
{-# INLINABLE cnftValidator' #-}
cnftValidator' :: CNFTDatum -> () -> ScriptContext -> Bool
cnftValidator' dat _ ctx = 

  signedBySeller || if specifiedBuyer then signedByBuyer && valuePaid else valuePaid

  where

    info :: TxInfo
    info = scriptContextTxInfo ctx

    valuePaid :: Bool
    valuePaid = traceIfFalse "Insufficient lovelace paid to seller PKH" $
      all (\(pkh, val) -> valuePaidTo info pkh `geq` singleton adaSymbol adaToken val) $ sellers dat

    signedBySeller :: Bool
    signedBySeller = traceIfFalse "Invalid seller signature" $
      any (\(pkh, _) -> txSignedBy info pkh) $ sellers dat

    signedByBuyer :: Bool
    signedByBuyer = traceIfFalse "Invalid buyer signature" $ 
      txSignedBy info $ buyer dat

    specifiedBuyer :: Bool
    specifiedBuyer =  traceIfFalse "No specified buyer" $
      buyerBool dat

-- Untyped Plutus Core compiler
cnftValidator :: Validator
cnftValidator = mkValidatorScript $ $$(compile [|| wrap ||]) 
  where wrap = mkUntypedValidator cnftValidator'
