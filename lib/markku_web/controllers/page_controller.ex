defmodule MarkkuWeb.PageController do
  use MarkkuWeb, :controller

  def home(%Plug.Conn{assigns: %{current_user: nil}} = conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def home(%Plug.Conn{assigns: %{current_user: _}} = conn, _params) do
    # Redirect a logged in user to the bookmarks list view from the landing page
    redirect(conn, to: ~p"/bookmark")
  end
end
