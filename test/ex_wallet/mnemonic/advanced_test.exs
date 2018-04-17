defmodule ExWallet.Mnemonic.AdvancedTest do
  use ExUnit.Case, async: true

  alias ExWallet.Mnemonic.Advanced

  @vector "test/fixtures/vectors.json"
          |> File.read!()
          |> Poison.decode!(keys: :atoms)
          |> Map.get(:english)

  test "should not generate mnemonic words with invalid entropy length" do
    assert {:error, "Entropy length must be one of [128, 160, 192, 224, 256]"} =
             Advanced.generate(9)
  end

  test "should validate vector mnemonics" do
    assert Enum.all?(@vector, fn [entropy, mnemonic | _] ->
             assert Advanced.from_entropy(entropy) == mnemonic

             assert mnemonic
                    |> Advanced.to_entropy()
                    |> Base.encode16(case: :lower) == entropy
           end)
  end

  test "should generate a random mnemonic" do
    assert 12 =
             Advanced.generate(128)
             |> String.split()
             |> length()

    assert 15 =
             Advanced.generate(160)
             |> String.split()
             |> length()

    assert 18 =
             Advanced.generate(192)
             |> String.split()
             |> length()

    assert 21 =
             Advanced.generate(224)
             |> String.split()
             |> length()

    assert 24 =
             Advanced.generate(256)
             |> String.split()
             |> length()

    assert 24 =
             Advanced.generate()
             |> String.split()
             |> length()
  end

  test "should generate and recover entropy" do
    mnemonic = Advanced.generate()
    entropy = Advanced.to_entropy(mnemonic)

    assert ^mnemonic = Advanced.from_entropy(entropy)
  end

  test "should work booth on encoded and decoded entropies" do
    entropy_decoded =
      <<193, 14, 194, 13, 195, 205, 159, 101, 44, 127, 172, 47, 18, 48, 247, 163, 200, 40, 56,
        154, 20, 57, 47, 5>>

    entropy_encoded = Base.encode16(entropy_decoded, case: :lower)

    assert Advanced.from_entropy(entropy_decoded) == Advanced.from_entropy(entropy_encoded)
  end
end
