defmodule EspyWeb.WebhookController do
  use EspyWeb, :controller

  alias Espy.Gateway.{Webhook, App}

  alias Espy.Adapter.{HTTPC}

  alias Espy.Watcher.Mock

  def list(conn, %{"id" => id }) do
    user_id = conn.assigns.current_user.id
    app = App.get!(id, user_id)
    webhooks = Webhook.list(app.id)
    changeset = Webhook.change(%Webhook{})
    render(conn, "list.html", webhooks: webhooks, app: app,changeset: changeset)
  end

  def create(conn, %{"webhook" => %{"url" => url}} = params) do
    user_id = conn.assigns.current_user.id
    app = App.get!(Map.get(params, "id"), user_id)
    webhook = %{app_id: app.id, url: url, deleted: false}
    case Webhook.create(webhook) do
      {:ok, _webhook} ->
        conn
        |> put_flash(:info, "Webhook created successfully")
        |> redirect(to: webhook_path(conn, :list, app.app_id ))
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        conn
        |> put_flash(:error, "Please enter a valid webhook URL")
        |> redirect(to: webhook_path(conn, :list, app.app_id ))
    end
  end

  def delete(conn, %{"id" => id, "webhook_id" => webhook_id}) do
    user_id = conn.assigns.current_user.id
    app = App.get!(id, user_id)
    Webhook.delete(%{"hook_id": webhook_id, "app_id": app.id})
    redirect(conn, to: webhook_path(conn, :list, app.app_id))
  end

  def trigger(conn, %{"id" => id, "webhook_id" => webhook_id}) do
    user_id = conn.assigns.current_user.id
    app = App.get!(id, user_id)
    webhook = Webhook.get!(webhook_id, user_id)
    case Hammer.check_rate("webhook_trigger:#{user_id}", 60_000, 5) do
      {:allow, _count} ->
        tx = Mock.transaction
        Task.Supervisor.start_child(
            Espy.Supervisor.HTTPC,
            HTTPC,
            :call,
            [%{ url: webhook.url, body: tx ,callback: nil}]
        )
        conn
        |> put_flash(:info, "A sample POST request just sent to the webhook URL.")
        |> redirect(to: webhook_path(conn, :list, app.app_id))
      {:deny, _limit} ->
        conn
        |> put_flash(:error, "Rate limit exceeded, please wait while and try again.")
        |> redirect(to: webhook_path(conn, :list, app.app_id ))
    end
  end

end
