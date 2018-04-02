defmodule ExWallet.Signature do
  @ecdsa_curve :secp256k1
  @type_signature :ecdsa
  @type_hash :sha256

  @spec generate(binary, String.t()) :: String.t()
  def generate(private_key, message),
    do: :crypto.sign(@type_signature, @type_hash, message, [private_key, @ecdsa_curve])

  @spec verify(binary, binary, String.t()) :: boolean
  def verify(public_key, signature, message) do
    :crypto.verify(@type_signature, @type_hash, message, signature, [public_key, @ecdsa_curve])
  end
end
