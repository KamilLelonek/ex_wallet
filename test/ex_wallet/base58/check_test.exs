defmodule ExWallet.Base58.CheckTest do
  use ExUnit.Case, async: true

  alias ExWallet.Base58.Check

  @input "00010966776006953D5567439E5E39F86A0D273BEE"
  @checksum "D61967F6"
  @result @input <> @checksum

  test "should perform Base58 check on the given hash" do
    assert @result =
             @input
             |> Base.decode16!()
             |> Check.call()
             |> Base.encode16()
  end

  test "should perform Base58 check on an empty hash" do
    assert "5DF6E0E2" =
             ""
             |> Base.decode16!()
             |> Check.call()
             |> Base.encode16()
  end

  test "should perform Base58 check on an empty bytes" do
    assert "5DF6E0E2" =
             <<>>
             |> Check.call()
             |> Base.encode16()
  end
end
