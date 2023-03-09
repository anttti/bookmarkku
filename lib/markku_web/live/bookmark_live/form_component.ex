defmodule MarkkuWeb.BookmarkLive.FormComponent do
  use MarkkuWeb, :live_component

  alias Markku.Bookmarks
  alias Markku.Bookmarks.Fetcher

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="bookmark-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:url]}
          type="text"
          label="Url"
          phx-blur="fetch_meta"
          phx-target={@myself}
        />
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Bookmark</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{bookmark: bookmark} = assigns, socket) do
    changeset = Bookmarks.change_bookmark(bookmark)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("fetch_meta", %{"value" => url}, socket) do
    # TODO: Use Fetcher with Task.async to populate title and description (also show a spinner)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"bookmark" => bookmark_params}, socket) do
    changeset =
      socket.assigns.bookmark
      |> Bookmarks.change_bookmark(bookmark_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"bookmark" => bookmark_params}, socket) do
    save_bookmark(socket, socket.assigns.action, bookmark_params)
  end

  defp save_bookmark(socket, :edit, bookmark_params) do
    case Bookmarks.update_bookmark(socket.assigns.bookmark, bookmark_params) do
      {:ok, bookmark} ->
        notify_parent({:saved, bookmark})

        {:noreply,
         socket
         |> put_flash(:info, "Bookmark updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_bookmark(socket, :new, bookmark_params) do
    case Bookmarks.create_bookmark(bookmark_params) do
      {:ok, bookmark} ->
        notify_parent({:saved, bookmark})

        {:noreply,
         socket
         |> put_flash(:info, "Bookmark created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
