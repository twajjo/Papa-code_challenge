defmodule CodeChallenge.Repo.Migrations.AddingCreditsToModelPerReqts do
  use Ecto.Migration

  def change do
    alter table("user") do
      add_if_not_exists(:credits, :integer, default: 0)
    end
  end
end
