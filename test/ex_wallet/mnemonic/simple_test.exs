defmodule ExWallet.Mnemonic.SimpleTest do
  use ExUnit.Case, async: true

  alias ExWallet.Mnemonic.Simple

  @vector "test/fixtures/bip39.json"
          |> File.read!()
          |> Poison.decode!(keys: :atoms)
          |> Map.get(:english)

  test "should not generate mnemonic words with invalid entropy length" do
    assert {:error, "Entropy length must be one of [128, 160, 192, 224, 256]"} =
             Simple.generate(9)
  end

  test "should validate vector mnemonics" do
    assert Enum.all?(@vector, fn [entropy, mnemonic | _] ->
             assert Simple.from_entropy(entropy) == mnemonic

             assert mnemonic
                    |> Simple.to_entropy()
                    |> Base.encode16(case: :lower) == entropy
           end)
  end

  test "should generate a random mnemonic" do
    assert 12 =
             Simple.generate(128)
             |> String.split()
             |> length()

    assert 15 =
             Simple.generate(160)
             |> String.split()
             |> length()

    assert 18 =
             Simple.generate(192)
             |> String.split()
             |> length()

    assert 21 =
             Simple.generate(224)
             |> String.split()
             |> length()

    assert 24 =
             Simple.generate(256)
             |> String.split()
             |> length()

    assert 24 =
             Simple.generate()
             |> String.split()
             |> length()
  end

  test "should generate and recover entropy" do
    mnemonic = Simple.generate()
    entropy = Simple.to_entropy(mnemonic)

    assert ^mnemonic = Simple.from_entropy(entropy)
  end

  test "should work booth on encoded and decoded entropies" do
    entropy_decoded =
      <<193, 14, 194, 13, 195, 205, 159, 101, 44, 127, 172, 47, 18, 48, 247, 163, 200, 40, 56,
        154, 20, 57, 47, 5>>

    entropy_encoded = Base.encode16(entropy_decoded, case: :lower)

    assert Simple.from_entropy(entropy_decoded) == Simple.from_entropy(entropy_encoded)
  end
end
