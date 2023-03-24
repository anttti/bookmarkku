defmodule Markku.Bookmarks do
  @moduledoc """
  The Bookmarks context.
  """

  import Ecto.Query, warn: false
  alias Markku.Repo

  alias Markku.Accounts.User
  alias Markku.Bookmarks.Bookmark

  @doc """
  Returns the list of bookmarks for a given user.
  """
  def list_bookmark(%User{} = user) do
    query =
      from b in Bookmark,
        order_by: [desc: :unread, desc: :inserted_at],
        preload: [:tags],
        where: b.user_id == ^user.id

    Repo.all(query)
  end

  @doc """
  Gets a single bookmark.

  Raises `Ecto.NoResultsError` if the Bookmark does not exist.
  """
  def get_bookmark!(%User{} = user, id) do
    Repo.get_by!(Bookmark, id: id, user_id: user.id)
  end

  @doc """
  Creates a bookmark.

  ## Examples

      iex> create_bookmark(%{field: value})
      {:ok, %Bookmark{}}

      iex> create_bookmark(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bookmark(attrs, tags) do
    %Bookmark{}
    |> Bookmark.create_changeset(attrs, tags)
    |> Repo.insert()
  end

  @doc """
  Updates a bookmark.

  ## Examples

      iex> update_bookmark(bookmark, %{field: new_value})
      {:ok, %Bookmark{}}

      iex> update_bookmark(bookmark, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bookmark(%Bookmark{} = bookmark, attrs) do
    bookmark
    |> Bookmark.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bookmark.

  ## Examples

      iex> delete_bookmark(bookmark)
      {:ok, %Bookmark{}}

      iex> delete_bookmark(bookmark)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bookmark(%Bookmark{} = bookmark) do
    Repo.delete(bookmark)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bookmark changes.

  ## Examples

      iex> change_bookmark(bookmark)
      %Ecto.Changeset{data: %Bookmark{}}

  """
  def change_bookmark(%Bookmark{} = bookmark, attrs \\ %{}) do
    Bookmark.changeset(bookmark, attrs)
  end

  def mark_unread(%User{} = user, id, unread) do
    {:ok, bookmark} = get_bookmark!(user.id, id) |> update_bookmark(%{unread: unread})

    Repo.preload(bookmark, :tags)
  end

  alias Markku.Bookmarks.Tag

  @doc """
  Returns all tags for a given user.
  """
  def list_tag(%User{} = user) do
    query =
      from t in Tag,
        order_by: [asc: :name],
        where: t.user_id == ^user.id

    Repo.all(query)
  end

  def search_tags(%User{} = user, term) do
    query =
      from t in Tag,
        where: ilike(t.name, ^"%#{String.replace(term, "%", "\\%")}%"),
        where: t.user_id == ^user.id,
        order_by: [asc: :name]

    Repo.all(query)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  def get_tags(ids) do
    query = from t in Tag, where: t.id in ^ids
    Repo.all(query)
  end

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end

  @doc """
  Gets or creates a list of tags.

  ## Examples

      iex> get_or_create_tags([1, 2, "new-tag"])
      [%Tag{}]
  """
  def get_or_create_tags(%User{} = user, tags) do
    existing_tags =
      Enum.filter(tags, fn id -> String.match?(id, ~r/^\d+$/) end)
      |> Markku.Bookmarks.get_tags()

    new_tags =
      Enum.filter(tags, fn id -> !String.match?(id, ~r/^\d+$/) end)
      |> Enum.map(fn name ->
        Markku.Bookmarks.create_tag(%{"name" => name, "user_id" => user.id})
      end)
      |> Enum.flat_map(&get_tag/1)

    existing_tags ++ new_tags
  end

  defp get_tag({:ok, tag}), do: [tag]
  defp get_tag(_), do: []
end
