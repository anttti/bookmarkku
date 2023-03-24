defmodule Markku.Repo.Migrations.AddOwnersToBookmarks do
  use Ecto.Migration

  def change do
    alter table(:bookmarks) do
      add :user_id, references(:users), null: false
    end
  end
end
