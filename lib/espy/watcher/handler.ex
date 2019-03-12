defmodule Espy.Watcher.Handler do
  require Logger

  alias Espy.Gateway.{App, Webhook, Subsciption}
  alias Espy.Watcher.{Cache, Logging}
  alias Espy.Adapter.{HTTPC}

  defp send_hook(webhooks , tx) do
    webhooks
    |> Enum.each(
      fn w ->
        {:ok, pid } = Task.Supervisor.start_child(
            Espy.Supervisor.HTTPC,
            HTTPC,
            :call,
            [%{ url: w.url, body: tx, callback: %{webhook: w.id, app: w.app_id, object: tx["transaction"]["hash"] }}]
        )
        Logger.info "Request: #{w.url} on #{Kernel.inspect pid} - [ Parent: #{Kernel.inspect self()}]",  ansi_color: :cyan
      end
    )
  end

  defp check(address) do
    case Cache.fetch(address) do
      :not_found -> :not_found
      app_ids ->
        Enum.reduce(app_ids, [],
          fn v, n ->
            case App.get(v) do
              nil ->
                # App is not active then remove the Subsciption from cache
                Cache.delete(address, v)
                n
              app -> n ++ [app.id]
            end
          end
        )
    end
  end

  defp get_availables(tx) do
    Enum.reduce([get_in(tx, ["transaction","Account"]), get_in(tx, ["transaction","Destination"])], [] ,
      fn v, n ->
        case check(v) do
          :not_found -> n
          app_ids -> n ++ app_ids
        end
      end
    )
  end

  def handle(tx) do
    # :timer.sleep(4000)
    case get_availables tx do
      [] -> true
      app_ids ->
        case Webhook.list_by_apps Enum.uniq(app_ids) do
          [] -> :no_webhook
            # Cache.delete(get_in(tx, ["transaction","Account"]))
            # Cache.delete(get_in(tx, ["transaction","Destination"]))
          webhooks -> send_hook(webhooks, tx)
        end
    end
  end

end
