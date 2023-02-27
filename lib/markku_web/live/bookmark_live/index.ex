defmodule MarkkuWeb.BookmarkLive.Index do
  use MarkkuWeb, :live_view

  alias Markku.Bookmarks
  alias Markku.Bookmarks.Bookmark

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :bookmark_collection, Bookmarks.list_bookmark())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bookmark")
    |> assign(:bookmark, Bookmarks.get_bookmark!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bookmark")
    |> assign(:bookmark, %Bookmark{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bookmark")
    |> assign(:bookmark, nil)
  end

  @impl true
  def handle_info({MarkkuWeb.BookmarkLive.FormComponent, {:saved, bookmark}}, socket) do
    {:noreply, stream_insert(socket, :bookmark_collection, bookmark)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmark = Bookmarks.get_bookmark!(id)
    {:ok, _} = Bookmarks.delete_bookmark(bookmark)

    {:noreply, stream_delete(socket, :bookmark_collection, bookmark)}
  end
end
