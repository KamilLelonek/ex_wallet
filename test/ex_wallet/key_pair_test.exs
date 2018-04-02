defmodule ExWallet.KeyPairTest do
  use ExUnit.Case, async: true

  alias ExWallet.KeyPair

  describe "generate" do
    test "should generate key pair with a public and private key" do
      assert {key_public, key_private} = KeyPair.generate()
      assert is_binary(key_public)
      assert is_binary(key_private)
    end
  end

  describe "to_public_key" do
    test "should not convert a private key to a public key" do
      {key_public, _key_private} = KeyPair.generate()
      {_key_public, key_private} = KeyPair.generate()

      refute key_public == KeyPair.to_public_key(key_private)
    end

    test "should convert a private key to a public key" do
      {key_public, key_private} = KeyPair.generate()

      assert key_public == KeyPair.to_public_key(key_private)
    end

    test "should convert an encoded key to a public key" do
      {key_public, key_private} = KeyPair.generate()

      assert key_public == key_private |> Base.encode16() |> KeyPair.to_public_key()
    end

    test "should convert a string key to a public key" do
      assert "0450863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B23522CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6" ==
               "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725"
               |> KeyPair.to_public_key()
               |> Base.encode16()
    end
  end
end
