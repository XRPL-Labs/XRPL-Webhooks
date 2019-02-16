defmodule EspyWeb.Plugs.ApiAuthenticate do

  import Plug.Conn,          only: [assign: 3 ,get_req_header: 2, put_status: 2, halt: 1]
  import Phoenix.Controller, only: [json: 2]

  alias Espy.Gateway.{App}

  def init( opts ), do: opts

  def call(conn, _) do
    case authorize conn do
      {:ok, app} ->
        conn
        |> assign(:app, app)
      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: true, message: message})
        |> halt

    end
  end

  defp authorize( conn ) do
    api_key = get_req_header( conn, "x-api-key" ) |> List.first
    api_secret = get_req_header( conn, "x-api-secret" ) |> List.first

    case is_nil(api_key) or is_nil(api_secret) do
      true -> {:error, "AUTH HEADERS REQUIRED"}
      _ -> authorize_tokens(api_key, api_secret)
    end
  end

  defp authorize_tokens(api_key, api_secret) do
    case App.get_by_token(api_key, api_secret) do
      nil -> {:error , "UNAUTORIZED ACCESS"}
      app ->
        case app.active and !app.deleted do
          true -> {:ok, app }
          false -> {:error , "APP NOTFOUND"}
        end
    end
  end


end
