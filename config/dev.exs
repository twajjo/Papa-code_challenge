import Config

# Configure your database
config :code_challenge, CodeChallenge.Repo,
  username: "postgres",
  password: "Cran8Gat8",
  hostname: "localhost",
  database: "code_challenge_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Enable dev routes for dashboard and mailbox
config :code_challenge, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
