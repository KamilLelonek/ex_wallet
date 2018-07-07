defmodule ExWallet.Extended.Pathlist do
  @mersenne_prime 2_147_483_647

  def to_list(<<"m/", path::binary>>), do: {:private, to_list(path)}
  def to_list(<<"M/", path::binary>>), do: {:public, to_list(path)}

  def to_list(path) do
    path
    |> String.split("/")
    |> Enum.map(&cast_to_integer/1)
  end

  defp cast_to_integer(level) do
    level
    |> String.reverse()
    |> maybe_hardened(level)
  end

  defp maybe_hardened(<<"'", reversed_part::binary>>, _level) do
    reversed_part
    |> String.reverse()
    |> String.to_integer()
    |> Kernel.+(1)
    |> Kernel.+(@mersenne_prime)
  end

  defp maybe_hardened(_reversed_part, level), do: String.to_integer(level)
end
