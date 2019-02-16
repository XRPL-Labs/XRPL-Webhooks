
defmodule EspyWeb.Factory do
  use ExMachina.Ecto, repo: Espy.Repo

  alias Espy.Gateway.{App, Webhook}

  def webhook_factory do
    %Webhook{
      url: "http://localhost/webhook",
    }
  end

  def app_factory do
    %App{
      app_id: "314014556",
      name: "app_test",
      url: "https://test.app",
      description: "app desc",
      api_key: "69682cbf-85bd-4507-8cbd-f4ee63fed1dc",
      api_secret: "bWR3ajJSMWxwR3R5Nmd4cmtCaXNBQT09"
    }
  end

end
