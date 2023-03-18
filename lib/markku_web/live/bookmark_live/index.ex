defmodule MarkkuWeb.BookmarkLive.Index do
  use MarkkuWeb, :live_view

  alias Markku.Bookmarks
  alias Markku.Bookmarks.Bookmark
  alias Markku.Bookmarks.Fetcher

  @impl true
  def mount(_params, _session, socket) do
    changeset = Bookmarks.change_bookmark(%Bookmark{})

    {:ok,
     socket
     |> assign(loading?: false, inputs_disabled?: true)
     |> assign_form(changeset)
     |> stream(:bookmark_collection, Bookmarks.list_bookmark())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("validate", %{"bookmark" => bookmark_params}, socket) do
    changeset =
      socket.assigns.bookmark
      |> Bookmarks.change_bookmark(bookmark_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("fetch_meta", %{"value" => ""}, socket) do
    # Don't do any fetching when value is "". This happens once every time
    # the live view opens
    {:noreply, socket}
  end

  @impl true
  def handle_event("fetch_meta", %{"value" => url}, socket) do
    task_ref =
      Task.async(fn ->
        Fetcher.fetch_title(url)
      end)

    {:noreply, socket |> assign(loading?: true, inputs_disabled?: true, task_ref: task_ref)}
  end

  @impl true
  def handle_event("save", %{"bookmark" => bookmark_params}, socket) do
    save_bookmark(socket, socket.assigns.action, bookmark_params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmark = Bookmarks.get_bookmark!(id)
    {:ok, _} = Bookmarks.delete_bookmark(bookmark)

    {:noreply, stream_delete(socket, :bookmark_collection, bookmark)}
  end

  @impl true
  def handle_info({ref, [title, description]}, socket) do
    Process.demonitor(ref, [:flush])

    changeset =
      socket.assigns.bookmark
      |> Bookmarks.change_bookmark(%{
        title: title,
        description: description,
        url: socket.assigns.form.params["url"]
      })

    {:noreply,
     assign(socket, loading?: false, inputs_disabled?: false)
     |> assign_form(changeset)
     |> push_event("fetched", %{title: title, description: description})}
  end

  defp save_bookmark(socket, :new, bookmark_params) do
    case Bookmarks.create_bookmark(bookmark_params) do
      {:ok, bookmark} ->
        {:noreply,
         socket
         |> stream_insert(:bookmark_collection, bookmark)
         |> put_flash(:info, "Bookmark created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
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
    |> assign(:page_title, "Bookmarks")
    |> assign(:bookmark, nil)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
