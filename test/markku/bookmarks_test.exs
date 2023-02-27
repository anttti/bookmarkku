defmodule Markku.BookmarksTest do
  use Markku.DataCase

  alias Markku.Bookmarks

  describe "bookmark" do
    alias Markku.Bookmarks.Bookmark

    import Markku.BookmarksFixtures

    @invalid_attrs %{title: nil, url: nil}

    test "list_bookmark/0 returns all bookmark" do
      bookmark = bookmark_fixture()
      assert Bookmarks.list_bookmark() == [bookmark]
    end

    test "get_bookmark!/1 returns the bookmark with given id" do
      bookmark = bookmark_fixture()
      assert Bookmarks.get_bookmark!(bookmark.id) == bookmark
    end

    test "create_bookmark/1 with valid data creates a bookmark" do
      valid_attrs = %{title: "some title", url: "some url"}

      assert {:ok, %Bookmark{} = bookmark} = Bookmarks.create_bookmark(valid_attrs)
      assert bookmark.title == "some title"
      assert bookmark.url == "some url"
    end

    test "create_bookmark/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bookmarks.create_bookmark(@invalid_attrs)
    end

    test "update_bookmark/2 with valid data updates the bookmark" do
      bookmark = bookmark_fixture()
      update_attrs = %{title: "some updated title", url: "some updated url"}

      assert {:ok, %Bookmark{} = bookmark} = Bookmarks.update_bookmark(bookmark, update_attrs)
      assert bookmark.title == "some updated title"
      assert bookmark.url == "some updated url"
    end

    test "update_bookmark/2 with invalid data returns error changeset" do
      bookmark = bookmark_fixture()
      assert {:error, %Ecto.Changeset{}} = Bookmarks.update_bookmark(bookmark, @invalid_attrs)
      assert bookmark == Bookmarks.get_bookmark!(bookmark.id)
    end

    test "delete_bookmark/1 deletes the bookmark" do
      bookmark = bookmark_fixture()
      assert {:ok, %Bookmark{}} = Bookmarks.delete_bookmark(bookmark)
      assert_raise Ecto.NoResultsError, fn -> Bookmarks.get_bookmark!(bookmark.id) end
    end

    test "change_bookmark/1 returns a bookmark changeset" do
      bookmark = bookmark_fixture()
      assert %Ecto.Changeset{} = Bookmarks.change_bookmark(bookmark)
    end
  end

  describe "tag" do
    alias Markku.Bookmarks.Tag

    import Markku.BookmarksFixtures

    @invalid_attrs %{name: nil}

    test "list_tag/0 returns all tag" do
      tag = tag_fixture()
      assert Bookmarks.list_tag() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Bookmarks.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Tag{} = tag} = Bookmarks.create_tag(valid_attrs)
      assert tag.name == "some name"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bookmarks.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Tag{} = tag} = Bookmarks.update_tag(tag, update_attrs)
      assert tag.name == "some updated name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Bookmarks.update_tag(tag, @invalid_attrs)
      assert tag == Bookmarks.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Bookmarks.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Bookmarks.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Bookmarks.change_tag(tag)
    end
  end
end
