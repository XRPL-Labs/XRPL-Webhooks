defmodule EspyWeb.AppController do
  use EspyWeb, :controller

  alias Espy.Gateway.{App}
  alias Espy.Watcher.{Logging}

  def dashboard(conn, _params) do
    user_id = conn.assigns.current_user.id
    apps = App.user_apps(user_id)
    render(conn, "dashboard.html", apps: apps)
  end

  def logs(conn, %{"id" => id} = params) do
    user_id = conn.assigns.current_user.id
    app = App.get!(id, user_id)

    page = params
           |> Map.get("page", "1")
           |> String.to_integer

    logs = Logging.get_last_x_log(page, app.id)
    count = Logging.count(app.id) |> hd
    render(conn, "logs.html", logs: logs, id: id, count: count, page: page)
  end


  def create(conn, params) when params == %{} do
    changeset = App.change(%App{})
    render(conn, "create_app.html", changeset: changeset)
  end

  def create(conn, %{"app" => params}) do
    user = conn.assigns.current_user
    # check for user app limit
    # TODO: need to write cleaner code
    if App.check_limit(user.id) do
      conn
      |> put_flash(:error, "Private app limit reached, you cannot create more apps.")
      |> redirect(to: "/app/dashboard")
    else
      params = Map.put(params, "user_id", user.id)
      case App.create(params) do
        {:ok, _app} ->
          conn
          |> put_flash(:info, "App created successfully")
          |> redirect(to: "/app/dashboard")
        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render("create_app.html", changeset: changeset)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    user_id = conn.assigns.current_user.id
    app = App.get!(id, user_id)
    changeset = App.change(app)
    render(conn, "show.html", app: app, changeset: changeset)
  end

  def update(conn, %{"id" => id, "app" => params}) do
    user_id = conn.assigns.current_user.id
    app = App.get!(id, user_id)
    case App.update(app, params) do
      {:ok, _app} ->
        conn
        |> put_flash(:info, "App updated successfully")
        |> redirect(to: app_path(conn, :show, id))
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        conn
        |> render("show.html", app: app, changeset: changeset)
    end
  end


  def regenerate(conn, %{"id" => id}) do
    user_id = conn.assigns.current_user.id
    app = App.regenerate(id, user_id)
    conn
    |> put_flash(:info, "New keys successfully generated.")
    |> redirect(to: app_path(conn, :show, id))
  end

end
