defmodule MarkkuWeb.TagLiveTest do
  use MarkkuWeb.ConnCase

  import Phoenix.LiveViewTest
  import Markku.BookmarksFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_tag(_) do
    tag = tag_fixture()
    %{tag: tag}
  end

  describe "Index" do
    setup [:create_tag]

    test "lists all tag", %{conn: conn, tag: tag} do
      {:ok, _index_live, html} = live(conn, ~p"/tag")

      assert html =~ "Listing Tag"
      assert html =~ tag.name
    end

    test "saves new tag", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tag")

      assert index_live |> element("a", "New Tag") |> render_click() =~
               "New Tag"

      assert_patch(index_live, ~p"/tag/new")

      assert index_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tag-form", tag: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tag")

      html = render(index_live)
      assert html =~ "Tag created successfully"
      assert html =~ "some name"
    end

    test "updates tag in listing", %{conn: conn, tag: tag} do
      {:ok, index_live, _html} = live(conn, ~p"/tag")

      assert index_live |> element("#tag-#{tag.id} a", "Edit") |> render_click() =~
               "Edit Tag"

      assert_patch(index_live, ~p"/tag/#{tag}/edit")

      assert index_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tag-form", tag: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tag")

      html = render(index_live)
      assert html =~ "Tag updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes tag in listing", %{conn: conn, tag: tag} do
      {:ok, index_live, _html} = live(conn, ~p"/tag")

      assert index_live |> element("#tag-#{tag.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tag-#{tag.id}")
    end
  end

  describe "Show" do
    setup [:create_tag]

    test "displays tag", %{conn: conn, tag: tag} do
      {:ok, _show_live, html} = live(conn, ~p"/tag/#{tag}")

      assert html =~ "Show Tag"
      assert html =~ tag.name
    end

    test "updates tag within modal", %{conn: conn, tag: tag} do
      {:ok, show_live, _html} = live(conn, ~p"/tag/#{tag}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tag"

      assert_patch(show_live, ~p"/tag/#{tag}/show/edit")

      assert show_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#tag-form", tag: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tag/#{tag}")

      html = render(show_live)
      assert html =~ "Tag updated successfully"
      assert html =~ "some updated name"
    end
  end
end
