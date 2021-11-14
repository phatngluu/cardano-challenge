{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module Cardano.Challenge1
  ( apiNFTMintScript
  , apiMintScript
  , nftTokenName
  , counterTokenName
  , votesTokenName
  ) where

import           Cardano.Api.Shelley      (PlutusScript (..), PlutusScriptV1)
import           Codec.Serialise
import qualified Data.ByteString.Lazy     as LB
import qualified Data.ByteString.Short    as SBS
import           Ledger                   hiding (singleton)
import qualified Ledger.Typed.Scripts     as Scripts
import           Ledger.Value             as Value
import qualified PlutusTx
import           PlutusTx.Builtins        (modInteger)
import           PlutusTx.Prelude         hiding (Semigroup (..), unless)
import qualified Plutus.V1.Ledger.Scripts as Plutus
import           Prelude                  (Show)

data LobsterParams = LobsterParams
    { lpSeed      :: Integer
    , lpNFT       :: AssetClass
    , lpCounter   :: AssetClass
    , lpVotes     :: AssetClass
    , lpNameCount :: Integer
    , lpVoteCount :: Integer
    } deriving Show

PlutusTx.makeLift ''LobsterParams

{- HLINT ignore "Avoid lambda" -}
{-# INLINABLE mkOtherPolicy #-}
mkOtherPolicy :: BuiltinData -> ScriptContext -> Bool
mkOtherPolicy _ _ = True

otherPolicy :: Scripts.MintingPolicy
otherPolicy = mkMintingPolicyScript $$(PlutusTx.compile [|| Scripts.wrapMintingPolicy mkOtherPolicy ||])

otherPlutusScript :: Script
otherPlutusScript = unMintingPolicyScript otherPolicy

otherValidator :: Validator
otherValidator = Validator otherPlutusScript

otherScriptAsCbor :: LB.ByteString
otherScriptAsCbor = serialise otherValidator

apiMintScript :: PlutusScript PlutusScriptV1
apiMintScript = PlutusScriptSerialised $ SBS.toShort $ LB.toStrict otherScriptAsCbor