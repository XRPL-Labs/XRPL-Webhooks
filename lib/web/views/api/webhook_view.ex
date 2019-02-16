
defmodule EspyWeb.Api.WebhookView do
  use EspyWeb, :view
  alias EspyWeb.Api.WebhookView

  def render("index.json", %{app_id: app_id, webhooks: webhooks}) do
    %{
      app_id: app_id,
      webhooks: render_many(webhooks, WebhookView, "webhook.json")
    }
  end

  def render("show.json", %{webhook: webhook}) do
    %{data: render_one(webhook, WebhookView, "webhook.json")}
  end

  def render("webhook.json", %{webhook: webhook}) do
    %{id: webhook.hook_id,
      url: webhook.url,
      active: !webhook.deactivated,
      created_at: webhook.inserted_at
    }
  end
end
