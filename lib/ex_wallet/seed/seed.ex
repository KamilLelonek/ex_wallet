defmodule ExWallet.Seed do
  @rounds_count 2048
  @initial_round_number 1

  def generate(mnemonic, passphrase \\ "") do
    passphrase
    |> salt()
    |> initial_round(mnemonic)
    |> pbkdf2(mnemonic)
    |> encode()
  end

  defp salt(passphrase), do: "mnemonic" <> passphrase

  defp initial_round(salt, mnemonic),
    do: hmac_sha512(mnemonic, <<salt::binary, @initial_round_number::integer-size(32)>>)

  defp pbkdf2(initial_block, mnemonic),
    do: iterate(mnemonic, @initial_round_number + 1, initial_block, initial_block)

  defp iterate(_mnemonic, round_number, _previous_block, result)
       when round_number > @rounds_count,
       do: result

  defp iterate(mnemonic, round_number, previous_block, result) do
    with next_block = hmac_sha512(mnemonic, previous_block),
      do: iterate(mnemonic, round_number + 1, next_block, xor(next_block, result))
  end

  defp hmac_sha512(key, data), do: :crypto.hmac(:sha512, key, data)

  defp xor(a, b), do: :crypto.exor(a, b)

  defp encode(result), do: Base.encode16(result, case: :lower)
end
