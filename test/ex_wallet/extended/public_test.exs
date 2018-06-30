defmodule ExWallet.Extended.PublicTest do
  use ExUnit.Case, async: true

  alias ExWallet.Extended.Public

  @chain_code <<0>>
  @child_number 0
  @depth 0
  @fingerprint <<0, 0, 0, 0>>
  @key <<0>>
  @network :main

  describe "new" do
    test "should have the default values" do
      assert %Public{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: nil,
               network: :main,
               version_number: nil
             } = %Public{}
    end

    test "should provide the default values for the main network" do
      network = :main

      assert %Public{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: @key,
               network: ^network,
               version_number: <<4, 136, 178, 30>>
             } = Public.new(network, @key)
    end

    test "should provide the default values for the test network" do
      network = :test

      assert %Public{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: @key,
               network: ^network,
               version_number: <<4, 53, 135, 207>>
             } = Public.new(network, @key)
    end

    test "should fill the given values" do
      assert %Public{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: @key,
               network: @network,
               version_number: <<4, 136, 178, 30>>
             } =
               Public.new(
                 @network,
                 @key,
                 @chain_code,
                 @depth,
                 @fingerprint,
                 @child_number
               )
    end

    test "should fill the given values with an invalid network" do
      assert %Public{
               chain_code: @chain_code,
               child_number: @child_number,
               depth: @depth,
               fingerprint: @fingerprint,
               key: @key,
               network: :x,
               version_number: nil
             } = Public.new(:x, @key)
    end
  end
end
