defmodule ExWallet.Seed do
  @rounds_count 2048
  @initial_round_number 1
  @seed_length div(512, 8)

  def generate(mnemonic, passphrase \\ "") do
    passphrase
    |> salt()
    |> pbkdf2(mnemonic)
  end

  defp salt(passphrase), do: "mnemonic" <> passphrase

  defp pbkdf2(salt, mnemonic) do
    with initial_block = initial_round(mnemonic, salt) do
      salt
      |> iterate(mnemonic, @initial_round_number + 1, initial_block, initial_block)
      |> seed()
    end
  end

  defp initial_round(mnemonic, salt),
    do: hmac_sha512(mnemonic, <<salt::binary, @initial_round_number::integer-size(32)>>)

  defp seed(acc) do
    [acc, [acc, []]]
    |> Enum.reverse()
    |> IO.iodata_to_binary()
    |> encode()
  end

  defp encode(<<seed::binary-size(@seed_length), _::binary>>), do: Base.encode16(seed, case: :lower)

  defp iterate(_salt, _mnemonic, round_number, _previous_block, acc)
       when round_number > @rounds_count,
       do: acc

  defp iterate(salt, mnemonic, round_number, previous_block, acc) do
    with next_block = hmac_sha512(mnemonic, previous_block) do
      iterate(salt, mnemonic, round_number + 1, next_block, xor(next_block, acc))
    end
  end

  defp hmac_sha512(key, data), do: :crypto.hmac(:sha512, key, data)

  defp xor(a, b), do: :crypto.exor(a, b)
end
