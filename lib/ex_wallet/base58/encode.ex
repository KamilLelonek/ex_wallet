defmodule ExWallet.Base58.Encode do
  @alphabet "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  @length String.length(@alphabet)

  def call(input, acc \\ "")
  def call(0, acc), do: acc

  def call(input, acc)
      when is_binary(input) do
    input
    |> :binary.decode_unsigned()
    |> call(acc)
    |> prepend_zeros(input)
  end

  def call(input, acc) do
    input
    |> div(@length)
    |> call(extended_hash(input, acc))
  end

  defp extended_hash(input, acc) do
    @alphabet
    |> String.at(rem(input, @length))
    |> apend(acc)
  end

  defp prepend_zeros(acc, input) do
    input
    |> encode_zeros()
    |> apend(acc)
  end

  defp encode_zeros(input) do
    input
    |> leading_zeros()
    |> duplicate_zeros()
  end

  defp leading_zeros(input) do
    input
    |> :binary.bin_to_list()
    |> Enum.find_index(&(&1 != 0))
  end

  defp duplicate_zeros(count) do
    @alphabet
    |> String.first()
    |> String.duplicate(count)
  end

  defp apend(prefix, postfix), do: prefix <> postfix
end
