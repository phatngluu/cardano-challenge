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

{-# INLINABLE mkNFTPolicy #-}
mkNFTPolicy :: TokenName -> TxOutRef -> BuiltinData -> ScriptContext -> Bool
mkNFTPolicy tn utxo _ ctx = traceIfFalse "UTxO not consumed"   hasUTxO           &&
                            traceIfFalse "wrong amount minted" checkMintedAmount
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    hasUTxO :: Bool
    hasUTxO = any (\i -> txInInfoOutRef i == utxo) $ txInfoInputs info

    checkMintedAmount :: Bool
    checkMintedAmount = case flattenValue (txInfoMint info) of
        [(_, tn', amt)] -> tn' == tn && amt == 1
        _               -> False

nftTokenName, counterTokenName, votesTokenName :: TokenName
nftTokenName = "PrimeNFT"
counterTokenName = "PrimeCounter"
votesTokenName = "PrimeVotes"

nftPolicy :: TxOutRef -> Scripts.MintingPolicy
nftPolicy utxo = mkMintingPolicyScript $
    $$(PlutusTx.compile [|| \tn utxo' -> Scripts.wrapMintingPolicy $ mkNFTPolicy tn utxo' ||])
    `PlutusTx.applyCode`
     PlutusTx.liftCode nftTokenName
    `PlutusTx.applyCode`
     PlutusTx.liftCode utxo

nftPlutusScript :: TxOutRef -> Script
nftPlutusScript = unMintingPolicyScript . nftPolicy

nftValidator :: TxOutRef -> Validator
nftValidator = Validator . nftPlutusScript

nftScriptAsCbor :: TxOutRef -> LB.ByteString
nftScriptAsCbor = serialise . nftValidator

apiNFTMintScript :: TxOutRef -> PlutusScript PlutusScriptV1
apiNFTMintScript = PlutusScriptSerialised . SBS.toShort . LB.toStrict . nftScriptAsCbor

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