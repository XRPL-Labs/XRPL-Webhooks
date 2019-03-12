defmodule Espy.Gateway.App do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Espy.Repo
  alias Espy.Gateway.App
  alias Espy.Account
  alias Espy.Account.{User}

  schema "apps" do
    field :app_id, :integer
    field :active, :boolean, default: true
    field :api_key, :string
    field :api_secret, :string
    field :deleted, :boolean, default: false
    field :description, :string
    field :name, :string
    field :url, :string

    belongs_to :user, User
    timestamps()
  end

  def changeset(%App{} = app, attrs) do
    app
    |> cast(attrs, [:name, :description, :url, :user_id])
    |> cast_assoc(:user)
    |> validate_required([:name, :description, :url, :user_id])
    |> validate_length(:name, min: 3, max: 16)
    |> validate_length(:description, min: 10, max: 64)
    |> validate_url()
    |> put_app_id()
    |> put_api_key()
    |> put_api_secret()
  end

  def update_changeset(%App{} = app, attrs) do
    app
    |> cast(attrs, [:name, :description, :url, :user_id])
    |> cast_assoc(:user)
    |> validate_required([:name, :description, :url, :user_id])
    |> validate_length(:name, min: 3, max: 16)
    |> validate_length(:description, min: 10, max: 64)
    |> validate_url()
  end


  def regenerate_changeset(%App{} = app) do
    app
    |> put_api_key()
    |> put_api_secret()
  end

  def validate_url(changeset) do
    case get_field(changeset, :url) do
      nil -> changeset
      url ->
        case URI.parse(url) do
          %URI{scheme: nil} -> add_error(changeset, :url, "URL is missing host")
          %URI{host: nil} -> add_error(changeset, :url, "URL is missing host")
          %URI{host: host} ->
            case :inet.gethostbyname(Kernel.to_charlist host) do
              {:ok, _} -> changeset
              {:error, _} -> add_error(changeset, :url, "invalid host")
            end
          end
    end
  end


  def check_limit(user_id) do
    apps_count = App
    |> where(user_id: ^user_id)
    |> where(deleted: false)
    |> Repo.aggregate(:count, :id)

    user = Account.get_user!(user_id)

    apps_count >= 1 and user.level != "pro"
  end

  def put_app_id(changeset) do
    change(changeset, app_id:  Enum.random(1000000..99999999))
  end


  def put_api_key(changeset) do
    change(changeset, api_key: SecureRandom.uuid())
  end

  def put_api_secret(changeset) do
    change(changeset, api_secret: SecureRandom.urlsafe_base64())
  end

  def user_apps(user_id) do
    Repo.all(from a in App, where: a.user_id == ^user_id, where: a.deleted != true)
  end

  def get!(id, user_id) do
    Repo.get_by!(App, [ app_id: id, user_id: user_id, deleted: false]) |> Repo.preload(:user)
  end

  def get(id) do
    Repo.get_by(App, [ id: id, deleted: false, active: true]) |> Repo.preload(:user)
  end


  def get_by_token(api_key, api_secret) do
    Repo.get_by(App, [ api_key: api_key, api_secret: api_secret]) |> Repo.preload(:user)
  end

  def regenerate(id, user_id) do
    Repo.get_by!(App, [ app_id: id, user_id: user_id, deleted: false])
    |> App.regenerate_changeset()
    |> Repo.update
  end


  def create(attrs \\ %{}) do
    %App{}
    |> App.changeset(attrs)
    |> Repo.insert()
  end

  def update(%App{} = app, attrs) do
    app
    |> App.update_changeset(attrs)
    |> Repo.update()
  end

  def delete(%App{} = app) do
    Repo.delete(app)
  end

  def change(%App{} = app) do
    App.update_changeset(app, %{})
  end


end
