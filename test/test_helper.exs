CodeChallenge.Repo.start_link(pool_size: 5)
Ecto.Adapters.SQL.Sandbox.mode(CodeChallenge.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
