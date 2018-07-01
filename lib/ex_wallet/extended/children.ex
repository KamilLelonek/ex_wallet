defmodule ExWallet.Extended.Children do
  alias ExWallet.{Extended, KeyPair, Crypto}
  alias ExWallet.Extended.{Private, Public}

  @curve_order 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
  @mersenne_prime 2_147_483_647

  defguardp hardened?(index) when index > @mersenne_prime
  defguardp normal?(index) when index > -1 and index <= @mersenne_prime

  def derive(key, <<"m/", path::binary>>), do: derive(key, path, :private)
  def derive(key, <<"M/", path::binary>>), do: derive(key, path, :public)

  defp derive(key, path, kind),
    do: derive_pathlist(key, pathlist(path), kind)

  defp pathlist(path) do
    path
    |> String.split("/")
    |> Enum.map(&cast_to_integer/1)
  end

  defp cast_to_integer(part) do
    part
    |> String.reverse()
    |> cast_to_integer(part)
  end

  defp cast_to_integer(<<"'", reversed_part::binary>>, _part) do
    reversed_part
    |> String.reverse()
    |> String.to_integer()
    |> Kernel.+(1)
    |> Kernel.+(@mersenne_prime)
  end

  defp cast_to_integer(_reversed_part, part), do: String.to_integer(part)

  defp derive_pathlist(%Public{} = key, [], :public), do: key
  defp derive_pathlist(%Private{} = key, [], :private), do: key
  defp derive_pathlist(%Private{} = key, [], :public), do: Extended.to_public_key(key)

  defp derive_pathlist(key, [index | rest], kind) do
    key
    |> derive_key(index)
    |> derive_pathlist(rest, kind)
  end

  defp derive_key(%Private{chain_code: chain_code} = private_key, index)
       when normal?(index) do
    chain_code
    |> compressed_hmac_sha512(private_key, index)
    |> private_derivation(private_key, index)
  end

  defp derive_key(%Private{key: key, chain_code: chain_code} = private_key, index)
       when hardened?(index) do
    chain_code
    |> Crypto.hmac_sha512(<<0::8, key::binary, index::32>>)
    |> private_derivation(private_key, index)
  end

  defp derive_key(%Public{chain_code: chain_code} = public_key, index)
       when normal?(index) do
    chain_code
    |> compressed_hmac_sha512(public_key, index)
    |> elliptic_curve_point_addition(public_key, index)
  end

  defp derive_key(%Public{}, index)
       when hardened?(index),
       do: raise("Cannot derive Public Hardened Child!")

  defp compressed_hmac_sha512(chain_code, key, index),
    do: Crypto.hmac_sha512(chain_code, <<compress(key)::binary, index::32>>)

  defp compress(%Public{key: key}), do: Extended.compress(key)

  defp compress(%Private{key: key}) do
    key
    |> KeyPair.to_public_key()
    |> Extended.compress()
  end

  defp private_derivation(
         <<derived_key::256, child_chain::binary>>,
         %Private{key: key} = private_key,
         index
       ) do
    derived_key
    |> child_key(key)
    |> build_child(private_key, child_chain, index)
  end

  def elliptic_curve_point_addition(
        <<derived_key::binary-32, child_chain::binary>>,
        %Public{key: key} = public_key,
        index
      ) do
    key
    |> :libsecp256k1.ec_pubkey_tweak_add(derived_key)
    |> elem(1)
    |> build_child(public_key, child_chain, index)
  end

  defp child_key(derived_key, <<key::256>>) do
    derived_key
    |> Kernel.+(key)
    |> rem(@curve_order)
    |> :binary.encode_unsigned()
  end

  defp build_child(child_key, %{depth: depth} = key, child_chain, index) when is_map(key) do
    key
    |> Map.put(:key, child_key)
    |> Map.put(:chain_code, child_chain)
    |> Map.put(:depth, depth + 1)
    |> Map.put(:fingerprint, Extended.fingerprint(key))
    |> Map.put(:child_number, index)
  end
end
