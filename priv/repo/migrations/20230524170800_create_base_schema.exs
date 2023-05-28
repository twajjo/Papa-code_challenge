defmodule CodeChallenge.Repo.Migrations.CreateBaseSchema do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:user, primary_key: true) do
      add(:first_name, :string)
      add(:last_name, :string)
      add(:email, :string)
      add(:credits, :integer, default: 0)
      timestamps(type: :utc_datetime_usec)
    end
    create_if_not_exists table(:visit, primary_key: true) do
      add(:date, :utc_datetime)
      add(:minutes, :integer)
      add(:tasks, :string, default: "")
      add(:member_id, references("user", type: :id, on_delete: :nilify_all))
      timestamps(type: :utc_datetime_usec)
    end
    create_if_not_exists table(:transaction, primary_key: true) do
      add(:member_id, references("user", type: :id, on_delete: :nilify_all))
      add(:pal_id, references("user", type: :id, on_delete: :nilify_all))
      add(:visit_id, references("visit", type: :id, on_delete: :nilify_all))
      timestamps(type: :utc_datetime_usec)
    end
    create index(:user, [:email], unique: true)
    create index(:user, [:last_name, :first_name], unique: false)
    create index(:visit, [:date], unique: false)
    create index(:transaction, [:visit_id], unique: true)
  end
end
