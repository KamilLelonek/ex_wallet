defmodule ExWallet.SignatureTest do
  use ExUnit.Case, async: true

  alias ExWallet.{Keys.Pair, Signature}

  @message "This is a message"

  test "should generate and verify the given message" do
    {key_public, key_private} = Pair.generate()
    signature = Signature.generate(key_private, @message)

    assert is_binary(signature)
    assert true = Signature.verify(key_public, signature, @message)
  end

  test "should not verify an invalid message" do
    {key_public, key_private} = Pair.generate()
    signature = Signature.generate(key_private, @message)

    refute Signature.verify(key_public, signature, "message")
  end

  test "should not verify with an invalid private key" do
    {key_public, _key_private} = Pair.generate()
    signature = Signature.generate("key_private", @message)

    refute Signature.verify(key_public, signature, @message)
  end

  test "should not verify with an invalid public key" do
    {_key_public, key_private} = Pair.generate()
    signature = Signature.generate(key_private, @message)

    refute Signature.verify("key_public", signature, @message)
  end
end
