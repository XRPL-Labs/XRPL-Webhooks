defmodule Espy.Mixfile do
  use Mix.Project

  def project do
    [
      app: :espy,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Espy.Application, []},
      extra_applications: [:logger, :runtime_tools, :timex, :edeliver]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0.0"},
      {:ecto_sql, "~> 3.0-rc"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.14.1"},
      {:blue_bird, "~> 0.4.0"},
      {:websockex, "~> 0.4.2"},
      {:phoenix_html, "~> 2.10"},
      {:ex_machina, "~> 2.2", only: :test},
      {:phoenix_live_reload, "~> 1.2.0", only: :dev},
      {:poison, ">= 0.0.0"},
      {:binary, "0.0.4"},
      {:gen_stage, "~> 0.11"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 2.6.1"},
      {:secure_random, "~> 0.5"},
      {:comeonin, "~> 4.0"},
      {:hammer, "~> 6.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:ueberauth, "~> 0.3"},
      {:ueberauth_github, "~> 0.4"},
      {:ueberauth_twitter, "~> 0.2"},
      {:oauth, github: "tim/erlang-oauth"},
      {:timex, "~> 3.0"},
      {:logger_file_backend, "~> 0.0.10"},
      {:edeliver, ">= 1.6.0"},
      {:distillery, "~> 2.0", warn_missing: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  def blue_bird_info do
    [
      host: "https://webhook.casinocoin.services",
      title: "CSCL Webhook API",
      description: """
                  API requires authorization. All requests must have valid
                  `x-api-key` and `x-api-secret`.
                  """
    ]
  end
end
