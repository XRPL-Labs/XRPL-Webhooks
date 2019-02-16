use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :espy, EspyWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :espy, Espy.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PGSQL_TEST_USERNAME"),
  password: System.get_env("PGSQL_TEST_PASSWORD"),
  database: System.get_env("PGSQL_TEST_DATABASE"),
  hostname: System.get_env("PGSQL_TEST_HOSTNAME"),
  pool: Ecto.Adapters.SQL.Sandbox
