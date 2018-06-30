defmodule ExWallet.Extended do
  alias ExWallet.{Base58, KeyPair}
  alias ExWallet.Extended.{Private, Public}

  @bitcoin_key "Bitcoin seed"

  def master(seed, network \\ :main) do
    seed
    |> Base.decode16!(case: :lower)
    |> hmac_sha512()
    |> new_private(network)
  end

  def serialize(%Private{key: key} = private_key) do
    key
    |> prepend_index()
    |> encode_serialize(private_key)
  end

  def serialize(%Public{key: key} = public_key) do
    key
    |> compress()
    |> encode_serialize(public_key)
  end

  def to_public_key(%Private{
        network: network,
        key: key,
        chain_code: chain_code,
        depth: depth,
        fingerprint: fingerprint,
        child_number: child_number
      }) do
    Public.new(
      network,
      KeyPair.to_public_key(key),
      chain_code,
      depth,
      fingerprint,
      child_number
    )
  end

  defp hmac_sha512(seed), do: :crypto.hmac(:sha512, @bitcoin_key, seed)

  defp new_private(<<private_key::binary-32, chain_code::binary-32>>, network),
    do: Private.new(network, private_key, chain_code)

  defp compress(<<_prefix::8, x_coordinate::256, y_coordinate::256>>) do
    y_coordinate
    |> rem(2)
    |> compress(x_coordinate)
  end

  defp compress(0, x_coordinate), do: <<0x02::8, x_coordinate::256>>
  defp compress(1, x_coordinate), do: <<0x03::8, x_coordinate::256>>

  defp prepend_index(private_key), do: <<0::8, private_key::binary>>

  defp encode_serialize(transformed_key, key) do
    transformed_key
    |> prepend_serial(key)
    |> Base58.check_encode()
  end

  defp prepend_serial(
         transformed_key,
         %{
           version_number: version_number,
           depth: depth,
           fingerprint: fingerprint,
           child_number: child_number,
           chain_code: chain_code
         }
       ) do
    <<
      version_number::binary,
      depth::8,
      fingerprint::binary,
      child_number::32,
      chain_code::binary,
      transformed_key::binary
    >>
  end
end
