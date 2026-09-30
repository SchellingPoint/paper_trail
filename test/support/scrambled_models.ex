defmodule ScrambledType do
  @moduledoc """
  Stands in for an encryption type such as `Cloak.Ecto.Binary`: it embeds as
  itself, so `Ecto.embedded_dump/2` never calls `dump/1`, and `dump/1` returns
  bytes that are not valid UTF-8.
  """
  use Ecto.Type

  @impl true
  def type, do: :binary

  @impl true
  def embed_as(_format), do: :self

  @impl true
  def cast(value) when is_binary(value), do: {:ok, value}
  def cast(_), do: :error

  @impl true
  def dump(value) when is_binary(value), do: {:ok, <<0xFF>> <> String.reverse(value)}
  def dump(_), do: :error

  @impl true
  def load(<<0xFF, reversed::binary>>), do: {:ok, String.reverse(reversed)}
  def load(_), do: :error
end

defmodule ScrambledNote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scrambled_notes" do
    field(:title, :string)
    field(:secret, ScrambledType, source: :scrambled_secret)
  end

  def changeset(note, params), do: cast(note, params, [:title, :secret])
end
