defmodule Markku.BookmarksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Markku.Bookmarks` context.
  """

  @doc """
  Generate a bookmark.
  """
  def bookmark_fixture(attrs \\ %{}) do
    {:ok, bookmark} =
      attrs
      |> Enum.into(%{
        title: "some title",
        url: "some url"
      })
      |> Markku.Bookmarks.create_bookmark()

    bookmark
  end

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Markku.Bookmarks.create_tag()

    tag
  end
end
