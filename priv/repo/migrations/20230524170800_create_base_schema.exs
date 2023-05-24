defmodule CodeChallenge.Repo.Migrations.CreateBaseSchema do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:user, primary_key: false) do
      add(:id, :integer, primary_key: true)
      add(:first_name, :string)
      add(:last_name, :string)
      add(:email, :string)
      timestamps(type: :utc_datetime_usec)
    end
    create_if_not_exists table(:visit, primary_key: false) do
      add(:id, :integer, primary_key: true)
      add(:date, :utc_datetime)
      add(:minutes, :integer)
      add(:member_id, references("user", type: :integer, on_delete: :nilify_all))
      timestamps(type: :utc_datetime_usec)
    end
    create_if_not_exists table(:transaction, primary_key: false) do
      add(:id, :integer, primary_key: true)
      add(:member_id, references("user", type: :integer, on_delete: :nilify_all))
      add(:pal_id, references("user", type: :integer, on_delete: :nilify_all))
      add(:visit_id, references("visit", type: :integer, on_delete: :nilify_all))
      timestamps(type: :utc_datetime_usec)
    end
    create index(:user, [:email], unique: true)
    create index(:user, [:last_name, :first_name], unique: false)
    create index(:visit, [:date], unique: false)
  end
end
