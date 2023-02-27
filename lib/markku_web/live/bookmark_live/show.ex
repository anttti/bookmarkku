defmodule MarkkuWeb.BookmarkLive.Show do
  use MarkkuWeb, :live_view

  alias Markku.Bookmarks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:bookmark, Bookmarks.get_bookmark!(id))}
  end

  defp page_title(:show), do: "Show Bookmark"
  defp page_title(:edit), do: "Edit Bookmark"
end
