# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :espy,
  ecto_repos: [Espy.Repo]

# Configures the endpoint
config :espy, EspyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "U6rb9AJCDoSe1LtiNJOsLGzUW8+S60TApNALK1lnjems+w+yx3pcMD2d4dskTxax",
  render_errors: [view: EspyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Espy.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time [$level] $metadata $message\n",
  metadata: [:app_id, :user_id]

# Configures Blue Bird API Docs
config :blue_bird,
  docs_path: "assets/static/docs",
  theme: "streak",
  router: EspyWeb.Router

# Configures Ueberauth
config :ueberauth, Ueberauth,
  providers: [
    twitter: { Ueberauth.Strategy.Twitter, []},
    github: { Ueberauth.Strategy.Github, [default_scope: "user:email"] },
  ]

config :ueberauth, Ueberauth.Strategy.Twitter.OAuth,
  consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
  consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Config Rate Limiter
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4,
                                 cleanup_interval_ms: 60_000 * 10]}
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
