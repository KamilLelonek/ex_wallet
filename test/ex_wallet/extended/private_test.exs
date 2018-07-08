defmodule ExWallet.Extended.PrivateTest do
  use ExUnit.Case, async: true

  alias ExWallet.{Seed, Extended, KeyPair}
  alias ExWallet.Extended.{Private, Public}

  @chain_code <<0>>
  @child_number 0
  @depth 0
  @fingerprint <<0, 0, 0, 0>>
  @key <<128>>
  @network :main

  describe "new" do
    test "should have the default values" do
      assert %Private{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: nil,
               network: :main,
               version_number: nil
             } = %Private{}
    end

    test "should provide the default values for the main network" do
      network = :main

      assert %Private{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: @key,
               network: ^network,
               version_number: <<4, 136, 173, 228>>
             } = Private.new(network, @key)
    end

    test "should provide the default values for the test network" do
      network = :test

      assert %Private{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: @key,
               network: ^network,
               version_number: <<4, 53, 131, 148>>
             } = Private.new(network, @key)
    end

    test "should fill the given values" do
      assert %Private{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: @key,
               network: @network,
               version_number: <<4, 136, 173, 228>>
             } =
               Private.new(
                 @network,
                 @key,
                 @chain_code,
                 @depth,
                 @fingerprint,
                 @child_number
               )
    end

    test "should fill the given values with an invalid network" do
      assert %Private{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: @key,
               network: :x,
               version_number: nil
             } = Private.new(:x, @key)
    end
  end

  describe "to_public" do
    test "should convert the given Private key to the Public one" do
      assert %Public{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: public_key,
               network: @network,
               version_number: <<4, 136, 178, 30>>
             } = @network |> Private.new(@key) |> Private.to_public()

      assert public_key == KeyPair.to_public_key(@key)
    end

    test "should convert the master PrivateKey to PublicKey" do
      assert master_private_key =
               %Private{
                 chain_code: chain_code,
                 child_number: child_number,
                 depth: depth,
                 fingerprint: fingerprint,
                 key: private_key,
                 network: network,
                 version_number: version_number_private
               } = "primary matter gate" |> Seed.generate() |> Extended.master()

      assert %Public{
               chain_code: ^chain_code,
               child_number: ^child_number,
               depth: ^depth,
               fingerprint: ^fingerprint,
               key: public_key,
               network: ^network,
               version_number: version_number_public
             } = Private.to_public(master_private_key)

      refute version_number_private == version_number_public

      assert public_key == KeyPair.to_public_key(private_key)
    end
  end
end
