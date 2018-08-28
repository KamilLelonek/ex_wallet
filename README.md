# ex_wallet

[![Build Status](https://travis-ci.com/KamilLelonek/ex_wallet.svg?token=f2crVURbhKfHsgpJjedn&branch=master)](https://travis-ci.com/KamilLelonek/ex_wallet)

The intent of this repository is described in the following articles:

* https://k.lelonek.me/bitcoin-address
* https://k.lelonek.me/bitcoin-mnemonic-phrase
* https://k.lelonek.me/bitcoin-wallet-seed
* https://k.lelonek.me/bitcoin-extended-keys
* https://k.lelonek.me/bitcoin-key-derivation

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

You are able to calculate a **Bitcoin Address** using your _private key_:

```elixir
iex(10)> ExWallet.Address.calculate(private_key)
"112NcehZWxu8WMTRXYLmKG9xiW1bP6gVyB"
```

### Mnemonic.Advanced

**`generate/1`**

You can generate a random _mnemonic words_ for the given _entropy_ length (`256` is the default).

```elixir
iex(11)> ExWallet.Mnemonic.Advanced.generate()
"quote plunge gloom vital rookie kick tiger drastic prize lab brass present play man cinnamon perfect manual deer turkey inspire exit story multiply today"

iex(12)> mnemonic = ExWallet.Mnemonic.Advanced.generate(128)
"actor quantum tunnel fish speak model attack type hint crisp boss zone"
```

**`from_entropy/1`**

However, if you already have some random entropy, you can derive a _mnemonic_ from it:

```elixir
iex(13)> entropy = "00000000000000000000000000000000"
"00000000000000000000000000000000"
iex(14)> ExWallet.Mnemonic.Advanced.from_entropy(entropy)
<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
"abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
```

**`to_entropy/1`**

And, once you have your _mnemonic words_, you can turn them back into the corresponding sequence of bytes:

```elixir
iex(14)> ExWallet.Mnemonic.Advanced.to_entropy(mnemonic)
<<2, 181, 235, 170, 43, 221, 13, 29, 3, 159, 94, 107, 198, 116, 104, 255>>
```

### Mnemonic.Simple

It has identical interface as `Advanced` above, and, as you can guess, provides a simpler implementation for the the same functionality.

### Seed

**`generate/2`**

From the generated mnemonic, you can create a seed which can be later used to derive your keys in HD _wallet_. To do that, just call:

```elixir
iex(15)> seed = ExWallet.Seed.generate(mnemonic)
"9941f6b337ae0e6501c43fcae4631c07505212220120e5837a309c4b6e0f1d8a6941bef743602ee61ae09adf72ba94bd31d3b05c5d1f00fdf7d005fdc86f5575"
```

You can provide an optional passphrase to your seed:

```elixir
iex(16)> ExWallet.Seed.generate(mnemonic, "password")
"78cf455898d8647080e0b6ba92b39c6bea1f115994c5945bca8dc8dffa2d9a428b2aef255cfeaefd381bdd5fb8aef6dae1793a169abeba481cc9ec9ded664514"
```

Notice that, even with the same _mnemonic_, the generated _seed_ is different with the given password.

### Extended

**`master/1`**

Creates a _master private key_ and a _chain code_ from the given _seed_.

```elixir
iex(17)> %{chain_code: chain_code, key: key} = master_key = ExWallet.Extended.master(seed)
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

iex(19)> public_key = ExWallet.Extended.Private.to_public(master_key)
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

### Extended.Public

**`new/6`**

Creates a new _extended public key_ struct with the given params.

```elixir
iex(21)> ExWallet.Extended.Public.new(:main, key, chain_code)
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

Creates a new _extended private key_ struct with the given params.

```elixir
iex(22)> ExWallet.Extended.Private.new(:test, key, chain_code)
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

**`to_public/1`**

Converts the given _private key_ to the public one.

```elixir
iex(23)> ExWallet.Extended.Private.to_public(master_key)
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

### Extended.Children

**`derive/2`**

Derives _public_ or _private child key_ from the given _master key_ based on the specific _chain_.

Private to Private Hardened:

```elixir
iex(23)> ExWallet.Extended.Children.derive(master_key, "m/0'/1")
%ExWallet.Extended.Private{
  chain_code: <<9, 195, 92, 71, 136, 21, 39, 116, 10, 68, 125, 72, 219, 217,
    173, 226, 21, 132, 198, 64, 219, 89, 58, 111, 108, 78, 195, 13, 240, 106,
    161, 84>>,
  child_number: 1,
  depth: 2,
  fingerprint: <<86, 241, 214, 41>>,
  key: <<210, 55, 243, 180, 11, 7, 41, 12, 126, 193, 186, 225, 51, 193, 74, 255,
    88, 44, 30, 77, 117, 36, 223, 72, 160, 233, 194, 92, 106, 131, 168, 40>>,
  network: :main,
  version_number: <<4, 136, 173, 228>>
}
```

Private to Public Hardened:

```elixir
iex(24)> ExWallet.Extended.Children.derive(master_key, "M/0'")
%ExWallet.Extended.Public{
  chain_code: <<56, 236, 184, 130, 50, 173, 70, 194, 18, 255, 38, 105, 176, 162,
    77, 93, 194, 215, 84, 161, 108, 241, 107, 203, 87, 145, 57, 209, 181, 119,
    21, 62>>,
  child_number: 2147483648,
  depth: 1,
  fingerprint: <<236, 39, 144, 106>>,
  key: <<4, 112, 255, 93, 55, 8, 241, 185, 89, 51, 71, 173, 187, 222, 172, 218,
    46, 215, 108, 57, 223, 20, 123, 177, 187, 144, 210, 106, 233, 106, 106, 117,
    108, 231, 244, 224, 90, 87, 255, 197, 207, 112, 90, 255, 217, ...>>,
  network: :main,
  version_number: <<4, 136, 178, 30>>
}
```

Public to Public:

```elixir
iex(25)> master_key |> ExWallet.Extended.Private.to_public() |> ExWallet.Extended.Children.derive("M/100")
%ExWallet.Extended.Public{
  chain_code: <<59, 227, 171, 8, 162, 89, 114, 70, 199, 64, 150, 220, 184, 44,
    92, 230, 114, 174, 24, 146, 230, 21, 42, 20, 27, 150, 11, 52, 24, 182, 84,
    56>>,
  child_number: 100,
  depth: 1,
  fingerprint: <<236, 39, 144, 106>>,
  key: <<4, 240, 125, 84, 166, 82, 126, 184, 67, 34, 134, 229, 193, 205, 246,
    115, 56, 157, 67, 98, 125, 90, 129, 50, 104, 81, 213, 118, 238, 191, 138,
    206, 45, 106, 39, 238, 137, 130, 61, 150, 160, 248, 43, 57, 61, ...>>,
  network: :main,
  version_number: <<4, 136, 178, 30>>
}
```

Public to Public Hardened:

```elixir
iex(26)> master_key |> ExWallet.Extended.to_public_key() |> ExWallet.Extended.Children.derive("m/0'")
** (RuntimeError) Cannot derive Public Hardened Child!
    (ex_wallet) lib/ex_wallet/extended/children.ex:72: ExWallet.Extended.Children.derive_key/2
    (ex_wallet) lib/ex_wallet/extended/children.ex:45: ExWallet.Extended.Children.derive_pathlist/3
```
