defmodule ExWallet.WalletTest do
  use ExUnit.Case, async: true

  alias ExWallet.{KeyPair, Wallet}

  test "should generate a valid Bitcoin Address" do
    {_key_public, key_private} = KeyPair.generate()

    address = Wallet.address(key_private)

    assert 34 = byte_size(address)
    assert 34 = String.length(address)
    assert is_bitstring(address)
    assert is_binary(address)
  end

  test "should generate a specific Bitcoin Address" do
    assert "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM" =
             Wallet.address("18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725")
  end
end
