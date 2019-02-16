defmodule EspyWeb.PageController do
  use EspyWeb, :controller


  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def docs(conn, _params) do
    conn
    |> redirect(to: "/docs/index.html")
    |> halt
  end
end
