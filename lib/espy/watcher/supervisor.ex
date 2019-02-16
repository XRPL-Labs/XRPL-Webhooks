defmodule Espy.Watcher.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(Espy.Watcher.Socket, [[name: Espy.Watcher.Socket]]),
      worker(Espy.Watcher.Cache, [[name: Espy.Watcher.Cache]]),
      worker(Task.Supervisor, [[name: Espy.Supervisor.Handler]], id: :handler),
      worker(Task.Supervisor, [[name: Espy.Supervisor.HTTPC]], id: :httpc)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
