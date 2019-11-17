defmodule Espy.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Espy.Repo, []),
      # start watcher Socket
      supervisor(Espy.Watcher.Supervisor, []),
      # Start the endpoint when the application starts
      supervisor(EspyWeb.Endpoint, []),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, strategy: :one_for_one, name: Espy.Supervisor)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EspyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
