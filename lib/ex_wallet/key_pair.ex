defmodule ExWallet.KeyPair do
  @type_algorithm :ecdh
  @ecdsa_curve :secp256k1

  def generate, do: :crypto.generate_key(@type_algorithm, @ecdsa_curve)

  def to_public_key(private_key) do
    private_key
    |> String.valid?()
    |> maybe_decode(private_key)
    |> generate_key()
  end

  defp maybe_decode(true, private_key), do: Base.decode16!(private_key)
  defp maybe_decode(false, private_key), do: private_key

  defp generate_key(private_key) do
    with {public_key, _private_key} <-
           :crypto.generate_key(@type_algorithm, @ecdsa_curve, private_key),
         do: public_key
  end
end
