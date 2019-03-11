defmodule EspyWeb.Api.WebhookController do
  use EspyWeb, :controller

  alias Espy.Gateway.{Webhook}


  apigroup("Webhooks", "")

  api :POST, "/api/v1/webhooks" do
    title "Registers webhook URL"
    description "Registers a webhook URL for all event types."
    note "The URL will be validated via CRC request before saving. In case the validation failed, returns comprehensive error message to the requester."
    parameter :url, :string, [description: "Encoded URL for the callback endpoint."]
  end

  def create(conn, %{"url" => url}) do
    app = conn.assigns.app


    case Webhook.can_add(app) do
      :can_add -> 
	params = %{app_id: app.id, url: url, deleted: false}
	case Webhook.create(params) do
	  {:ok, hook} -> json conn, %{success: true, webhook_id: hook.hook_id}
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

  api :GET, "/api/v1/webhooks" do
    title "Return all webhooks"
    description "Returns all webhook URLs and their statuses for the authenticating app"
    note "The URL will be validated via CRC request before saving. In case the validation failed, returns comprehensive error message to the requester."
  end

  def list(conn, _params) do
    app = conn.assigns.app
    webhooks = Webhook.list_by_app(app.id)
    render(conn, "index.json", app_id: app.app_id, webhooks: webhooks)
  end

  api :DELETE, "/api/v1/webhooks/:webhook_id" do
    title "Delete webhook"
    description "Removes the webhook from the provided application's all subscription configuration."
    note "The webhook ID can be accessed by making a call to GET /api/v1/webhooks."
    parameter :webhook_id, :number, [description: "Webhook ID to delete"]
  end


  def delete(conn, %{"webhook_id" => webhook_id}) do
    app = conn.assigns.app
    case Webhook.can_delete(app) do
      :can_delete ->
	params = %{app_id: app.id, hook_id: webhook_id}
	case Webhook.delete(params) do
	  {:ok, struct} ->
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
      error ->
	conn
	|> put_status(:unprocessable_entity)
	|> json(%{success: false, error: error })
    end
  end

end
