defmodule EspyWeb.SubscriptionController do
  use EspyWeb, :controller

  alias Espy.Gateway.{Webhook, Subscription, App}

  alias Espy.Watcher.{Cache}

  def list(conn, %{"id" => id }) do
    user_id = conn.assigns.current_user.id
    app = App.get!(id, user_id)
    subscriptions = Subscription.list_by_app(app.id)
    changeset = Subscription.change(%Subscription{})
    render(conn, "list.html", subscriptions: subscriptions, app: app,changeset: changeset)
  end

  def create(conn, %{"subscription" => %{"address" => address}} = params) do
    user = conn.assigns.current_user
    app = App.get!(Map.get(params, "id"), user.id)


    case Subscription.can_add(app) do
      :can_add -> subscription = %{app_id: app.id, address: address}
	case Subscription.create(subscription) do
	  {:ok, subscription} ->
	    # set new subscription to Watcher Cache
	    Cache.set(address, app.id)
	    # return response
	    conn
	    |> put_flash(:info, "Subscription added successfully")
	    |> redirect(to: subscription_path(conn, :list, app.app_id ))
	  {:exist, subscription} ->
	    # return response
	    conn
	    |> put_flash(:info, "Subscription already exist.")
	    |> redirect(to: subscription_path(conn, :list, app.app_id ))
	  {:error, %Ecto.Changeset{} = changeset} ->
	    conn
	    |> put_flash(:error, "Please enter a valid Ripple Address")
	    |> redirect(to: subscription_path(conn, :list, app.app_id ))
	end
      error ->
	conn
	|> put_flash(:error, error)
	|> redirect(to: subscription_path(conn, :list, app.app_id ))
    end

  end

  def delete(conn, %{"id" => id, "subscription_id" => subscription_id}) do
    user_id = conn.assigns.current_user.id
    app = App.get!(id, user_id)
    case Subscription.delete(%{subscription_id: subscription_id, app_id: app.id}) do
      {:ok, struct} ->
	# Remove address from cache
	Cache.delete(struct.address, app.id)
      _ -> true
    end
    redirect(conn, to: subscription_path(conn, :list, app.app_id))
  end

end
