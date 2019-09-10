defmodule EspyWeb.Api.SubscriptionController do
  use EspyWeb, :controller

  alias Espy.Gateway.{Webhook, Subscription}

  alias Espy.Watcher.{Cache}

  apigroup("Subscriptions", "")

  api :POST, "/api/v1/subscriptions" do
    title "Subscribes address to app"
    description "Subscribes the provided app all events for the provided address for all transaction types. After activation, all transactions for the requesting address will be sent to the provided webhook id via POST request."
    parameter :address, :string, [description: "Valid XRP address"]
  end

  def create(conn, %{"address" => address}) do
    app = conn.assigns.app

    case Subscription.can_add(app) do
      :can_add ->
	params = %{app_id: app.id, address: address}
	case Subscription.create(params) do
	  {:ok, subscription} ->
	    # set new subscription to Watcher Cache
	    Cache.set(address, app.id)
	    # return response
	    json conn, %{success: true, subscription_id: subscription.subscription_id}
	  {:exist, subscription} ->
	    # return response
	    json conn, %{success: true, subscription_id: subscription.subscription_id}
	  {:error, %Ecto.Changeset{} = changeset } ->
	    conn
	    |> put_status(:unprocessable_entity)
	    |> put_view(EspyWeb.ErrorView)
	    |> render("error.json", changeset: changeset)
	end
      error ->
	conn
	|> put_status(:unprocessable_entity)
	|> json(%{success: false, error: error })
    end

  end

  api :GET, "/api/v1/subscriptions" do
    title "Return all Subscriptions belong to app"
    description "Returns a list of the current Activity type subscriptions."
  end

  def list(conn, _params) do
    app = conn.assigns.app
    subscriptions = Subscription.list_by_app(app.id)
    render(conn, "index.json", app_id: app.app_id, subscriptions: subscriptions)
  end

  api :DELETE, "/api/v1/subscriptions/:subscription_id" do
    title "Delete subscription"
    description "Deactivates subscription(s) for the provided subscription ID  and application for all activities. After deactivation, all events for the requesting subscription_id will no longer be sent to the webhook URL."
    note "The subscription ID can be accessed by making a call to GET /api/v1/subscriptions."
    parameter :subscription_id, :number, [description: "Subscriptions ID to deactivation"]
  end


  def delete(conn, %{"subscription_id" => subscription_id}) do
    app_id = conn.assigns.app.id
    params = %{app_id: app_id, subscription_id: subscription_id}
    case Subscription.delete(params) do
      {:ok, struct} ->
	# Remove address from cache
	Cache.delete(struct.address, app_id)
	# Response
	conn
	|> put_status(:no_content)
	|> json(%{success: true})
      {:error, :not_found} ->
	conn
	|> put_status(:not_found)
	|> json(%{success: false})
      {:error, %Ecto.Changeset{} = changeset } ->
	conn
	|> put_status(:unprocessable_entity)
	|> put_view(EspyWeb.ErrorView)
	|> render("error.json", changeset: changeset)
    end
  end

end
