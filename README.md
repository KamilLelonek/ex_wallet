# ex_wallet

[![Build Status](https://travis-ci.com/KamilLelonek/ex_wallet.svg?token=f2crVURbhKfHsgpJjedn&branch=master)](https://travis-ci.com/KamilLelonek/ex_wallet)

The intent of this repository is described in the following articles:

* https://k.lelonek.me/bitcoin-address
* https://k.lelonek.me/bitcoin-mnemonic-phrase
* https://k.lelonek.me/bitcoin-wallet-seed

## Usage

There are a couple of modules you can use.

### Keys.Pair

**`generate/0`**

This is the very first function you should use to generate _private_ and _public_ keys.

```elixir
iex(1)> {public_key, private_key} = ExWallet.Keys.Pair.generate()
{<<4, 151, 165, 182, 104, 33, 82, 87, 33, 86, 124, 244, 253, 92, 60, 183, 7,
   154, 180, 180, 47, 244, 111, 19, 40, 17, 182, 113, 123, 223, 121, 66, 61,
   163, 59, 23, 46, 179, 183, 212, 84, 206, 146, 133, 78, 224, 18, 82, 2, ...>>,
 <<228, 41, 150, 11, 220, 240, 14, 161, 45, 136, 250, 107, 22, 147, 157, 134,
   144, 53, 111, 189, 59, 72, 238, 135, 208, 136, 238, 60, 106, 160, 64, 138>>}
```

**`to_public_key/1`**

You can use the following function if you have a _private key_ and you want to derive a _public_ one.

```elixir
iex(2)> ExWallet.Keys.Pair.to_public_key(private_key)
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

### Keys.Master

**`create/1`**

Creates a master private key and a chain code from the given seed.

```elixir
iex(17)> master = ExWallet.Keys.Master.create(seed)
%ExWallet.Keys.Master{
  chain_code: <<131, 69, 235, 8, 98, 10, 186, 165, 132, 3, 72, 226, 215, 255,
    246, 149, 151, 252, 74, 61, 83, 136, 39, 206, 51, 173, 236, 87, 231, 172,
    120, 6>>,
  private_key: <<235, 156, 223, 236, 122, 159, 219, 74, 168, 63, 172, 58, 68,
    101, 64, 28, 150, 138, 86, 234, 43, 221, 144, 104, 203, 253, 54, 176, 112,
    214, 38, 163>>
}
```
