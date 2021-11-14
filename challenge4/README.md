# This challenge is work in progress

Idea:
- A có CERC20
- MP có NFT
- A submit transaction để gửi MP CERC20 và claim NFT về A.
- Plutus script verify: amount of CERC20 có đủ để claim NFT không?
- Lưu CERC20 vào NFT metadata

## Policy để mint CERC20: 1 ADA = 1 CERC20
- Validate số lượng mint bằng cách so sánh input UTXO ADA value và số lượng minting value của Token

## Policy để buy NFT: 1 CERC20 = 1 NFT
- Validate xem có CERC20 nào không?

## Nâng cao: Làm sao để lưu giá trị của NFT?
Giả sử có 1 NFT giá trị là 20 CERC20. Bài toán có thể được giải quyết là bỏ 20 vào datum hash.
Khi mà một người họ submit transaction lên cùng với X tokens CERC20. Mình sẽ mã hoá X tokens thành datum hash và compare nó với datum hash của của NFT.
- Làm sao để lấy được value của UTXO có chứa CERC20?
- Làm sao để hash value đó thành datum?

Docs:
https://marlowe-playground-staging.plutus.aws.iohkdev.io/doc/haddock/plutus-ledger-api/html/Plutus-V1-Ledger-Contexts.html#t:TxInfo
ScriptContext	 
    scriptContextTxInfo :: TxInfo	 
    scriptContextPurpose :: ScriptPurpose

TxInfo	 
    txInfoInputs :: [TxInInfo] Transaction inputs

TxInInfo	 
    txInInfoOutRef :: TxOutRef	 
    txInInfoResolved :: TxOut

TxOut	 
    txOutAddress :: Address	 
    txOutValue :: Value	 
    txOutDatumHash :: Maybe DatumHash