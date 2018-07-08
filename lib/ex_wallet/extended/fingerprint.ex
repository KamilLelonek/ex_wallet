defmodule ExWallet.Fingerprint do
  alias ExWallet.{KeyPair, Crypto, Compression}
  alias ExWallet.Extended.{Private, Public}

  def build(%Private{key: key}) do
    key
    |> KeyPair.to_public_key()
    |> build()
  end

  def build(%Public{key: key}), do: build(key)

  def build(pub_key) do
    pub_key
    |> Compression.run()
    |> Crypto.hash_160()
    |> fingerprint()
  end

  defp fingerprint(<<fingerprint::binary-4, _rest::binary>>),
    do: fingerprint
end
