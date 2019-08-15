defmodule ExWallet.Extended.Children do
  alias ExWallet.{Crypto, Compression, Fingerprint}
  alias ExWallet.Extended.{Private, Public, Pathlist}

  @curve_order 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
  @mersenne_prime 2_147_483_647
  @total_bytes 32

  defguardp hardened?(index) when index > @mersenne_prime
  defguardp normal?(index) when index > -1 and index <= @mersenne_prime

  def derive(key, path) do
    with {kind, pathlist} <- Pathlist.to_list(path),
         do: derive_pathlist(key, pathlist, kind)
  end

  defp derive_pathlist(%Public{} = key, [], :public), do: key
  defp derive_pathlist(%Private{} = key, [], :private), do: key
  defp derive_pathlist(%Private{} = key, [], :public), do: Private.to_public(key)

  defp derive_pathlist(%Public{}, [], :private),
    do: raise("Cannot derive Private Child from a Public Parent!")

  defp derive_pathlist(key, [index | rest], kind) do
    with {public_child_key, child_chain} <- derive_key(key, index) do
      public_child_key
      |> build_child(child_chain, key, index)
      |> derive_pathlist(rest, kind)
    end
  end

  defp derive_key(%Private{chain_code: chain_code} = private_key, index)
       when normal?(index) do
    chain_code
    |> compressed_hmac_sha512(private_key, index)
    |> private_derivation(private_key)
  end

  defp derive_key(%Private{key: key, chain_code: chain_code} = private_key, index)
       when hardened?(index) do
    chain_code
    |> Crypto.hmac_sha512(<<0::8, key::binary, index::32>>)
    |> private_derivation(private_key)
  end

  defp derive_key(%Public{chain_code: chain_code} = public_key, index)
       when normal?(index) do
    chain_code
    |> compressed_hmac_sha512(public_key, index)
    |> elliptic_curve_point_addition(public_key)
  end

  defp derive_key(%Public{}, index)
       when hardened?(index),
       do: raise("Cannot derive Public Hardened Child!")

  defp compressed_hmac_sha512(chain_code, key, index),
    do: Crypto.hmac_sha512(chain_code, <<Compression.run(key)::binary, index::32>>)

  defp private_derivation(
         <<derived_key::256, child_chain::binary>>,
         %Private{key: <<key::256>>}
       ) do
    {private_child_key(derived_key, key), child_chain}
  end

  defp private_child_key(derived_key, key) do
    derived_key
    |> Kernel.+(key)
    |> rem(@curve_order)
    |> :binary.encode_unsigned()
    |> pad_bytes()
  end

  defp pad_bytes(content)
       when byte_size(content) >= @total_bytes,
       do: content

  defp pad_bytes(content) do
    bits = (@total_bytes - byte_size(content)) * 8
    <<0::size(bits)>> <> content
  end

  defp elliptic_curve_point_addition(
         <<derived_key::binary-32, child_chain::binary>>,
         %Public{key: key}
       ) do
    with {:ok, public_child_key} <- :libsecp256k1.ec_pubkey_tweak_add(key, derived_key),
         do: {public_child_key, child_chain}
  end

  defp build_child(child_key, child_chain, key, index) do
    with %{depth: depth, network: network} <- key do
      key.__struct__.new(
        network,
        child_key,
        child_chain,
        depth + 1,
        Fingerprint.build(key),
        index
      )
    end
  end
end
