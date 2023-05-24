defmodule CodeChallenge.Repo.Migrations.ForgotTasksSoAddEm do
  use Ecto.Migration

  def change do
    alter table("visit") do
      add_if_not_exists(:tasks, :string, default: "")
    end
  end
end
