defmodule EspyWeb.Plugs.Protected do

    import Plug.Conn,           only: [ halt: 1]
    import Phoenix.Controller,  only: [ redirect: 2, put_flash: 3]

    def init( opts ), do: opts

    def call(conn, _) do
      case authorize conn do
        false ->
          conn
          |> put_flash(:error, "You need to login to access this page.")
          |> redirect(to: "/")
          |> halt
        true -> conn
      end
    end

    defp authorize( conn ) do
        conn.assigns.user_signed_in?
    end
  end

