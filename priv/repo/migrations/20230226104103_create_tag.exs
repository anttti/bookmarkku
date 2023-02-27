defmodule Markku.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string

      timestamps()
    end

    create table(:bookmark_tags, primary_key: false) do
      add :bookmark_id, references(:bookmarks)
      add :tag_id, references(:tags)
    end
  end
end
