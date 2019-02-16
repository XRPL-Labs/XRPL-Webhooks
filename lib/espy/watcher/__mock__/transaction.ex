defmodule Espy.Watcher.Mock do
 
  def transaction do
    %{
      "engine_result" => "tesSUCCESS",
      "engine_result_code" => 0,
      "engine_result_message" => "The transaction was applied. Only final in a validated ledger.",
      "ledger_hash" => "887EA4DFE99460F5A5A642F45BAEE33A5CE138B67EA69323FF0BC504960CB845",
      "ledger_index" => 45184774,
      "meta" => %{
        "AffectedNodes" => [
          %{
            "ModifiedNode" => %{
              "FinalFields" => %{
                "Account" => "rNEygqkMv4Vnj8M2eWnYT1TDnV1Sc1X5SN",
                "Balance" => "471234064842",
                "Domain" => "6274637475726B2E636F6D",
                "Flags" => 131072,
                "OwnerCount" => 0,
                "Sequence" => 59012
              },
              "LedgerEntryType" => "AccountRoot",
              "LedgerIndex" => "2D559E46C77FAFDE39F992FF332E32A2E34C4AC5320E3ABC3B2C24F5BD8385C7",
              "PreviousFields" => %{
                "Balance" => "471349886438",
                "Sequence" => 59011
              },
              "PreviousTxnID" => "AFCCC8270E6E8F2B49FA3B293158033997CB0919CA31CDADA1A57FBF714A36FF",
              "PreviousTxnLgrSeq" => 45184725
            }
          },
          %{
            "ModifiedNode" => %{
              "FinalFields" => %{
                "Account" => "rP1afBEfikTz7hJh2ExCDni9W4Bx1dUMRk",
                "Balance" => "376699318981",
                "Flags" => 131072,
                "OwnerCount" => 0,
                "Sequence" => 841
              },
              "LedgerEntryType" => "AccountRoot",
              "LedgerIndex" => "628BCCF8592C8C2D861630192D758E712C0DC9B4101F89CE47EC4694B71B1E69",
              "PreviousFields" => %{"Balance" => "376583497695"},
              "PreviousTxnID" => "1C05307E92E841DB3CC13ECCD5354B635E539E2F75297F184B869C9BEB204516",
              "PreviousTxnLgrSeq" => 45184724
            }
          }
          ],
          "TransactionIndex" => 6,
          "TransactionResult" => "tesSUCCESS"
          },
          "status" => "closed",
          "transaction" => %{
            "Account" => "rNEygqkMv4Vnj8M2eWnYT1TDnV1Sc1X5SN",
            "Amount" => "115821286",
            "Destination" => "rP1afBEfikTz7hJh2ExCDni9W4Bx1dUMRk",
            "DestinationTag" => 84201897,
            "Fee" => "310",
            "Flags" => 2147483648,
            "Sequence" => 59011,
            "SigningPubKey" => "02FC56A7601914BC0462E28994EF7F059D5A23AA17705BAD668E3E4EE00450FFB9",
            "TransactionType" => "Payment",
            "TxnSignature" => "3045022100B62D73409E327FB87F4D24A05523A93FA6684A39ACBE92784B16077C0DBBF036022048186886025CA1A50FF84A6CA0B17E19104EB747FFCA7F2D277638E66BB5BE17",
            "date" => 603665393,
            "hash" => "D8C12166A6ECCCE097B059168CF3DE869573D358F65DD6B687365F8CCB439CD6"
          },
          "type" => "transaction",
          "validated" => true
          }
  end

end
