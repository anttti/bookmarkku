defmodule Markku.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MarkkuWeb.Telemetry,
      Markku.Repo,
      {Phoenix.PubSub, name: Markku.PubSub},
      {Finch, name: Markku.Finch},
      MarkkuWeb.Endpoint
      # Start a worker by calling: Markku.Worker.start_link(arg)
      # {Markku.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Markku.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MarkkuWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
