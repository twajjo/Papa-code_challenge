import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :code_challenge, CodeChallenge.Repo,
  username: "postgres",
  password: "Cran8Gat8",
  hostname: "localhost",
  database: "code_challenge_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :code_challenge,
  code_challenge_domain_fulfillment_impl: CodeChallenge.Domain.Fulfillment.Mock,
  code_challenge_domain_membership_impl: CodeChallenge.Domain.Membership.Mock,
  code_challenge_domain_request_impl: CodeChallenge.Domain.Request.Mock

# Print only warnings and errors during test
config :logger, level: :warning
