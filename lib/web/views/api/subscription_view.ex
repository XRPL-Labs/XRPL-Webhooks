
defmodule EspyWeb.Api.SubscriptionView do
  use EspyWeb, :view
  alias EspyWeb.Api.SubscriptionView

  def render("index.json", %{app_id: app_id, subscriptions: subscriptions}) do
    %{
      app_id: app_id,
      subscriptions: render_many(subscriptions, SubscriptionView, "subscription.json")
    }
  end

  def render("show.json", %{subscription: subscription}) do
    render_one(subscription, SubscriptionView, "subscription.json")
  end

  def render("subscription.json", %{subscription: subscription}) do
    %{id: subscription.subscription_id,
      address: subscription.address,
      created_at: subscription.inserted_at
    }
  end
end
