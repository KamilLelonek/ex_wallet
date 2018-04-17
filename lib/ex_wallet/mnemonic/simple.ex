defmodule ExWallet.Mnemonic.Simple do
  alias ExWallet.Mnemonic

  @allowed_lengths Mnemonic.allowed_lengths()

  def generate(entropy_length \\ List.last(@allowed_lengths))

  def generate(entropy_length)
      when not (entropy_length in @allowed_lengths),
      do: {:error, "Entropy length must be one of #{inspect(@allowed_lengths)}"}

  def generate(entropy_length) do
    entropy_length
    |> Mnemonic.random_bytes()
    |> from_entropy()
  end

  def from_entropy(entropy) do
    entropy
    |> Mnemonic.sha256()
    |> checksum(entropy)
    |> append(entropy)
    |> mnemonic()
  end

  defp checksum(sha256, entropy) do
    with size = Mnemonic.checksum_length(entropy),
         <<checksum::bits-size(size), _::bits>> <- sha256,
         do: checksum
  end

  defp append(checksum, entropy), do: <<entropy::bits, checksum::bits>>

  defp mnemonic(entropy) do
    for <<chunk::11 <- entropy>> do
      Enum.at(Mnemonic.words(), chunk)
    end
  end
end
