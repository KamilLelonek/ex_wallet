defmodule ExWallet.Mnemonic do
  @words :ex_wallet
         |> :code.priv_dir()
         |> Path.join("words.txt")
         |> File.stream!()
         |> Stream.map(&String.trim/1)
         |> Enum.to_list()

  @allowed_lengths [128, 160, 192, 224, 256]

  @leading_zeros_for_mnemonic 8
  @leading_zeros_of_mnemonic 11
  @regex_chunk_from_entropy Regex.compile!(".{1,#{@leading_zeros_of_mnemonic}}")
  @regex_chunk_to_entropy Regex.compile!(".{1,#{@leading_zeros_for_mnemonic}}")

  def generate(private_key_length \\ List.last(@allowed_lengths))

  def generate(private_key_length)
      when not (private_key_length in @allowed_lengths),
      do: {:error, "Length of private key must be one of #{inspect(@allowed_lengths)}"}

  def generate(private_key_length) do
    private_key_length
    |> random_bytes()
    |> from_private_key()
  end

  def from_private_key(bytes_or_string) do
    bytes_or_string
    |> String.valid?()
    |> normalize(bytes_or_string)
    |> with_checksum()
    |> mnemonic()
  end

  def to_private_key(mnemonic) do
    mnemonic
    |> binary_indicies()
    |> entropy_bits()
    |> encode_private_key()
  end

  defp normalize(true, string), do: Base.decode16!(string, case: :mixed)
  defp normalize(false, bytes), do: bytes

  defp random_bytes(private_key_length) do
    private_key_length
    |> bits_to_bytes()
    |> :crypto.strong_rand_bytes()
  end

  defp bits_to_bytes(bits), do: div(bits, 8)

  defp with_checksum(bytes) do
    bytes
    |> sha256()
    |> to_binary_string()
    |> checksum(bytes)
    |> append_to_binary_string(bytes)
  end

  defp sha256(data), do: :crypto.hash(:sha256, data)

  defp to_binary_string(bytes) do
    bytes
    |> :binary.bin_to_list()
    |> Enum.map(&binary_for_mnemonic/1)
    |> Enum.join()
  end

  defp binary_for_mnemonic(byte), do: to_binary(byte, @leading_zeros_for_mnemonic)

  defp to_binary(byte, leading_zeros) do
    byte
    |> Integer.to_string(2)
    |> String.pad_leading(leading_zeros, "0")
  end

  defp checksum(binary_string, bytes) do
    bytes
    |> checksum_range()
    |> slice(binary_string)
  end

  defp checksum_range(bytes) do
    bytes
    |> checksum()
    |> range()
  end

  defp checksum(entropy_bytes) do
    entropy_bytes
    |> bit_size()
    |> div(32)
  end

  defp range(length), do: Range.new(0, length - 1)

  defp slice(range, binary_string), do: String.slice(binary_string, range)

  defp append_to_binary_string(checksum, bytes), do: to_binary_string(bytes) <> checksum

  defp mnemonic(entropy) do
    @regex_chunk_from_entropy
    |> Regex.scan(entropy)
    |> List.flatten()
    |> Enum.map(&word/1)
    |> Enum.join(" ")
  end

  defp word(binary) do
    binary
    |> String.to_integer(2)
    |> pick_word()
  end

  defp pick_word(index), do: Enum.at(@words, index)

  defp binary_indicies(mnemonic) do
    mnemonic
    |> String.split()
    |> Enum.map(&word_binary_index/1)
    |> Enum.join()
  end

  defp word_binary_index(word) do
    @words
    |> Enum.find_index(&(&1 == word))
    |> binary_of_index()
  end

  defp binary_of_index(index), do: to_binary(index, @leading_zeros_of_mnemonic)

  defp entropy_bits(bits) do
    bits
    |> String.length()
    |> div(33)
    |> Kernel.*(32)
    |> range()
    |> slice(bits)
  end

  defp encode_private_key(entropy_bits) do
    @regex_chunk_to_entropy
    |> Regex.scan(entropy_bits)
    |> List.flatten()
    |> Enum.map(&String.to_integer(&1, 2))
    |> :binary.list_to_bin()
  end
end
