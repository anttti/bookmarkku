defmodule Markku.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string

      timestamps()
    end

    create table(:bookmark_tags, primary_key: false) do
      add :bookmark_id, references(:bookmarks, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)
    end
  end
end
