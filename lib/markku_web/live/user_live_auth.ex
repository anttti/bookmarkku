defmodule Markku.UserLiveAuth do
  import Phoenix.Component
  import Phoenix.LiveView
  alias Markku.Accounts

  def on_mount(:default, _params, %{"user_token" => user_token} = _session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        Accounts.get_user_by_session_token(user_token)
      end)

    # if socket.assigns.current_user.confirmed_at do
    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/login")}
    end
  end
end
