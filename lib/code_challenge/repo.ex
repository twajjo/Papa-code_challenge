defmodule CodeChallenge.Repo do
  use Ecto.Repo,
    otp_app: :code_challenge,
    adapter: Ecto.Adapters.Postgres
end
