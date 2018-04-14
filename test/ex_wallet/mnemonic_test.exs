defmodule ExWallet.MnemonicTest do
  use ExUnit.Case, async: true

  alias ExWallet.Mnemonic

  @vector "test/fixtures/vectors.json"
          |> File.read!()
          |> Poison.decode!(keys: :atoms)
          |> Map.get(:english)

  test "should not generate mnemonic words with invalid entropy length" do
    assert {:error, "Entropy length must be one of [128, 160, 192, 224, 256]"} =
             Mnemonic.generate(9)
  end

  test "should validate vector mnemonics" do
    assert Enum.all?(@vector, fn [entropy, mnemonic | _] ->
             assert Mnemonic.from_entropy(entropy) == mnemonic

             assert mnemonic
                    |> Mnemonic.to_entropy()
                    |> Base.encode16(case: :lower) == entropy
           end)
  end

  test "should generate a random mnemonic" do
    assert 12 =
             Mnemonic.generate(128)
             |> String.split()
             |> length()

    assert 15 =
             Mnemonic.generate(160)
             |> String.split()
             |> length()

    assert 18 =
             Mnemonic.generate(192)
             |> String.split()
             |> length()

    assert 21 =
             Mnemonic.generate(224)
             |> String.split()
             |> length()

    assert 24 =
             Mnemonic.generate(256)
             |> String.split()
             |> length()

    assert 24 =
             Mnemonic.generate()
             |> String.split()
             |> length()
  end

  test "should generate and recover entropy" do
    mnemonic = Mnemonic.generate()
    entropy = Mnemonic.to_entropy(mnemonic)

    assert ^mnemonic = Mnemonic.from_entropy(entropy)
  end

  test "should work booth on encoded and decoded entropies" do
    entropy_decoded =
      <<193, 14, 194, 13, 195, 205, 159, 101, 44, 127, 172, 47, 18, 48, 247, 163, 200, 40, 56,
        154, 20, 57, 47, 5>>

    entropy_encoded = Base.encode16(entropy_decoded, case: :lower)

    assert Mnemonic.from_entropy(entropy_decoded) == Mnemonic.from_entropy(entropy_encoded)
  end
end
