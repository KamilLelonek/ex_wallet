defmodule ExWallet.Wif do
  alias ExWallet.Base58
  alias ExWallet.Extended.Private

  @prefixes %{
    main: <<0x80>>,
    test: <<0xef>>
  }

  def priv_to_wif(key, network \\ :main)
  def priv_to_wif(%Private{key: key}, network), do: priv_to_wif(key, network)
  def priv_to_wif(key, network) when is_binary(key) do
    key
    |> prepend_symbol(network)
    |> Base58.check_encode()
  end

  defp prepend_symbol(key, network) do
    @prefixes
    |> Map.get(network)
    |> Kernel.<>(key)
  end
end
