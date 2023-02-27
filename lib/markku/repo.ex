defmodule Markku.Repo do
  use Ecto.Repo,
    otp_app: :markku,
    adapter: Ecto.Adapters.Postgres
end
