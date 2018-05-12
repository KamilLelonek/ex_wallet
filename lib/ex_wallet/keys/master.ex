defmodule ExWallet.Seed.Kyes.Master do
  defstruct [:private_key, :chain_code]

  @bitcoin_key "Bitcoin seed"

  def create(seed) do
    seed
    |> Base.decode16!(case: :lower)
    |> hmac_sha512()
    |> new()
  end

  defp hmac_sha512(seed), do: :crypto.hmac(:sha512, @bitcoin_key, seed)

  defp new(<<private_key::binary-32, chain_code::binary-32>>) do
    %__MODULE__{
      chain_code: chain_code,
      private_key: private_key
    }
  end
end
