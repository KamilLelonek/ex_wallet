defmodule ExWallet.Address do
  alias ExWallet.{Base58, KeyPair, Crypto}

  @version_bytes %{
    main: <<0x00>>,
    test: <<0x6F>>
  }

  def calculate(private_key, network \\ :main) do
    private_key
    |> KeyPair.to_public_key()
    |> Crypto.hash_160()
    |> prepend_version_byte(network)
    |> Base58.check_encode()
  end

  defp prepend_version_byte(public_hash, network) do
    @version_bytes
    |> Map.get(network)
    |> Kernel.<>(public_hash)
  end
end
