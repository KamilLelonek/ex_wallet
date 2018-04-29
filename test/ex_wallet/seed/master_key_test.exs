defmodule ExWallet.Seed.MasterKeyTest do
  use ExUnit.Case, async: true

  alias ExWallet.Seed
  alias ExWallet.Seed.MasterKey

  @mnemonic "primary matter gate"
  @seed "32038ca6aa25db9377aaf54ac2de4059419205e4b9021b68a3b83039a5742b1f0d55cd39c3b8369373507963209c9676ac230d4724cb343b26a3cba4d6c84cae"

  test "should extract a private key and a chain code from mnemonic" do
    assert %{private_key: private_key, chain_code: chain_code} =
             @mnemonic |> Seed.generate() |> MasterKey.create()

    <<^private_key::binary-32, ^chain_code::binary-32>> =
      :crypto.hmac(:sha512, "Bitcoin seed", Base.decode16!(@seed, case: :lower))
  end

  test "should extract a private key and a chain code from seed" do
    assert %{private_key: private_key, chain_code: chain_code} = MasterKey.create(@seed)

    <<^private_key::binary-32, ^chain_code::binary-32>> =
      :crypto.hmac(:sha512, "Bitcoin seed", Base.decode16!(@seed, case: :lower))
  end
end
