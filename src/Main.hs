module Main where

import CNFTMintingPolicy
         ( cnftMintingPolicy 
         )
import CNFTValidator
         ( cnftValidator
         )
import Prelude
         ( ($)
         , (<$>)
         , Bool (..)
         , IO
         , Integer
         , String
         , mapM_
         , putStrLn
         , read
         , readFile
         )
import Serialise
         ( toTxOutRef
         , writeDataToFile
         , writeDatumFileJSON
         , writeScriptToFile
         )
import System.Directory 
         ( createDirectoryIfMissing
         )
import System.Environment 
         ( getArgs
         )

main :: IO ()
main = do
  args <- getArgs
  case args of
    [utxo, datum] -> do
      createDirectoryIfMissing True "assets"
      datumParsed <- read <$> readFile datum :: IO [(String, [(String, Integer)], String, Bool)]
      mapM_ writeDatumFileJSON datumParsed
      writeDataToFile "assets/unit.json" ()
      writeScriptToFile "assets/CNFTMintingPolicy.plutus" $ cnftMintingPolicy $ toTxOutRef utxo
      writeScriptToFile "assets/CNFTValidator.plutus" cnftValidator
    _ -> putStrLn "cnft <utxo> <datum.hs file>"
