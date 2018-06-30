defmodule ExWallet.Extended do
  alias ExWallet.Base58
  alias ExWallet.Extended.Private

  @bitcoin_key "Bitcoin seed"
  @version_numbers %{
    private: %{
      main: <<4, 136, 173, 228>>,
      test: <<4, 53, 131, 148>>
    },
    public: %{
      main: <<4, 136, 178, 30>>,
      test: <<4, 53, 135, 207>>
    }
  }

  def master(seed, network \\ :main) do
    seed
    |> Base.decode16!(case: :lower)
    |> hmac_sha512()
    |> new_private(network)
  end

  defp hmac_sha512(seed), do: :crypto.hmac(:sha512, @bitcoin_key, seed)

  defp new_private(<<private_key::binary-32, chain_code::binary-32>>, network),
    do: Private.new(network, private_key, chain_code)

  def public(public_key, chain_code, network) do
    public_key
    |> compress()
    |> serialize(chain_code, :public, network)
  end

  def private(private_key, chain_code, network) do
    private_key
    |> prepend_index()
    |> serialize(chain_code, :private, network)
  end

  defp compress(<<_prefix::8, x_coordinate::256, y_coordinate::256>>) do
    y_coordinate
    |> rem(2)
    |> compress(x_coordinate)
  end

  defp compress(0, x_coordinate), do: <<0x02::8, x_coordinate::256>>
  defp compress(1, x_coordinate), do: <<0x03::8, x_coordinate::256>>

  defp prepend_index(private_key), do: <<0::8, private_key::binary>>

  defp serialize(key, chain_code, type, network) do
    @version_numbers
    |> Map.get(type)
    |> Map.get(network)
    |> prepend_serial(chain_code, key)
    |> Base58.check_encode()
  end

  defp prepend_serial(version_number, chain_code, key) do
    <<
      version_number::binary,
      # depth
      0::8,
      # fingerprint
      0::32,
      # child number
      0::32,
      chain_code::binary,
      key::binary
    >>
  end
end
