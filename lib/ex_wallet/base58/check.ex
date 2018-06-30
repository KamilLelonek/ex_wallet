defmodule ExWallet.Base58.Check do
  @checksum_length 4

  alias ExWallet.Crypto

  def call(versioned_hash) do
    versioned_hash
    |> Crypto.sha256()
    |> Crypto.sha256()
    |> checksum()
    |> append(versioned_hash)
  end

  defp append(checksum, hash), do: hash <> checksum

  defp checksum(<<checksum::bytes-size(@checksum_length), _::bits>>), do: checksum
end
