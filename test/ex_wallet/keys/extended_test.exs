defmodule ExWallet.Keys.ExtendedTest do
  use ExUnit.Case, async: true

  alias ExWallet.Keys.{Pair, Master, Extended}

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
                 key: key
               } = Master.create(seed)

               public_key = Pair.to_public_key(key)

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
             } = Master.create(seed)

             assert ^priv = Extended.private(key, chain_code, :main)
           end)
  end
end
