defmodule ExWallet.ReadmeTest do
  use ExUnit.Case, async: true

  describe "README.md" do
    test "part1" do
      {public_key, private_key} = ExWallet.KeyPair.generate()
      ExWallet.KeyPair.to_public_key(private_key)
      message = "message"
      signature = ExWallet.Signature.generate(private_key, message)
      ExWallet.Signature.verify(public_key, signature, message)
      ExWallet.Address.calculate(private_key)
    end

    test "part2" do
      ExWallet.Mnemonic.Advanced.generate()
      ExWallet.Mnemonic.Simple.generate()
      ExWallet.Base58.Encode.call("1")
      entropy = "00000000000000000000000000000000"
      ExWallet.Mnemonic.Advanced.from_entropy(entropy)
      ExWallet.Mnemonic.Simple.from_entropy(entropy)
    end

    test "part3" do
      mnemonic = ExWallet.Mnemonic.Advanced.generate(128)
      ExWallet.Mnemonic.Simple.generate(256)
      seed = ExWallet.Seed.generate(mnemonic)
      ExWallet.Mnemonic.Advanced.to_entropy(mnemonic)
      ExWallet.Mnemonic.Simple.to_entropy(mnemonic)
      ExWallet.Seed.generate(mnemonic, "password")
      %{chain_code: chain_code, key: key} = master_key = ExWallet.Extended.master(seed)
      ExWallet.Extended.serialize(master_key)
      public_key = ExWallet.Extended.Private.to_public(master_key)
      ExWallet.Extended.serialize(public_key)
      ExWallet.Extended.Public.new(:main, key, chain_code)
      ExWallet.Extended.Private.new(:test, key, chain_code)
      ExWallet.Extended.Private.to_public(master_key)
      ExWallet.Extended.Children.derive(master_key, "m/0'/1")
      ExWallet.Extended.Children.derive(master_key, "M/0'")

      master_key
      |> ExWallet.Extended.Private.to_public()
      |> ExWallet.Extended.Children.derive("M/100")
    end
  end
end
