defmodule Markku.Repo.Migrations.AddOwnersToBookmarks do
  use Ecto.Migration

  def change do
    execute "DELETE FROM bookmarks"

    alter table(:bookmarks) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
