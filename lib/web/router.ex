defmodule EspyWeb.Router do
  use EspyWeb, :router

  # -----------------pipeline ----------------

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EspyWeb.Plugs.WebAuthenticate
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug EspyWeb.Plugs.ApiAuthenticate
  end


  pipeline :protected do
    plug EspyWeb.Plugs.Protected
  end


  # ----------------- scope route ----------------

  scope "/", EspyWeb do
    pipe_through [:browser]

    get "/", PageController, :index
    get "/docs", PageController, :docs
    get "/login", PageController, :login

    # oauth
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    get "/signout", AuthController, :delete
  end


  # Definitely logged in scope
  scope "/app", EspyWeb do
      pipe_through [:browser, :protected]

      # App controllers
      get "/dashboard", AppController, :dashboard
      get "/new", AppController, :create
      post "/new", AppController, :create
      get "/:id/details", AppController, :show
      put "/:id/details", AppController, :update
      get "/:id/regenerate", AppController, :regenerate
      get "/:id/logs", AppController, :logs
      get "/:id/logs/:page", AppController, :logs

      # Webhook controllers
      get "/:id/webhooks", WebhookController, :list
      post "/:id/webhooks", WebhookController, :create
      get "/:id/webhooks/:webhook_id/delete", WebhookController, :delete
      get "/:id/webhooks/:webhook_id/trigger", WebhookController, :trigger

      # Webhook controllers
      get "/:id/subscriptions", SubscriptionController, :list
      post "/:id/subscriptions", SubscriptionController, :create
      get "/:id/subscriptions/:subscription_id/delete", SubscriptionController, :delete

  end


  scope "/api/v1", EspyWeb, as: :api do
    pipe_through :api

    post "/webhooks", Api.WebhookController, :create
    get "/webhooks", Api.WebhookController, :list
    delete "/webhooks/:webhook_id", Api.WebhookController, :delete

    post "/subscriptions", Api.SubscriptionController, :create
    get "/subscriptions", Api.SubscriptionController, :list
    delete "/subscriptions/:subscription_id", Api.SubscriptionController, :delete


  end


end
