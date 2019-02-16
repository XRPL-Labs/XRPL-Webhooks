defmodule Espy.Watcher.Socket do

  require Logger

  use WebSockex

  alias Espy.Watcher.{Handler}


  @url         "wss://s1.ripple.com:443"
  @command     "subscribe"
  @streams     ["transactions"]
  @only_handle ["Payment"]

  def start_link(_opts \\ []) do
    {:ok, pid } = WebSockex.start_link(@url, __MODULE__, %{},[name: __MODULE__])
    subscribe_to_streams(pid)
    {:ok, pid}
  end


  defp filter_transaction(parsed) do
    try do
      transaction = Map.get(parsed, "transaction")
      engine_result = Map.get(parsed, "engine_result")

      cond do
        engine_result == "tesSUCCESS" ->
          case Map.get(transaction,"TransactionType") in @only_handle do
            true -> parsed
            _ -> :no_handler
          end
        true -> :no_handler
      end
    rescue
      _ -> IO.inspect "error"

    end
  end


  defp pass_to_handler(raw) do
    with {:ok , parsed } = {:ok, %{}} <-  Poison.Parser.parse(raw) do
      case filter_transaction(parsed) do
        :no_handler -> true
        tx ->
          {:ok, pid } = Task.Supervisor.start_child(
            Espy.Supervisor.Handler,
            Handler,
            :handle,
            [tx]
          )
          Logger.info "Handle: #{tx["transaction"]["hash"]} on #{Kernel.inspect pid}", ansi_color: :light_black
      end
    else
      {:error, reason} -> Logger.error reason
    end
  end


  def handle_discounnet(_conn, state) do
    Logger.info "Disconnected from #{String.upcase(@url)}", ansi_color: :red
    {:ok, state}
  end

  def handle_connect(_conn, state) do
    Logger.info "Connected to ripple server #{String.upcase(@url)}", ansi_color: :green
    timer_ref = Process.send_after(self(), :timeout, 20000)
    {:ok, Map.put(state, :timer_ref, timer_ref)}
  end

  def handle_frame({type, msg}, %{timer_ref: timer_ref} = state) do
    cancel_timer(timer_ref)
    pass_to_handler msg
    new_timer_ref = Process.send_after(self(), :timeout, 20000)
    {:ok, %{state | timer_ref: new_timer_ref}}
  end

  def handle_info(:timeout, state) do
    {:close, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    {:reply, frame, state}
  end


  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect reason}")
    Logger.info("Reconnecting...")
    {:reconnect, state}
  end

  defp cancel_timer(ref) do
    case Process.cancel_timer(ref) do
    i when is_integer(i) -> :ok
    false ->
      receive do
        :timeout -> :ok
      after
        0 -> :ok
      end
    end
  end

  def subscribe_to_streams(pid) do
    Logger.info("Sending subscribe request: streams=#{@streams}", ansi_color: :light_blue)
    data = %{command: @command, streams: @streams} |> Poison.encode!()
    WebSockex.send_frame(pid, {:text, data})
  end


end
