defmodule ExWallet.Seed.ExtendedKeyTest do
  use ExUnit.Case, async: true

  alias ExWallet.Seed.{MasterKey, ExtendedKey}
  alias ExWallet.Keys.Pair

  @vector_bip32 "test/fixtures/bip32.json"
                |> File.read!()
                |> Poison.decode!(keys: :atoms)

  @vector_bip39 "test/fixtures/bip39.json"
                |> File.read!()
                |> Poison.decode!(keys: :atoms)

  test "should serialize public and private keys" do
    assert Enum.all?(@vector_bip32, fn %{seed: seed, chains: chains} ->
             Enum.all?(chains, fn %{pub: pub, priv: priv} ->
               %{
                 chain_code: chain_code,
                 private_key: private_key
               } = MasterKey.create(seed)

               public_key = Pair.to_public_key(private_key)

               assert ^pub = ExtendedKey.public(public_key, chain_code, :main)
               assert ^priv = ExtendedKey.private(private_key, chain_code, :main)
             end)
           end)
  end

  test "should serialize a private key" do
    assert Enum.all?(@vector_bip39, fn %{seed: seed, private_key_extended: priv} ->
             %{
               chain_code: chain_code,
               private_key: private_key
             } = MasterKey.create(seed)

             assert ^priv = ExtendedKey.private(private_key, chain_code, :main)
           end)
  end
end
