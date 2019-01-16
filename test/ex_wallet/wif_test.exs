defmodule ExWallet.WifTest do
  use ExUnit.Case, async: true

  alias ExWallet.Wif

  # source of tests: https://en.bitcoin.it/wiki/Wallet_import_format
  setup do
    # Here we convert the hex representation of the private key, into a binary <<12, ...>>
    hex_priv = "0C28FCA386C7A227600B2FE50B7CAE11EC86D3BF1FBE471BE89827E19D72AA1D"

    priv =
      for <<x::binary-2 <- hex_priv>> do
        x
      end
      |> Enum.map(&String.to_integer(&1, 16))
      |> Enum.reverse
      |> Enum.reduce(<<>>, fn x, acc -> <<x>> <> acc end)

    [priv: priv]
  end

  test "Converts private key into wallet import format", %{priv: priv} do
    result = Wif.priv_to_wif(priv)

    assert result == "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"
  end
end
