defmodule Markku.Bookmarks.Bookmark do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmarks" do
    field :title, :string
    field :url, :string
    many_to_many :tags, Markku.Bookmarks.Tag, join_through: "bookmark_tags"

    timestamps()
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:title, :url])
    # |> cast_assoc(:tags, required: true)
    |> validate_required([:title, :url])
  end
end
