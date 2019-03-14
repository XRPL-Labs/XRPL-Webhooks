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

  def delete(slug, value) do
    case GenServer.call(__MODULE__, {:delete, slug, value}) do
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
    %{ets_table_name: ets_table_name} = state
    case :ets.lookup(ets_table_name, slug) do
      [] ->
        true = :ets.insert(ets_table_name, {slug, [value]})
      [{_slug, current}]  ->
        true = :ets.insert(ets_table_name, {slug, [ value | current ] })
    end

    {:reply, value, state}
  end


  def handle_call({:delete, slug, value}, _from, state) do
    %{ets_table_name: ets_table_name} = state
    case :ets.lookup(ets_table_name, slug) do
      [] -> true
      [{_slug, current}]  ->
        case length(current) do
          1 ->
            result = :ets.delete(ets_table_name, slug)
            {:reply, result, state}
          _ ->
            new_value = List.delete(current, value)
            :ets.insert(ets_table_name, {slug, new_value})
            {:reply, true, state}
        end
    end
  end


  def init(args) do
    [{:ets_table_name, ets_table_name}, {:log_limit, log_limit}] = args

    :ets.new(ets_table_name, [:named_table, :set, :private])

    Logger.info("Loading all Subscriptions to the cache...", ansi_color: :light_blue)
    Enum.each Subscription.get_all, fn(s) ->
      case :ets.lookup(ets_table_name, s.address) do
        [] ->
          true = :ets.insert(ets_table_name, {s.address, [s.app_id]})
        [{_slug, current}]  ->
          true = :ets.insert(ets_table_name, {s.address, [ s.app_id | current ] })
      end
    end

    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name}}
  end
end
