defmodule ExWallet.Address do
  alias ExWallet.Base58.{Check, Encode}
  alias ExWallet.KeyPair

  @version_bytes %{
    main: <<0x00>>,
    test: <<0x6F>>
  }

  def calculate(private_key, network \\ :main) do
    private_key
    |> KeyPair.to_public_key()
    |> hash_160()
    |> prepend_version_byte(network)
    |> Check.call()
    |> Encode.call()
  end

  defp hash_160(public_key) do
    public_key
    |> hash(:sha256)
    |> hash(:ripemd160)
  end

  defp hash(data, algorithm), do: :crypto.hash(algorithm, data)

  defp prepend_version_byte(public_hash, network) do
    @version_bytes
    |> Map.get(network)
    |> Kernel.<>(public_hash)
  end
end
