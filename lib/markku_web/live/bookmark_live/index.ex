defmodule MarkkuWeb.BookmarkLive.Index do
  use MarkkuWeb, :live_view

  import LiveSelect

  alias Markku.Bookmarks
  alias Markku.Bookmarks.Bookmark
  alias Markku.Bookmarks.Fetcher

  on_mount Markku.UserLiveAuth

  @impl true
  def mount(_params, _session, socket) do
    changeset = Bookmarks.change_bookmark(%Bookmark{tags: []})

    {:ok,
     socket
     |> assign(
       loading?: false,
       inputs_disabled?: true,
       server_url: Application.get_env(:markku, :server_url)
     )
     |> assign_form(changeset)
     |> stream(:bookmark_collection, Bookmarks.list_bookmark(socket.assigns.current_user))}
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
    save_bookmark(socket, bookmark_params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmark = Bookmarks.get_bookmark!(socket.assigns.current_user, id)
    {:ok, _} = Bookmarks.delete_bookmark(bookmark)

    {:noreply, stream_delete(socket, :bookmark_collection, bookmark)}
  end

  @impl true
  def handle_event("mark-read", %{"id" => id}, socket) do
    bookmark = Bookmarks.mark_unread(socket.assigns.current_user, id, false)
    {:noreply, stream_insert(socket, :bookmark_collection, bookmark)}
  end

  @impl true
  def handle_event("mark-unread", %{"id" => id}, socket) do
    bookmark = Bookmarks.mark_unread(socket.assigns.current_user, id, true)
    {:noreply, stream_insert(socket, :bookmark_collection, bookmark)}
  end

  @impl true
  def handle_event("live_select_change", %{"text" => text, "id" => live_select_id}, socket) do
    options = Markku.Bookmarks.search_tags(text)

    send_update(LiveSelect.Component,
      id: live_select_id,
      options: Enum.map(options, fn o -> {o.name, o.id} end)
    )

    {:noreply, socket}
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

  defp save_bookmark(socket, bookmark_params) do
    bookmark_params =
      Map.put(bookmark_params, "unread", true)
      |> Map.put("user_id", socket.assigns.current_user.id)

    tags = Bookmarks.get_or_create_tags(bookmark_params["tags_search"])
    IO.inspect(tags)

    case Bookmarks.create_bookmark(bookmark_params, tags) do
      {:ok, bookmark} ->
        {:noreply,
         socket
         |> stream_insert(:bookmark_collection, bookmark, at: 0)
         |> put_flash(:info, "Bookmark created successfully")
         |> push_patch(to: ~p"/bookmark")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect("Error!")
        IO.inspect(changeset)
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Bookmark")
    |> assign(:bookmark, Bookmarks.get_bookmark!(socket.assigns.current_user, id))
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
