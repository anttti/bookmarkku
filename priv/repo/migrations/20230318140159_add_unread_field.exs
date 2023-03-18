defmodule Markku.Repo.Migrations.AddUnreadField do
  use Ecto.Migration

  def change do
    alter table(:bookmarks) do
      add :unread, :boolean, default: true
    end
  end
end
