defmodule ExWallet.Mnemonic.MnemonicTest do
  use ExUnit.Case, async: true

  alias ExWallet.Mnemonic.{Simple, Advanced}

  @vector "test/fixtures/vectors.json"
          |> File.read!()
          |> Poison.decode!(keys: :atoms)
          |> Map.get(:english)

  test "should validate vector mnemonics" do
    assert Enum.all?(@vector, fn [entropy, mnemonic | _] ->
             assert Advanced.from_entropy(entropy) == mnemonic

             assert mnemonic
                    |> Simple.to_entropy()
                    |> Base.encode16(case: :lower) == entropy

             assert Simple.from_entropy(entropy) == mnemonic

             assert mnemonic
                    |> Advanced.to_entropy()
                    |> Base.encode16(case: :lower) == entropy
           end)
  end

  test "should convert from Advanced to Simple" do
    mnemonic = Advanced.generate()
    entropy = Advanced.to_entropy(mnemonic)

    assert ^mnemonic = Simple.from_entropy(entropy)
  end

  test "should convert from Simple to Advanced" do
    mnemonic = Simple.generate()
    entropy = Simple.to_entropy(mnemonic)

    assert ^mnemonic = Advanced.from_entropy(entropy)
  end

  test "should convert between Simple and Advanced" do
    mnemonic = Advanced.generate()
    entropy = Simple.to_entropy(mnemonic)

    assert ^mnemonic = Advanced.from_entropy(entropy)
  end

  test "should convert between Advanced and Simple" do
    mnemonic = Simple.generate()
    entropy = Advanced.to_entropy(mnemonic)

    assert ^mnemonic = Simple.from_entropy(entropy)
  end
end
