defmodule Espy.Watcher.Cache do
  use GenServer

  require Logger

  alias Espy.Gateway.{Subscription}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [
      {:ets_table_name, :watcher_cache_table},
      {:log_limit, 1_000_000}
    ], opts)
  end

  # Public
  #
  def fetch(slug) do
    case get(slug) do
      {:not_found} ->  :not_found
      {:found, result} -> result
    end
  end

  def delete(slug) do
    case GenServer.call(__MODULE__, {:delete, slug}) do
      true -> :ok
      _ -> :ok
    end
  end


  # Private

  defp get(slug) do
    case GenServer.call(__MODULE__, {:get, slug}) do
      [] -> {:not_found}
      [{_slug, result}] -> {:found, result}
    end
  end

  def set(slug, value) do
    GenServer.call(__MODULE__, {:set, slug, value})
  end

  # GenServer callbacks

  def handle_call({:get, slug}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    result = :ets.lookup(ets_table_name, slug)
    {:reply, result, state}
  end

  def handle_call({:set, slug, value}, _from, state) do
    Logger.info "Set cache #{slug}:#{value}"
    %{ets_table_name: ets_table_name} = state
    true = :ets.insert(ets_table_name, {slug, value})
    {:reply, value, state}
  end


  def handle_call({:delete, slug}, _from, state) do
    Logger.info "Delete cache key #{slug}"
    %{ets_table_name: ets_table_name} = state
    result = :ets.delete(ets_table_name, slug)
    {:reply, result, state}
  end


  def init(args) do
    [{:ets_table_name, ets_table_name}, {:log_limit, log_limit}] = args

    :ets.new(ets_table_name, [:named_table, :set, :private])


    Logger.info("Loading all Subscriptions to the cache...", ansi_color: :light_blue)
    Enum.each Subscription.get_all, fn(s) ->
      true = :ets.insert(ets_table_name, {s.address, s.app_id})
    end

    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name}}
  end
end
