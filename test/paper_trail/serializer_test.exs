defmodule PaperTrail.SerializerTest do
  use ExUnit.Case, async: false

  alias PaperTrail.Serializer

  @note %ScrambledNote{id: 1, title: "Plan", secret: "launch code"}
  @dumped Base.encode64(<<0xFF>> <> String.reverse("launch code"))

  describe "with ScrambledType in :dumped_types" do
    setup do
      Application.put_env(:paper_trail, :dumped_types, [ScrambledType])
      on_exit(fn -> Application.delete_env(:paper_trail, :dumped_types) end)
    end

    test "serialize/1 stores the dumped value under the column name" do
      assert Serializer.serialize(@note)[:scrambled_secret] == @dumped
    end

    test "serialize/1 leaves other fields as they were" do
      assert Serializer.serialize(@note)[:title] == "Plan"
    end

    test "serialize/1 keeps a nil value nil" do
      assert Serializer.serialize(%{@note | secret: nil})[:scrambled_secret] == nil
    end

    test "serialize_changes/1 stores the dumped value under the field name" do
      changeset = ScrambledNote.changeset(%ScrambledNote{id: 1}, %{secret: "launch code"})

      assert Serializer.serialize_changes(changeset) == %{secret: @dumped}
    end

    test "the stored value loads back to the original" do
      {:ok, loaded} =
        Serializer.serialize(@note)[:scrambled_secret]
        |> Base.decode64!()
        |> ScrambledType.load()

      assert loaded == "launch code"
    end
  end

  describe "without :dumped_types" do
    test "serialize/1 stores the value as Ecto.embedded_dump/2 does" do
      assert Serializer.serialize(@note)[:scrambled_secret] == "launch code"
    end
  end
end
