defmodule MarkkuWeb.BookmarkLive.FormComponent do
  use MarkkuWeb, :live_component

  alias Markku.Bookmarks

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <h1><%= if @loading?, do: "loading", else: "idle" %></h1>

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
        <div>
          <%= @form.params["title"] %>
        </div>
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
    assigns = Map.put(assigns, :loading?, false)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("fetch_meta", %{"value" => url}, socket) do
    task_ref =
      Task.async(fn ->
        # Fetcher.fetch_title(url)
        url
      end)

    {:noreply, socket |> assign(loading?: true, task_ref: task_ref)}
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

  def handle_info({ref, result}, %{assigns: %{task_ref: ref}} = socket) do
    Process.demonitor(ref, [:flush])
    IO.puts("RESULT")
    IO.inspect(result)
    # [title, description] = result
    # {:noreply, assign(socket, loading?: false, title: title, description: description)}
    {:noreply, assign(socket, loading?: false)}
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
