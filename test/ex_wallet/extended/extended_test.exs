defmodule ExWallet.Keys.ExtendedTest do
  use ExUnit.Case, async: true

  alias ExWallet.{Seed, KeyPair, Extended}
  alias ExWallet.Extended.{Private, Public}

  @vector_bip32 "test/fixtures/bip32.json"
                |> File.read!()
                |> Poison.decode!(keys: :atoms)

  @vector_bip39 "test/fixtures/bip39.json"
                |> File.read!()
                |> Poison.decode!(keys: :atoms)

  @mnemonic "primary matter gate"
  @seed "32038ca6aa25db9377aaf54ac2de4059419205e4b9021b68a3b83039a5742b1f0d55cd39c3b8369373507963209c9676ac230d4724cb343b26a3cba4d6c84cae"

  test "should extract a private key and a chain code from mnemonic" do
    assert %{key: key, chain_code: chain_code} = @mnemonic |> Seed.generate() |> Extended.master()

    <<^key::binary-32, ^chain_code::binary-32>> =
      :crypto.hmac(:sha512, "Bitcoin seed", Base.decode16!(@seed, case: :lower))
  end

  test "should extract a private key and a chain code from seed" do
    assert %{key: key, chain_code: chain_code} = Extended.master(@seed)

    <<^key::binary-32, ^chain_code::binary-32>> =
      :crypto.hmac(:sha512, "Bitcoin seed", Base.decode16!(@seed, case: :lower))
  end

  test "should serialize public and private keys" do
    assert Enum.all?(@vector_bip32, fn %{seed: seed, chains: chains} ->
             Enum.all?(chains, fn %{pub: pub, priv: priv} ->
               %{
                 chain_code: chain_code,
                 key: key
               } = Extended.master(seed)

               public_key = KeyPair.to_public_key(key)

               assert ^pub = Extended.public(public_key, chain_code, :main)
               assert ^priv = Extended.private(key, chain_code, :main)
             end)
           end)
  end

  test "should serialize a private key" do
    assert Enum.all?(@vector_bip39, fn %{seed: seed, private_key_extended: priv} ->
             %{
               chain_code: chain_code,
               key: key
             } = Extended.master(seed)

             assert ^priv = Extended.private(key, chain_code, :main)
           end)
  end

  describe "to_public_key" do
    test "should convert the master PrivateKey to PublicKey" do
      assert master_private_key =
               %Private{
                 chain_code: chain_code,
                 child_number: child_number,
                 depth: depth,
                 fingerprint: fingerprint,
                 key: private_key,
                 network: network,
                 version_number: version_number_private
               } = @mnemonic |> Seed.generate() |> Extended.master()

      assert %Public{
               chain_code: ^chain_code,
               child_number: ^child_number,
               depth: ^depth,
               fingerprint: ^fingerprint,
               key: public_key,
               network: ^network,
               version_number: version_number_public
             } = Extended.to_public_key(master_private_key)

      refute version_number_private == version_number_public

      assert public_key == KeyPair.to_public_key(private_key)
    end
  end
end
