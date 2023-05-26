defmodule CodeChallenge.Repo.Migrations.UniqueIndexOnTransaction do
  use Ecto.Migration

  def change do
    create_if_not_exists index(:transaction, [:visit_id], unique: true)
  end
end
