defmodule Espy.Watcher.Socket do
  require Logger
  use WebSockex

  alias Espy.Watcher.{Handler}


  @urls         ["wss://rippled.xrptipbot.com:443", "wss://s1.ripple.com:443"]
  @command     "subscribe"
  @streams     ["transactions"]
  @only_handle ["Payment"]

  def start_link(_opts \\ []) do
    queue =  @urls |> :queue.from_list
    {{:value, url}, queue} = :queue.out(queue)
    queue = :queue.in(url, queue)
    WebSockex.start_link(url, __MODULE__, %{queue: queue, url: url},[name: __MODULE__, handle_initial_conn_failure: true])
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

  def handle_connect(_conn, %{url: url} = state) do
    Logger.info "Connected to ripple server #{String.upcase(url)}", ansi_color: :green
    subscribe_to_streams self()
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


  def handle_disconnect(%{reason: {:local, reason}}, %{timer_ref: timer_ref} = state) do
    cancel_timer(timer_ref)
    Logger.info("Local close with reason: #{inspect reason}")
    Logger.info("Reconnecting...")
    {:reconnect, state}
  end

  def handle_disconnect(%{reason: reson, conn: conn, attempt_number: attempt_number }, %{url: url, timer_ref: timer_ref} = state) when attempt_number < 5 do
    cancel_timer(timer_ref)
    Logger.info "Cannot Connect to #{String.upcase(url)} attempt #{attempt_number}", ansi_color: :red
    Logger.info("Retring after 3 sec ...")
    :timer.sleep(3000)
    {:reconnect, conn, state}
  end

  def handle_disconnect(%{reason: reson, conn: connn, attempt_number: attempt_number }, %{queue: queue} = state) do
    {{:value, head}, queue} = :queue.out(queue)
    Logger.info "Switching the endpoint #{head}", ansi_color: :red
    conn = WebSockex.Conn.new(head)
    queue = :queue.in(head, queue)

    state = Map.put(state, :queue, queue)
    state = Map.put(state, :url, head)

    {:reconnect, conn, state}
  end


  def terminate(reason, state) do
    Logger.info("Socket terminated with: #{inspect reason}")
    exit(:normal)
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
    Task.start fn -> WebSockex.send_frame(pid, {:text, data}) end
  end

end
