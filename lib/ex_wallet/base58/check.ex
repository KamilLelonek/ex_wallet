defmodule ExWallet.Base58.Check do
  @checksum_length 4

  def call(versioned_hash) do
    versioned_hash
    |> sha256()
    |> sha256()
    |> checksum()
    |> append(versioned_hash)
  end

  defp sha256(data), do: :crypto.hash(:sha256, data)

  defp append(checksum, hash), do: hash <> checksum

  defp checksum(<<checksum::bytes-size(@checksum_length), _::bits>>), do: checksum
end
