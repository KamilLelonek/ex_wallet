# ex_wallet

[![Build Status](https://travis-ci.com/KamilLelonek/ex_wallet.svg?token=f2crVURbhKfHsgpJjedn&branch=master)](https://travis-ci.com/KamilLelonek/ex_wallet)

The intent of this repository is described in the following articles:

* https://k.lelonek.me/bitcoin-address
* https://k.lelonek.me/bitcoin-mnemonic-phrase
* https://k.lelonek.me/bitcoin-wallet-seed

## Prerequisites

Firstly, make sure you have `libtool` (not the native one), `automake` and `autogen` installed.

To do that, use [`brew`](https://brew.sh/):

    brew install libtool automake autogen

Then, install and compile all the dependencies and the entire project:

    mix do deps.get, deps.compile, compile

## Usage

There are a couple of modules you can use.

### KeyPair

**`generate/0`**

This is the very first function you should use to generate _private_ and _public_ keys.

```elixir
iex(1)> {public_key, private_key} = ExWallet.KeyPair.generate()
{<<4, 151, 165, 182, 104, 33, 82, 87, 33, 86, 124, 244, 253, 92, 60, 183, 7,
   154, 180, 180, 47, 244, 111, 19, 40, 17, 182, 113, 123, 223, 121, 66, 61,
   163, 59, 23, 46, 179, 183, 212, 84, 206, 146, 133, 78, 224, 18, 82, 2, ...>>,
 <<228, 41, 150, 11, 220, 240, 14, 161, 45, 136, 250, 107, 22, 147, 157, 134,
   144, 53, 111, 189, 59, 72, 238, 135, 208, 136, 238, 60, 106, 160, 64, 138>>}
```

**`to_public_key/1`**

You can use the following function if you have a _private key_ and you want to derive a _public_ one.

```elixir
iex(2)> ExWallet.KeyPair.to_public_key(private_key)
<<4, 151, 165, 182, 104, 33, 82, 87, 33, 86, 124, 244, 253, 92, 60, 183, 7, 154,
  180, 180, 47, 244, 111, 19, 40, 17, 182, 113, 123, 223, 121, 66, 61, 163, 59,
  23, 46, 179, 183, 212, 84, 206, 146, 133, 78, 224, 18, 82, 2, 70, ...>>
```

### Signature

**`generate/2`**

When you have a message to sign, you can do that with your _private key_.

```elixir
iex(3)> signature = ExWallet.Signature.generate(private_key, "message")
<<48, 68, 2, 32, 83, 249, 55, 184, 125, 161, 204, 82, 253, 84, 35, 212, 65, 85,
  253, 107, 75, 142, 48, 105, 32, 132, 73, 176, 16, 183, 163, 210, 106, 22, 137,
  167, 2, 32, 118, 205, 247, 213, 157, 88, 249, 140, 83, 85, 180, 122, ...>>
```

**`verify/3`**

Later on, any user will be able to verify it with your _public key_.

```elixir
iex(4)> ExWallet.Signature.verify(public_key, signature, "message")
true
```

### Base58

**encode**

This is a regular `Base58` encoding according to its alphabet:

```elixir
iex(6)> ExWallet.Base58.Encode.call("1")
"r"
iex(7)> ExWallet.Base58.Encode.call("0")
"q"
iex(8)> ExWallet.Base58.Encode.call("a")
"2g"
iex(9)> ExWallet.Base58.Encode.call("k")
"2r"
```

### Address

**`calculate/1`**

You are able to calculate a Bitcoin Address using your _private key_:

```elixir
iex(10)> ExWallet.Address.calculate(private_key)
"112NcehZWxu8WMTRXYLmKG9xiW1bP6gVyB"
```

### Mnemonic.Advanced

**`generate/1`**

You can generate a random mnemonic words for the given entropy length (`256` is the default).

```elixir
iex(11)> ExWallet.Mnemonic.Advanced.generate()
"quote plunge gloom vital rookie kick tiger drastic prize lab brass present play man cinnamon perfect manual deer turkey inspire exit story multiply today"

iex(12)> mnemonic = ExWallet.Mnemonic.Advanced.generate(128)
"actor quantum tunnel fish speak model attack type hint crisp boss zone"
```

**`from_entropy/1`**

However, if you already have some random entropy, you can derive a mnemonic from it:

```elixir
iex(13)> entropy = "00000000000000000000000000000000"
"00000000000000000000000000000000"
iex(14)> ExWallet.Mnemonic.Advanced.from_entropy(entropy)
<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
"abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
```

**`to_entropy/1`**

And, once you have your mnemonic words, you can turn them back into the corresponding sequence of bytes:

```elixir
iex(14)> ExWallet.Mnemonic.Advanced.to_entropy(mnemonic)
<<2, 181, 235, 170, 43, 221, 13, 29, 3, 159, 94, 107, 198, 116, 104, 255>>
```

### Mnemonic.Simple

It has identical interface as `Advanced` above, and, as you can guess, provides a simpler implementation for the the same functionality.

### Seed

**`generate/2`**

From the generated mnemonic, you can create a seed which can be later used to derive your keys in HD wallet. To do that, just call:

```elixir
iex(15)> seed = ExWallet.Seed.generate(mnemonic)
"9941f6b337ae0e6501c43fcae4631c07505212220120e5837a309c4b6e0f1d8a6941bef743602ee61ae09adf72ba94bd31d3b05c5d1f00fdf7d005fdc86f5575"
```

You can provide an optional passphrase to your seed:

```elixir
iex(16)> ExWallet.Seed.generate(mnemonic, "password")
"78cf455898d8647080e0b6ba92b39c6bea1f115994c5945bca8dc8dffa2d9a428b2aef255cfeaefd381bdd5fb8aef6dae1793a169abeba481cc9ec9ded664514"
```

Notice that, even with the same mnemonic, the generated seed is different with the given password.

### Extended

**`master/1`**

Creates a master private key and a chain code from the given seed.

```elixir
iex(17)> master_key = ExWallet.Extended.master(seed)
%ExWallet.Extended.Private{
  chain_code: <<211, 95, 0, 172, 81, 118, 33, 225, 4, 161, 30, 58, 63, 94, 148,
    207, 233, 247, 216, 42, 155, 95, 136, 65, 219, 158, 48, 71, 187, 75, 232,
    121>>,
  child_number: 0,
  depth: 0,
  fingerprint: <<0, 0, 0, 0>>,
  key: <<113, 135, 206, 171, 176, 125, 48, 119, 134, 96, 129, 16, 126, 146, 98,
    237, 172, 203, 221, 191, 23, 95, 121, 216, 88, 45, 252, 56, 220, 233, 143,
    120>>,
  network: :main,
  version_number: <<4, 136, 173, 228>>
}
```

**`serialize/3`**

Serializes the given key into the `Base58` representation.

```elixir
iex(18)> ExWallet.Extended.serialize(master_key)
"xprv9s21ZrQH143K3NAHGAnTnNnTgQC3Q2A9H45DxCqSBuvvpNtGqLcrwLQjd4omvTpD5pxjjuuuZJ9gHAVYf3gzq7TZEBRtrFpKwQq8PS6BUMh"

iex(19)> public_key = ExWallet.Extended.to_public_key(master_key)
%ExWallet.Extended.Public{
  chain_code: <<188, 182, 132, 50, 118, 131, 197, 34, 46, 13, 92, 95, 242, 248,
    215, 104, 225, 149, 48, 203, 148, 210, 52, 226, 208, 13, 198, 75, 143, 9,
    29, 143>>,
  child_number: 0,
  depth: 0,
  fingerprint: <<0, 0, 0, 0>>,
  key: <<4, 247, 150, 148, 155, 170, 119, 220, 101, 153, 86, 20, 227, 168, 248,
    43, 64, 59, 11, 94, 219, 157, 20, 157, 101, 31, 50, 79, 111, 94, 173, 51,
    33, 89, 98, 132, 154, 25, 144, 94, 26, 241, 42, 204, 179, ...>>,
  network: :main,
  version_number: <<4, 136, 178, 30>>
}

iex(20)> ExWallet.Extended.serialize(public_key)
"xpub661MyMwAqRbcGRQXcXXrXAEVzprK3Qfa7FSeufon5EQn9D7T6z5puQUbiWrt6DfpUCghfoeMWSzCi9kKK3KRowuyFkPULbkTXHo7DK2MkYY"
```

**`to_public_key/1`**

Converts the given extended private key to the public one.

```elixir
iex(21)> ExWallet.Extended.to_public_key(master_key)
%ExWallet.Extended.Public{
  chain_code: <<62, 176, 6, 204, 0, 11, 94, 35, 226, 58, 8, 90, 254, 250, 246,
    78, 10, 142, 239, 51, 121, 32, 52, 180, 247, 81, 228, 255, 142, 206, 136,
    153>>,
  child_number: 0,
  depth: 0,
  fingerprint: <<0, 0, 0, 0>>,
  key: <<4, 125, 212, 138, 26, 23, 188, 118, 35, 158, 3, 16, 49, 129, 62, 87,
    19, 126, 178, 175, 55, 101, 120, 166, 214, 80, 72, 167, 217, 11, 47, 5, 117,
    46, 78, 130, 206, 21, 46, 111, 131, 191, 126, 222, 185, ...>>,
  network: :main,
  version_number: <<4, 136, 178, 30>>
}
```

### Extended.Public

**`new/6`**

Creates a new public extended key struct with the given params.

```elixir
iex(22)> ExWallet.Extended.Public.new(:main, key, chain_code)
%ExWallet.Extended.Public{
  chain_code: <<230, 125, 124, 99, 28, 250, 75, 124, 12, 51, 140, 0, 243, 64,
    111, 227, 169, 73, 152, 111, 175, 136, 252, 11, 126, 58, 46, 143, 146, 72,
    238, 242>>,
  child_number: 0,
  depth: 0,
  fingerprint: <<0, 0, 0, 0>>,
  key: <<133, 188, 193, 183, 218, 206, 89, 125, 148, 36, 247, 59, 231, 52, 107,
    71, 134, 107, 46, 72, 225, 30, 196, 236, 87, 27, 236, 28, 233, 13, 8, 162>>,
  network: :main,
  version_number: <<4, 136, 178, 30>>
}
```

### Extended.Private

**`new/6`**

Creates a new private extended key struct with the given params.

```elixir
iex(23)> ExWallet.Extended.Private.new(:test, key, chain_code)
%ExWallet.Extended.Private{
  chain_code: <<230, 125, 124, 99, 28, 250, 75, 124, 12, 51, 140, 0, 243, 64,
    111, 227, 169, 73, 152, 111, 175, 136, 252, 11, 126, 58, 46, 143, 146, 72,
    238, 242>>,
  child_number: 0,
  depth: 0,
  fingerprint: <<0, 0, 0, 0>>,
  key: <<133, 188, 193, 183, 218, 206, 89, 125, 148, 36, 247, 59, 231, 52, 107,
    71, 134, 107, 46, 72, 225, 30, 196, 236, 87, 27, 236, 28, 233, 13, 8, 162>>,
  network: :test,
  version_number: <<4, 53, 131, 148>>
}
```
