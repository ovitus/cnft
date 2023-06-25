{-# LANGUAGE OverloadedStrings #-}

module Main where

import CNFTValidator 
         ( cnftValidator
         , CNFTDatum (..)
         )
import CNFTMintingPolicy 
         ( cnftMintingPolicy 
         )
import Plutus.Script.Utils.V2.Contexts 
         ( TxOutRef (..)
         )
import Prelude
         ( ($)
         , Bool (..)
         , IO
         )
import Serialise 
         ( writeDataToFile
         , writeScriptToFile
         )
import System.Directory (createDirectoryIfMissing)

main :: IO ()
main = do
  createDirectoryIfMissing True "assets"
  writeScriptToFile "assets/CNFTValidator.plutus" cnftValidator
  writeDataToFile "assets/unit.json" ()
  writeScriptToFile "assets/CNFTMintingPolicy.plutus" $ cnftMintingPolicy $ TxOutRef
    { txOutRefId  = "2743bf418f2bb194d07281a06017331d8e171cc1eb9222af6460c5a8aa2efe68"
    , txOutRefIdx = 0
    }
  writeDataToFile "assets/bicycle-dat.json" $ CNFTDatum
    { sellers   = [("8712aa3f948afc59295f654f41d9a2ae24e37df0e2a8a2b00321c2a4", 100000000)]
    , buyer     = ""
    , buyerBool = False
    }
  writeDataToFile "assets/pikachu-dat.json" $ CNFTDatum
    { sellers   = [("8712aa3f948afc59295f654f41d9a2ae24e37df0e2a8a2b00321c2a4", 100000000)]
    , buyer     = ""
    , buyerBool = False
    }
