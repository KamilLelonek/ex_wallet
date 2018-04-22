defmodule ExWallet.Seed do
  @iterations_count 2048
  @initial_index 1
  @seed_length div(512, 8)
  @initial_acc []

  def generate(mnemonic, passphrase \\ "") do
    passphrase
    |> salt()
    |> start(mnemonic)
  end

  defp salt(passphrase), do: "mnemonic" <> passphrase

  defp start(salt, mnemonic) do
    mnemonic
    |> hash(salt)
    |> encode_iterations(salt, mnemonic)
  end

  defp hash(mnemonic, salt),
    do: hmac_sha512(mnemonic, <<salt::binary, @initial_index::integer-size(32)>>)

  defp encode_iterations(initial, salt, mnemonic) do
    salt
    |> iterate(mnemonic, @initial_index + 1, initial, initial)
    |> encode()
  end

  defp encode(acc)
       when not is_list(acc),
       do: encoode([acc, [acc, @initial_acc]])

  defp encoode(acc) do
    acc
    |> Enum.reverse()
    |> IO.iodata_to_binary()
    |> seed()
  end

  defp seed(<<seed::binary-size(@seed_length), _::binary>>), do: Base.encode16(seed, case: :lower)

  defp iterate(_salt, _mnemonic, iteration, _prev, acc)
       when iteration > @iterations_count,
       do: acc

  defp iterate(salt, mnemonic, iteration, prev, acc) do
    mnemonic
    |> hmac_sha512(prev)
    |> do_iterate(salt, mnemonic, iteration, acc)
  end

  defp do_iterate(next, salt, mnemonic, iteration, acc),
    do: iterate(salt, mnemonic, iteration + 1, next, xor(next, acc))

  defp hmac_sha512(key, data), do: :crypto.hmac(:sha512, key, data)

  defp xor(a, b), do: :crypto.exor(a, b)
end
