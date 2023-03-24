defmodule MarkkuWeb.AddLive do
  use MarkkuWeb, :bare_live_view

  alias Markku.Bookmarks
  alias Markku.Bookmarks.Bookmark

  on_mount Markku.UserLiveAuth

  def mount(params, _session, socket) do
    changeset = Bookmarks.change_bookmark(%Bookmark{}, params)

    {:ok, assign(socket, page_title: "Add bookmark", form: to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} phx-submit="save" method="post">
      <.input field={@form[:url]} type="text" label="URL" required />
      <.input field={@form[:title]} type="text" label="Title" required />

      <:actions>
        <.button phx-disable-with="Saving...">Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  def handle_event("save", %{"bookmark" => bookmark_params}, socket) do
    case Bookmarks.create_bookmark(socket.assigns.current_user, bookmark_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bookmark created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
