defmodule Espy.Adapter.WebSocket do
  @moduledoc """
  CasinoCoin WebSocket client.

  Behind the scenes, this module uses :websocket_client erlang libray.
  """

  import Logger, only: [info: 1, warn: 1]

  def send_command(client, command, args) do
    Process.whereis(client)
    |> :websocket_client.send({:text, encode(command, args)})
  end

  def cast_command(client, command, args) do
    Process.whereis(client)
    |> :websocket_client.cast({:text, encode(command, args)})
  end

  def encode(command, args) do
    Poison.encode!(Map.merge(%{command: command}, args))
  end

  defmacro __using__(_params) do
    quote do
      @behaviour :websocket_client
      @test_net false
      @url "wss://" <> (@test_net && "wst01.casinocoin.org:4443" || "ws01.casinocoin.org:4443")
      @ping_interval 5_000

      ## API
      def start_link(args \\ %{}) do
        :crypto.start()
        :ssl.start()
        {:ok, pid} = :websocket_client.start_link(@url, __MODULE__, [], [])
        Process.register(pid, __MODULE__)
        {:ok, pid}
      end

      def start_link(args, _), do: start_link(args)

            ## Callbacks
      def init(args) do
        {:ok, args}
      end

      def onconnect(_ws_req, state) do
        info("#{__MODULE__} connected")
        {:ok, state}
      end

      def ondisconnect(:normal, state) do
        info("#{__MODULE__} disconnected with reason :normal")
        {:ok, state}
      end

      def ondisconnect(reason, state) do
        warn("#{__MODULE__} disconnected: #{inspect reason}. Reconnecting")
        {:reconnect, state}
      end

      def websocket_handle({:pong, _}, _conn_state, state) do
        {:ok, state}
      end

      def websocket_handle(msg, _conn_state, state) do
        with {:text, text} <- msg,
             {:ok, resp}   <- Poison.Parser.parse(text) do
              handle_response(resp)
        else
          e ->
            warn("#{__MODULE__} received unexpected response: #{inspect e}")
        end
        {:ok, state}
      end

      def websocket_info(msg, _conn_state, state) do
        warn("#{__MODULE__} received unexpected erlang msg: #{inspect msg}")
        {:ok, state}
      end

      def websocket_terminate(reason, _conn_state, state) do
        warn("#{__MODULE__} closed in state #{inspect state} " <>
             "with reason #{inspect reason}")
        :ok
      end

      def handle_response(resp) do
        info("#{__MODULE__} received response: #{inspect resp}")
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end

end

