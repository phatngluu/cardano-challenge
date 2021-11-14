import Cardano.Api                         hiding (TxId)
import Data.String                         (IsString (..))
import Ledger
import Ledger.Bytes                        (getLedgerBytes)
import Prelude
import System.Environment                  (getArgs)

import Cardano.Challenge1

main :: IO ()
main = do
    let mintPolicyFile = "scripts/token-mint-policy.plutus"

    otherPolicyResult <- writeFileTextEnvelope mintPolicyFile Nothing apiMintScript
    case otherPolicyResult of
        Left err -> print $ displayError err
        Right () -> putStrLn $ "wrote other policy to file " ++ mintPolicyFile
