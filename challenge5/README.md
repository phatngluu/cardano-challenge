This challenge is derived from Lobster challenge with a small change: the vote number must be prime and lays between 1 and 10000.
My solution is to modify the LobsterScript.hs, in particular:
- adding a check for prime number: `traceIfFalse "counter increase is not prime" (isPrime increase)     &&`
- increase the higher bound to 10000: `traceIfFalse "counter increase too large" (increase <= 10000)`

mkLobsterValidator should be modified as follows:

```haskell
mkLobsterValidator :: LobsterParams -> BuiltinData -> BuiltinData -> ScriptContext -> Bool
mkLobsterValidator lp _ _ ctx =
    traceIfFalse "NFT missing from input"  (oldNFT   == 1)              &&
    traceIfFalse "NFT missing from output" (newNFT   == 1)              &&
    traceIfFalse "already finished"        (oldVotes <= lpVoteCount lp) &&
    traceIfFalse "wrong new votes"         (newVotes == oldVotes + 1)   &&
    traceIfFalse "counter increase is not prime" (isPrime increase)     &&
    if oldVotes < lpVoteCount lp then
        traceIfFalse "counter increase too small" (increase >= 1)       &&
        traceIfFalse "counter increase too large" (increase <= 10000)
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
```

Unfortunately, I cannot build the repository because version conflict of Plutus. So I cannot build and deploy my changes for this challenge.