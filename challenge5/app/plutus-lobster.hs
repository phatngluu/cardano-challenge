import Cardano.Api                         hiding (TxId)
import Data.String                         (IsString (..))
import Ledger.Value                        (AssetClass (..))
import Prelude
import System.Environment                  (getArgs)

import Cardano.PlutusLobster.LobsterScript

main :: IO ()
main = do
    [nftSymbol, counterSymbol, voteSymbol, seed', nameCount', voteCount'] <- getArgs
    let seed      = read seed'
        nft       = AssetClass (fromString nftSymbol,   nftTokenName)
        counter   = AssetClass (fromString counterSymbol, counterTokenName)
        votes     = AssetClass (fromString voteSymbol, votesTokenName)
        nameCount = read nameCount'
        voteCount = read voteCount'
        lp          = LobsterParams
            { lpSeed      = seed
            , lpNFT       = nft
            , lpCounter   = counter
            , lpVotes     = votes
            , lpNameCount = nameCount
            , lpVoteCount = voteCount
            }
        lobsterFile = "scripts/lobster.plutus"
    print lp

    lobsterResult <- writeFileTextEnvelope lobsterFile Nothing $ apiLobsterScript lp
    case lobsterResult of
        Left err -> print $ displayError err
        Right () -> putStrLn $ "wrote lobster script to file " ++ lobsterFile
