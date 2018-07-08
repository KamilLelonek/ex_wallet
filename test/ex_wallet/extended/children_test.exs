defmodule ExWallet.Extended.ChildrenTest do
  use ExUnit.Case, async: true

  alias ExWallet.Extended
  alias ExWallet.Extended.{Children, Private}

  test "Test vector 1" do
    seed = "000102030405060708090a0b0c0d0e0f"
    master_key = Extended.master(seed)

    # M/0h
    assert "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw" =
             derive(master_key, "M/0'")

    # m/0h
    assert "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7" =
             derive(master_key, "m/0'")

    # M/0h/1
    assert "xpub6ASuArnXKPbfEwhqN6e3mwBcDTgzisQN1wXN9BJcM47sSikHjJf3UFHKkNAWbWMiGj7Wf5uMash7SyYq527Hqck2AxYysAA7xmALppuCkwQ" =
             derive(master_key, "M/0'/1")

    # m/0h/1
    assert "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs" =
             derive(master_key, "m/0'/1")

    # M/0h/1/2h
    assert "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW5" =
             derive(master_key, "M/0'/1/2'")

    # m/0h/1/2h
    assert "xprv9z4pot5VBttmtdRTWfWQmoH1taj2axGVzFqSb8C9xaxKymcFzXBDptWmT7FwuEzG3ryjH4ktypQSAewRiNMjANTtpgP4mLTj34bhnZX7UiM" =
             derive(master_key, "m/0'/1/2'")

    # M/0h/1/2h/2
    assert "xpub6FHa3pjLCk84BayeJxFW2SP4XRrFd1JYnxeLeU8EqN3vDfZmbqBqaGJAyiLjTAwm6ZLRQUMv1ZACTj37sR62cfN7fe5JnJ7dh8zL4fiyLHV" =
             derive(master_key, "M/0'/1/2'/2")

    # m/0h/1/2h/2
    assert "xprvA2JDeKCSNNZky6uBCviVfJSKyQ1mDYahRjijr5idH2WwLsEd4Hsb2Tyh8RfQMuPh7f7RtyzTtdrbdqqsunu5Mm3wDvUAKRHSC34sJ7in334" =
             derive(master_key, "m/0'/1/2'/2")

    # M/0h/1/2h/2/1000000000
    assert "xpub6H1LXWLaKsWFhvm6RVpEL9P4KfRZSW7abD2ttkWP3SSQvnyA8FSVqNTEcYFgJS2UaFcxupHiYkro49S8yGasTvXEYBVPamhGW6cFJodrTHy" =
             derive(master_key, "M/0'/1/2'/2/1000000000")

    # m/0h/1/2h/2/1000000000
    assert "xprvA41z7zogVVwxVSgdKUHDy1SKmdb533PjDz7J6N6mV6uS3ze1ai8FHa8kmHScGpWmj4WggLyQjgPie1rFSruoUihUZREPSL39UNdE3BBDu76" =
             derive(master_key, "m/0'/1/2'/2/1000000000")
  end

  test "Test vector 2" do
    seed =
      "fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542"

    master_key = Extended.master(seed)

    # M/0
    assert "xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUmmDznezpbZb7ap6r1D3tgFxHmwMkQTPH" =
             derive(master_key, "M/0")

    # m/0
    assert "xprv9vHkqa6EV4sPZHYqZznhT2NPtPCjKuDKGY38FBWLvgaDx45zo9WQRUT3dKYnjwih2yJD9mkrocEZXo1ex8G81dwSM1fwqWpWkeS3v86pgKt" =
             derive(master_key, "m/0")

    # M/0/2147483647h
    assert "xpub6ASAVgeehLbnwdqV6UKMHVzgqAG8Gr6riv3Fxxpj8ksbH9ebxaEyBLZ85ySDhKiLDBrQSARLq1uNRts8RuJiHjaDMBU4Zn9h8LZNnBC5y4a" =
             derive(master_key, "M/0/2147483647'")

    # m/0/2147483647h
    assert "xprv9wSp6B7kry3Vj9m1zSnLvN3xH8RdsPP1Mh7fAaR7aRLcQMKTR2vidYEeEg2mUCTAwCd6vnxVrcjfy2kRgVsFawNzmjuHc2YmYRmagcEPdU9" =
             derive(master_key, "m/0/2147483647'")

    # M/0/2147483647h/1
    assert "xpub6DF8uhdarytz3FWdA8TvFSvvAh8dP3283MY7p2V4SeE2wyWmG5mg5EwVvmdMVCQcoNJxGoWaU9DCWh89LojfZ537wTfunKau47EL2dhHKon" =
             derive(master_key, "M/0/2147483647'/1")

    # m/0/2147483647h/1
    assert "xprv9zFnWC6h2cLgpmSA46vutJzBcfJ8yaJGg8cX1e5StJh45BBciYTRXSd25UEPVuesF9yog62tGAQtHjXajPPdbRCHuWS6T8XA2ECKADdw4Ef" =
             derive(master_key, "m/0/2147483647'/1")

    # M/0/2147483647h/1/2147483646h
    assert "xpub6ERApfZwUNrhLCkDtcHTcxd75RbzS1ed54G1LkBUHQVHQKqhMkhgbmJbZRkrgZw4koxb5JaHWkY4ALHY2grBGRjaDMzQLcgJvLJuZZvRcEL" =
             derive(master_key, "M/0/2147483647'/1/2147483646'")

    # m/0/2147483647h/1/2147483646h
    assert "xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc" =
             derive(master_key, "m/0/2147483647'/1/2147483646'")

    # M/0/2147483647h/1/2147483646h/2
    assert "xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt" =
             derive(master_key, "M/0/2147483647'/1/2147483646'/2")

    # m/0/2147483647h/1/2147483646h/2
    assert "xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j" =
             derive(master_key, "m/0/2147483647'/1/2147483646'/2")
  end

  describe "Test vector 3" do
    test "should verify the retention of leading zeros" do
      seed =
        "4b381541583be4423346c643850da4b320e46a87ae3d2a4e6da11eba819cd4acba45d239319ac14f863b8d5ab5a0d0c64d2e8a1e7d1457df2e5a3c51c73235be"

      master_key = Extended.master(seed)

      # m
      assert "xprv9s21ZrQH143K25QhxbucbDDuQ4naNntJRi4KUfWT7xo4EKsHt2QJDu7KXp1A3u7Bi1j8ph3EGsZ9Xvz9dGuVrtHHs7pXeTzjuxBrCmmhgC6" =
               Extended.serialize(master_key)

      # M
      assert "xpub661MyMwAqRbcEZVB4dScxMAdx6d4nFc9nvyvH3v4gJL378CSRZiYmhRoP7mBy6gSPSCYk6SzXPTf3ND1cZAceL7SfJ1Z3GC8vBgp2epUt13" =
               master_key |> Private.to_public() |> Extended.serialize()

      # M/0h
      assert "xpub68NZiKmJWnxxS6aaHmn81bvJeTESw724CRDs6HbuccFQN9Ku14VQrADWgqbhhTHBaohPX4CjNLf9fq9MYo6oDaPPLPxSb7gwQN3ih19Zm4Y" =
               derive(master_key, "M/0'")

      # m/0h
      assert "xprv9uPDJpEQgRQfDcW7BkF7eTya6RPxXeJCqCJGHuCJ4GiRVLzkTXBAJMu2qaMWPrS7AANYqdq6vcBcBUdJCVVFceUvJFjaPdGZ2y9WACViL4L" =
               derive(master_key, "m/0'")
    end
  end

  describe "failure" do
    test "should not derive Public Hardened Child" do
      assert_raise(
        RuntimeError,
        "Cannot derive Public Hardened Child!",
        fn ->
          ""
          |> Extended.master()
          |> Children.derive("M/0'/1/2'")
          |> Children.derive("M/100'")
        end
      )
    end

    test "should not derive Private Child from a Public Parent" do
      assert_raise(
        RuntimeError,
        "Cannot derive Private Child from a Public Parent!",
        fn ->
          ""
          |> Extended.master()
          |> Private.to_public()
          |> Children.derive("m/0/0/0")
          |> IO.inspect()
        end
      )
    end
  end

  defp derive(master_key, chain) do
    master_key
    |> Children.derive(chain)
    |> Extended.serialize()
  end
end
