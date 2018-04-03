# ex_wallet

[![Build Status](https://travis-ci.com/KamilLelonek/ex_wallet.svg?token=f2crVURbhKfHsgpJjedn&branch=master)](https://travis-ci.com/KamilLelonek/ex_wallet)

The intent of this repository is described in the following article: https://blog.lelonek.me/how-to-calculate-bitcoin-address-in-elixir-68939af4f0e9

## Usage

There are a couple of modules you can use.

### KeyPair

**`generate/0`**

This is the very first function you should use to generate _private_ and _public_ keys.

    iex(1)> {public_key, private_key} = ExWallet.KeyPair.generate()
    {<<4, 151, 165, 182, 104, 33, 82, 87, 33, 86, 124, 244, 253, 92, 60, 183, 7,
       154, 180, 180, 47, 244, 111, 19, 40, 17, 182, 113, 123, 223, 121, 66, 61,
       163, 59, 23, 46, 179, 183, 212, 84, 206, 146, 133, 78, 224, 18, 82, 2, ...>>,
     <<228, 41, 150, 11, 220, 240, 14, 161, 45, 136, 250, 107, 22, 147, 157, 134,
       144, 53, 111, 189, 59, 72, 238, 135, 208, 136, 238, 60, 106, 160, 64, 138>>}

**`to_public_key/1`**

You can use the following function if you have a _private key_ and you want to derive a _public_ one.

    iex(2)> ExWallet.KeyPair.to_public_key(private_key)
    <<4, 151, 165, 182, 104, 33, 82, 87, 33, 86, 124, 244, 253, 92, 60, 183, 7, 154,
      180, 180, 47, 244, 111, 19, 40, 17, 182, 113, 123, 223, 121, 66, 61, 163, 59,
      23, 46, 179, 183, 212, 84, 206, 146, 133, 78, 224, 18, 82, 2, 70, ...>>

### Signature

**`generate/2`**

When you have a message to sign, you can do that with your _private key_.

    iex(3)> ExWallet.Signature.generate(private_key, "message")
    <<48, 68, 2, 32, 83, 249, 55, 184, 125, 161, 204, 82, 253, 84, 35, 212, 65, 85,
      253, 107, 75, 142, 48, 105, 32, 132, 73, 176, 16, 183, 163, 210, 106, 22, 137,
      167, 2, 32, 118, 205, 247, 213, 157, 88, 249, 140, 83, 85, 180, 122, ...>>

**`verify/3`**

Later on, any user will be able to verify it with your _public key_.

    iex(4)> ExWallet.Signature.verify(public_key, signature, "message")
    true

### Base58

**encode**

This is a regular `Base58` encoding according to its alphabet:

    iex(6)> ExWallet.Base58.Encode.call("1")
    "r"
    iex(7)> ExWallet.Base58.Encode.call("0")
    "q"
    iex(8)> ExWallet.Base58.Encode.call("a")
    "2g"
    iex(9)> ExWallet.Base58.Encode.call("k")
    "2r"

### Address

**`calculate/1`**

Finally, you can generate a Bitcoin Address using your _private key_:

    iex(10)> ExWallet.Address.calculate(private_key)
    "112NcehZWxu8WMTRXYLmKG9xiW1bP6gVyB"
