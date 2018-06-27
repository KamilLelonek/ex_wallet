defmodule ExWallet.Keys.Master do
  alias ExWallet.Keys.Private

  @bitcoin_key "Bitcoin seed"

  def create(seed, network \\ :main) do
    seed
    |> Base.decode16!(case: :lower)
    |> hmac_sha512()
    |> build(network)
  end

  defp hmac_sha512(seed), do: :crypto.hmac(:sha512, @bitcoin_key, seed)

  defp build(<<private_key::binary-32, chain_code::binary-32>>, network),
    do: Private.new(network, private_key, chain_code)
end
