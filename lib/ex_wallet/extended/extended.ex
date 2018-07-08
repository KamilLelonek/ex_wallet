defmodule ExWallet.Extended do
  alias ExWallet.{Base58, Crypto, Compression}
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

  def serialize(%Public{} = public_key) do
    public_key
    |> Compression.run()
    |> encode_serialize(public_key)
  end

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
