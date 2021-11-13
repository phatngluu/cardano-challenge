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

module Cardano.PlutusLobster.LobsterScript
  ( apiNFTMintScript
  , apiOtherMintScript
  , apiLobsterScript
  , LobsterParams (..)
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
nftTokenName = "LobsterNFT"
counterTokenName = "LobsterCounter"
votesTokenName = "LobsterVotes"

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

apiOtherMintScript :: PlutusScript PlutusScriptV1
apiOtherMintScript = PlutusScriptSerialised $ SBS.toShort $ LB.toStrict otherScriptAsCbor

mkLobsterValidator :: LobsterParams -> BuiltinData -> BuiltinData -> ScriptContext -> Bool
mkLobsterValidator lp _ _ ctx =
    traceIfFalse "NFT missing from input"  (oldNFT   == 1)                &&
    traceIfFalse "NFT missing from output" (newNFT   == 1)                &&
    traceIfFalse "already finished"        (oldVotes <= lpVoteCount lp)   &&
    traceIfFalse "wrong new votes"         (newVotes == oldVotes + 1)     &&
    traceIfFalse "not prime"               (increase `elem` primeNumbers) &&
    if oldVotes < lpVoteCount lp then
        traceIfFalse "counter increase too small" (increase >= 1)                                                        &&
        traceIfFalse "counter increase too large" (increase <= 1000)
    else
        traceIfFalse "wrong counter value"        (newCounter == ((lpSeed lp + oldCounter) `modInteger` lpNameCount lp))
  where
    ownInput :: TxOut
    ownInput = case findOwnInput ctx of
        Nothing -> traceError "lobster input missing"
        Just i  -> txInInfoResolved i

    ownOutput :: TxOut
    ownOutput = case getContinuingOutputs ctx of
        [o] -> o
        _   -> traceError "expected exactly one lobster output"

    inVal, outVal :: Value
    inVal = txOutValue ownInput
    outVal = txOutValue ownOutput

    oldNFT, newNFT, oldCounter, newCounter, increase, oldVotes, newVotes :: Integer
    oldNFT     = assetClassValueOf inVal  $ lpNFT lp
    newNFT     = assetClassValueOf outVal $ lpNFT lp
    oldCounter = assetClassValueOf inVal  $ lpCounter lp
    newCounter = assetClassValueOf outVal $ lpCounter lp
    oldVotes   = assetClassValueOf inVal  $ lpVotes lp
    newVotes   = assetClassValueOf outVal $ lpVotes lp
    increase   = newCounter - oldCounter

    primeNumbers = [2,3,5,7,11,13,17,19,23,29,
                    31,37,41,43,47,53,59,61,67,71,
                    73,79,83,89,97,101,103,107,109,113,
                    127,131,137,139,149,151,157,163,167,173,
                    179,181,191,193,197,199,211,223,227,229,
                    233,239,241,251,257,263,269,271,277,281,
                    283,293,307,311,313,317,331,337,347,349,
                    353,359,367,373,379,383,389,397,401,409,
                    419,421,431,433,439,443,449,457,461,463,
                    467,479,487,491,499,503,509,521,523,541,
                    547,557,563,569,571,577,587,593,599,601,
                    607,613,617,619,631,641,643,647,653,659,
                    661,673,677,683,691,701,709,719,727,733,
                    739,743,751,757,761,769,773,787,797,809,
                    811,821,823,827,829,839,853,857,859,863,
                    877,881,883,887,907,911,919,929,937,941,
                    947,953,967,971,977,983,991,997]

data LobsterNaming
instance Scripts.ValidatorTypes LobsterNaming where
    type instance DatumType LobsterNaming = BuiltinData
    type instance RedeemerType LobsterNaming = BuiltinData

typedLobsterValidator :: LobsterParams -> Scripts.TypedValidator LobsterNaming
typedLobsterValidator lp = Scripts.mkTypedValidator @LobsterNaming
    ($$(PlutusTx.compile [|| mkLobsterValidator ||])
        `PlutusTx.applyCode` PlutusTx.liftCode lp)
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator @BuiltinData @BuiltinData

lobsterValidator :: LobsterParams -> Validator
lobsterValidator = Scripts.validatorScript . typedLobsterValidator

lobsterScript :: LobsterParams -> Plutus.Script
lobsterScript = Ledger.unValidatorScript . lobsterValidator

lobsterScriptAsShortBs :: LobsterParams -> SBS.ShortByteString
lobsterScriptAsShortBs = SBS.toShort . LB.toStrict . serialise . lobsterScript

apiLobsterScript :: LobsterParams -> PlutusScript PlutusScriptV1
apiLobsterScript = PlutusScriptSerialised . lobsterScriptAsShortBs
