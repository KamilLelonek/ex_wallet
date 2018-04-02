defmodule ExWallet.Base58.EncodeTest do
  use ExUnit.Case, async: true

  alias ExWallet.Base58.Encode

  test "should encode simple values" do
    assert "q" == Encode.call("0")
    assert "r" == Encode.call("1")
    assert "53t" == Encode.call("57")
    assert "53u" == Encode.call("58")
    assert "2g" == Encode.call("a")
    assert "2k" == Encode.call("e")
    assert "37" == Encode.call("z")
  end

  test "should encode the entire hash" do
    assert "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM" ==
             "00010966776006953D5567439E5E39F86A0D273BEED61967F6"
             |> Base.decode16!()
             |> Encode.call()
  end
end
