defmodule Markku.Bookmarks.Bookmark do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookmarks" do
    field :title, :string
    field :url, :string
    field :description, :string
    field :unread, :boolean
    many_to_many :tags, Markku.Bookmarks.Tag, join_through: "bookmark_tags"

    timestamps()
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:title, :url, :description, :unread])
    |> validate_required([:title, :url, :unread])
  end

  @doc false
  def create_changeset(bookmark, attrs, tags) do
    bookmark
    |> cast(attrs, [:title, :url, :description, :unread])
    |> put_assoc(:tags, tags)
    |> validate_required([:title, :url, :unread])
  end
end
