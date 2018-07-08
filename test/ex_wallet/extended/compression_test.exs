defmodule ExWallet.CompressionTest do
  use ExUnit.Case, async: true

  alias ExWallet.Compression
  alias ExWallet.Extended.{Private, Public}

  describe "run" do
    test "should compress a Private key with even Y coordinate" do
      key = Private.new(:main, <<222>>)

      assert <<0x02::8, _::256>> = Compression.run(key)
    end

    test "should compress a Private key with odd Y coordinate" do
      key = Private.new(:main, <<223>>)

      assert <<0x03::8, _::256>> = Compression.run(key)
    end

    test "should compress a Public key with even Y coordinate" do
      key = Public.new(:test, <<0x04::8, 10::256, 10::256>>)

      assert <<0x02::8, _::256>> = Compression.run(key)
    end

    test "should compress a Public key with odd Y coordinate" do
      key = Public.new(:test, <<0x04::8, 10::256, 11::256>>)

      assert <<0x03::8, _::256>> = Compression.run(key)
    end

    test "should compress a key with even Y coordinate" do
      key = <<0x04::8, 10::256, 10::256>>
      assert <<0x02::8, _::256>> = Compression.run(key)
    end

    test "should compress a key with odd Y coordinate" do
      key = <<0x04::8, 10::256, 11::256>>
      assert <<0x03::8, _::256>> = Compression.run(key)
    end
  end
end
