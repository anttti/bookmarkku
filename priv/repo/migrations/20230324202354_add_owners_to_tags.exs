defmodule Markku.Repo.Migrations.AddOwnersToTags do
  use Ecto.Migration

  def change do
    execute "DELETE FROM tags"

    alter table(:tags) do
      add :user_id, references(:users), null: false
    end
  end
end
