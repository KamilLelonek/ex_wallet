defmodule ExWallet.Compression do
  alias ExWallet.KeyPair
  alias ExWallet.Extended.{Private, Public}

  def run(%Public{key: key}), do: run(key)

  def run(%Private{key: key}) do
    key
    |> KeyPair.to_public_key()
    |> run()
  end

  def run(<<0x04::8, x_coordinate::256, y_coordinate::256>>) do
    y_coordinate
    |> rem(2)
    |> compress(x_coordinate)
  end

  defp compress(0, x_coordinate), do: <<0x02::8, x_coordinate::256>>
  defp compress(1, x_coordinate), do: <<0x03::8, x_coordinate::256>>
end
