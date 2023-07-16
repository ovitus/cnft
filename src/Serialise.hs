module Serialise where

import CNFTValidator
         ( CNFTDatum (..)
         )
import Cardano.Api 
         ( PlutusScriptV2
         , writeFileJSON
         , writeFileTextEnvelope
         )
import Cardano.Api.Shelley 
         ( PlutusScript (..)
         , fromPlutusData
         , scriptDataToJsonDetailedSchema
         )
import Codec.Serialise
         ( Serialise
         , serialise
         )
import Data.Aeson 
         ( Value
         )
import Data.ByteString
         ( ByteString
         )
import Data.ByteString.Base16
         ( decode
         )
import Data.ByteString.Char8
         ( pack
         )
import Data.ByteString.Lazy 
         ( toStrict 
         )
import Data.ByteString.Short 
         ( toShort
         )
import Data.Functor
         ( void
         )
import Plutus.Script.Utils.V2.Contexts
         ( TxOutRef (..)
         )
import Plutus.V2.Ledger.Api
         ( PubKeyHash (..)
         , ToData
         , TxId (..)
         , toBuiltin
         , toData
         )
import Prelude
         ( ($)
         , (++)
         , (.)
         , (<$>)
         , Bool
         , FilePath
         , IO
         , Integer
         , Maybe (..)
         , String
         , drop
         , either
         , error
         , id
         , read
         , take
         )

-- write serialised Plutus script file
serialisedScript :: Serialise a => a -> PlutusScript PlutusScriptV2
serialisedScript = PlutusScriptSerialised . toShort . toStrict . serialise

writeScriptToFile :: Serialise a => FilePath -> a -> IO ()
writeScriptToFile fp = void . (writeFileTextEnvelope fp Nothing) . serialisedScript

-- write ScriptData to JSON file
dataToJSON :: ToData a => a -> Value
dataToJSON = scriptDataToJsonDetailedSchema . fromPlutusData . toData

writeDataToFile :: ToData a => FilePath -> a -> IO ()
writeDataToFile fp = void . (writeFileJSON fp) . dataToJSON

bytesFromHex :: ByteString -> ByteString
bytesFromHex = either error id . decode

writeDatumFileJSON :: (String, [(String, Integer)], String, Bool) -> IO ()
writeDatumFileJSON (n,s,b,bb) = writeDataToFile ("assets/" ++ n ++ ".json") $ CNFTDatum
  { sellers = (\(string, int) -> (toPKH string, int)) <$> s
  , buyer = toPKH b
  , buyerBool = bb
  }
    where toPKH = PubKeyHash . toBuiltin . bytesFromHex . pack

toTxOutRef :: String -> TxOutRef
toTxOutRef x = 
  TxOutRef { txOutRefId  = TxId . toBuiltin . bytesFromHex . pack . (take 64) $ x
           , txOutRefIdx = read $ drop 65 x :: Integer
           }
