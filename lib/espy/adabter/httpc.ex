defmodule Espy.Adapter.HTTPC do
  require Logger

  alias Espy.Watcher.{Logging}
  alias Espy.Gateway.{Webhook}

  @default_http_opts timeout: 10000, connect_timeout: 10000, autoredirect: false
  @headers %{"Content-Type" => "application/json"}
  @method :post
  @delay 2000


  defp to_charlist_headers(headers) do
    for {key, value} <- headers, do: {to_charlist(key), to_charlist(value)}
  end

  defp build_request(_method, url, headers, body) do
    content_type = Map.get(headers, "Content-Type") |> to_charlist()
    {url, headers} = build_request(url, headers)
    body = Poison.encode!(body)
    {url, headers, content_type, body}
  end

  defp build_request(url, headers) do
    {url |> URI.encode() |> to_charlist(), to_charlist_headers(headers)}
  end

  defp publish(request) do
      :httpc.request(@method, request, @default_http_opts,[])
  end


  defp retry(pid, last_status \\ 0, last_response_time \\ 0) do
    Agent.update(pid, &Map.update(&1, :retries, 0, fn c -> c + 1 end))
    Agent.update(pid, &Map.put(&1, :last_status, last_status))
    Agent.update(pid, &Map.put(&1, :last_response_time, last_response_time))
    :timer.sleep(@delay)
  end

  def call(req) do
    %{body: body, url: url, callback: callback } = req
    request = build_request(@method, url, @headers, body)

    # CREATE AGENT FOR RETYR STATE
    {:ok, pid} = Agent.start_link(fn -> %{:retries => 1, :last_status => 0, :last_response_time => 0} end)

    try do
      for x <- [1, 2, 3] do
        if ( retries = Agent.get(pid, &Map.get(&1, :retries)) ) < 3 do
          case :timer.tc(&publish/1, [request]) do
            {time, {:ok, {{_, code, msg}, _headers, body}}} ->
              case div(code, 100) do
                2 -> throw({:break , {:ok, code , time, retries, callback}}) # SUCCESS
                _ -> retry(pid, code, time)
              end
            {time, {:error, reason}} -> retry(pid)
          end
        else
          agent = Agent.get(pid, & &1)
          throw({:break, {:error, agent.last_status, agent.last_response_time, agent.retries,callback}})
        end
      end
    catch
      {:break, return} ->
      Agent.stop(pid)
      if callback do
        return |> handle_callback
      end
    end
  end


  # handle HTTPC callback
  def handle_callback({:ok, staus_code, response_time, retries, callback}) do
    Logging.create_log(%{
      response_time: response_time,
      response_status: staus_code,
      retry_count: retries,
      object_id: callback.object,
      webhook_id: callback.webhook,
      app_id: callback.app
    })
    Webhook.set_failed_count(callback.webhook, 0)
  end

  def handle_callback({:error, staus_code, response_time, retries, callback}) do
    Logging.create_log(%{
      response_time: response_time,
      response_status: staus_code,
      retry_count: retries,
      object_id: callback.object,
      webhook_id: callback.webhook,
      app_id: callback.app
    })
    with {_,[c]} <- Webhook.increase_failed_count(callback.webhook) do
      if c > 20 do
        Webhook.deactivate(callback.webhook, "TOO MUCH FAILED REQUEST")
      end
    end
  end



end
