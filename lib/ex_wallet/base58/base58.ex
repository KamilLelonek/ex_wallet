defmodule ExWallet.Base58 do
  alias ExWallet.Base58.{Check, Encode}

  def check_encode(input) do
    input
    |> Check.call()
    |> Encode.call()
  end
end
