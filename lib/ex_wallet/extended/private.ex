defmodule ExWallet.Extended.Private do
  alias ExWallet.{KeyPair, Extended.Public}

  defstruct network: :main,
            version_number: nil,
            key: nil,
            chain_code: <<0>>,
            depth: 0,
            fingerprint: <<0::32>>,
            child_number: 0

  @version_numbers %{
    main: <<4, 136, 173, 228>>,
    test: <<4, 53, 131, 148>>
  }

  def new(
        network,
        key,
        chain_code \\ <<0>>,
        depth \\ 0,
        fingerprint \\ <<0::32>>,
        child_number \\ 0
      ) do
    %__MODULE__{
      network: network,
      version_number: @version_numbers[network],
      key: key,
      chain_code: chain_code,
      depth: depth,
      fingerprint: fingerprint,
      child_number: child_number
    }
  end

  def to_public(%__MODULE__{
        network: network,
        key: key,
        chain_code: chain_code,
        depth: depth,
        fingerprint: fingerprint,
        child_number: child_number
      }) do
    Public.new(
      network,
      KeyPair.to_public_key(key),
      chain_code,
      depth,
      fingerprint,
      child_number
    )
  end
end
