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

  def from_entropy(binary) do
    binary
    |> Mnemonic.maybe_normalize()
    |> append_checksum()
    |> mnemonic()
  end

  def to_entropy(mnemonic) do
    mnemonic
    |> indicies()
    |> bytes()
    |> entropy()
  end

  defp append_checksum(bytes) do
    bytes
    |> checksum()
    |> append(bytes)
  end

  defp checksum(entropy) do
    with size = Mnemonic.checksum_length(entropy),
         sha256 = Mnemonic.sha256(entropy),
         <<checksum::bits-size(size), _::bits>> <- sha256,
         do: checksum
  end

  defp append(checksum, entropy), do: <<entropy::bits, checksum::bits>>

  defp mnemonic(entropy) do
    entropy
    |> chunks()
    |> Enum.join(" ")
  end

  defp chunks(entropy) do
    for <<chunk::11 <- entropy>> do
      Enum.at(Mnemonic.words(), chunk)
    end
  end

  defp indicies(mnemonic) do
    mnemonic
    |> String.split()
    |> Enum.map(&word_index/1)
  end

  defp word_index(word), do: Enum.find_index(Mnemonic.words(), &(&1 == word))

  defp bytes(indicies) do
    for index <- indicies, into: <<>> do
      <<index::11>>
    end
  end

  defp entropy(sha256) do
    with size = entropy_length(sha256),
         <<entropy::bits-size(size), _::bits>> <- sha256,
         do: entropy
  end

  defp entropy_length(hash) do
    hash
    |> bit_size()
    |> Kernel.*(32)
    |> div(33)
  end
end
