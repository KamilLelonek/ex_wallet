defmodule ExWallet.Extended do
  alias ExWallet.{Base58, KeyPair, Crypto}
  alias ExWallet.Extended.{Private, Public}

  def master(seed, network \\ :main) do
    seed
    |> Base.decode16!(case: :lower)
    |> Crypto.hmac_sha512()
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

  def compress(<<_prefix::8, x_coordinate::256, y_coordinate::256>>) do
    y_coordinate
    |> rem(2)
    |> compress(x_coordinate)
  end

  def compress(0, x_coordinate), do: <<0x02::8, x_coordinate::256>>
  def compress(1, x_coordinate), do: <<0x03::8, x_coordinate::256>>

  def fingerprint(%Private{} = key) do
    key
    |> to_public_key()
    |> fingerprint()
  end

  def fingerprint(%Public{key: key}), do: fingerprint(key)

  def fingerprint(pub_key) do
    pub_key
    |> compress()
    |> Crypto.hash_160()
    |> take_fingerprint()
  end

  defp take_fingerprint(<<fingerprint::binary-4, _rest::binary>>),
    do: fingerprint

  defp new_private(<<private_key::binary-32, chain_code::binary-32>>, network),
    do: Private.new(network, private_key, chain_code)

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
