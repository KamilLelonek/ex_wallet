defmodule ExWallet.Seed.MasterKey do
  alias ExWallet.Base58

  defstruct [:private_key, :chain_code, :serial]

  @bitcoin_key "Bitcoin seed"
  @network_prefixes %{
    main: <<4, 136, 173, 228>>,
    test: <<4, 53, 131, 148>>
  }

  def create(seed, network \\ :main) do
    seed
    |> Base.decode16!(case: :lower)
    |> hmac_sha512()
    |> new(network)
  end

  defp hmac_sha512(seed), do: :crypto.hmac(:sha512, @bitcoin_key, seed)

  defp new(<<private_key::binary-32, chain_code::binary-32>>, network) do
    %__MODULE__{
      chain_code: chain_code,
      private_key: private_key,
      serial: serialize(private_key, chain_code, network)
    }
  end

  defp serialize(private_key, chain_code, network) do
    @network_prefixes
    |> Map.get(network)
    |> prepend_serial(chain_code, private_key)
    |> Base58.check_encode()
  end

  defp prepend_serial(network_prefix, chain_code, private_key),
    do: <<network_prefix::binary, 0::72, chain_code::binary, 0::8, private_key::binary>>
end
