module Serialise where

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
import Data.ByteString.Lazy 
         ( toStrict 
         )
import Data.ByteString.Short 
         ( ShortByteString
         , toShort
         )
import Data.Functor
         ( void
         )
import Plutus.V2.Ledger.Api 
         ( ToData
         , toData
         )
import Prelude
         ( (.)
         , FilePath
         , IO
         , Maybe (..)
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
