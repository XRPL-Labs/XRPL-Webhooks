defmodule EspyWeb.ApiTest do
  use EspyWeb.ConnCase

  import EspyWeb.Factory

  setup do
    Supervisor.terminate_child(Espy.Supervisor, ConCache)
    Supervisor.restart_child(Espy.Supervisor, ConCache)
    :ok
  end

  test "/api/v1/webhooks", %{conn: conn} do
    app1 = insert(:app)

		# CREATE WEBHOOK INVALID URL
    conn1 = conn
      |> put_req_header("x-api-key", app1.api_key)
      |> put_req_header("x-api-secret", app1.api_secret)
      |> put_req_header("content-type", "application/json; charset=utf-8")
      |> post(api_webhook_path(conn, :create), url: "https://invalid-url")
      |> BlueBird.ConnLogger.save()

    # CREATE WEBHOOK
    conn1 = conn
      |> put_req_header("x-api-key", app1.api_key)
      |> put_req_header("x-api-secret", app1.api_secret)
      |> put_req_header("content-type", "application/json; charset=utf-8")
      |> post(api_webhook_path(conn, :create), url: "https://myapp.com/webhook")
      |> BlueBird.ConnLogger.save()

    response_create = json_response(conn1, 200)
    webhook_id = Map.get(response_create, "webhook_id")

    # GET LIST OF WEBHOOKS
    conn2 = conn
      |> put_req_header("x-api-key", app1.api_key)
      |> put_req_header("x-api-secret", app1.api_secret)
      |> get(api_webhook_path(conn, :list))
      |> BlueBird.ConnLogger.save()

    response_list = json_response(conn2, 200)

    # DELETE WEBHOOK
    conn3 = conn
      |> put_req_header("x-api-key", app1.api_key)
      |> put_req_header("x-api-secret", app1.api_secret)
      |> put_req_header("content-type", "application/json; charset=utf-8")
      |> delete(api_webhook_path(conn, :delete,  webhook_id))
      |> BlueBird.ConnLogger.save()

  end



  test "/api/v1/subscriptions", %{conn: conn} do
    app1 = insert(:app)


		# Invalid address
    conn1 = conn
      |> put_req_header("x-api-key", app1.api_key)
      |> put_req_header("x-api-secret", app1.api_secret)
      |> put_req_header("content-type", "application/json; charset=utf-8")
      |> post(api_subscription_path(conn, :create), address: "invalid_address")
      |> BlueBird.ConnLogger.save()


    # Subscription an address
    conn1 = conn
      |> put_req_header("x-api-key", app1.api_key)
      |> put_req_header("x-api-secret", app1.api_secret)
      |> put_req_header("content-type", "application/json; charset=utf-8")
      |> post(api_subscription_path(conn, :create), address: "cqAiBkWakRA9Jr5TCahtKrPS23KBYUZhj")
      |> BlueBird.ConnLogger.save()

    response_create = json_response(conn1, 200)
    subscription_id = Map.get(response_create, "subscription_id")

    # GET LIST OF SUBSCRIPTIONS
    conn2 = conn
      |> put_req_header("x-api-key", app1.api_key)
      |> put_req_header("x-api-secret", app1.api_secret)
      |> get(api_subscription_path(conn, :list))
      |> BlueBird.ConnLogger.save()

    response_list = json_response(conn2, 200)

    # DEACTIVATE SUBSCRIPTION
    conn3 = conn
      |> put_req_header("x-api-key", app1.api_key)
      |> put_req_header("x-api-secret", app1.api_secret)
      |> put_req_header("content-type", "application/json; charset=utf-8")
      |> delete(api_subscription_path(conn, :delete,  subscription_id))
      |> BlueBird.ConnLogger.save()

  end
end
