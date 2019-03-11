defmodule Espy.Gateway.Webhook do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Espy.Repo
  alias Espy.Gateway.{ Webhook, Subscription }

  schema "webhooks" do
    field :deactivated, :boolean, default: false
    field :deactivate_reason, :string
    field :failed_count, :integer, default: 0
    field :deleted, :boolean, default: false
    field :hook_id, :integer
    field :url, :string

    belongs_to :app, App

    timestamps()
  end

  @doc false
  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:hook_id, :url, :deactivated, :app_id])
    |> cast_assoc(:app)
    |> validate_required([:url, :app_id])
    |> validate_url
    |> put_hook_id()
  end

  def put_hook_id(changeset) do
    change(changeset, hook_id:  Enum.random(1000000..99999999))
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

  def can_add(app) do
    webhook_count = Webhook
                    |> where(app_id: ^app.id)
                    |> where(deleted: false)
                    |> Repo.aggregate(:count, :id)
    case webhook_count >= 2 and app.user.level != "pro" do
      true -> "Webhooks limit reached, you cannot add more webhook."
      false -> :can_add
    end
  end


  def can_delete(app) do
    webhook_count = Webhook
                    |> where(app_id: ^app.id)
                    |> where(deleted: false)
                    |> Repo.aggregate(:count, :id)
    subscription_count = Subscription
                    |> where(app_id: ^app.id)
                    |> Repo.aggregate(:count, :id)
    case webhook_count == 1 and subscription_count > 0 do
      true -> "You already have some subscriptions on this app, please remove them and try again!"
      false -> :can_delete
    end
  end


  def create(attrs \\ %{}) do
    case Repo.get_by(Webhook, attrs) do
      nil  -> %Webhook{}
      object -> object
    end
    |> Webhook.changeset(attrs)
    |> Repo.insert_or_update
  end


  def get!(id, app_id) do
    Repo.get_by!(Webhook, [ hook_id: id, app_id: app_id, deleted: false])
  end


  def list(app_id) do
    Repo.all(from a in Webhook, where: a.app_id == ^app_id, where: a.deleted == false, order_by: [desc: a.id])
  end

  def list_by_app(app_id) do
    Repo.all(from a in Webhook, where: a.app_id == ^app_id,  where: a.deleted == false, where: a.deactivated == false, order_by: [desc: a.id])
  end

  def count_by_app(app_id) do
    Repo.one(from a in Webhook, where: a.app_id == ^app_id,  where: a.deleted == false, select: count(a.id))
  end

  def delete(params) do
    case Repo.get_by(Webhook, params) do
      nil -> {:error, :not_found}
      hook -> Repo.update(change(hook, deleted: true))
    end
  end

  def set_failed_count(id, count) do
    from(p in Webhook, where: p.id == ^id)
    |> Repo.update_all(set: [failed_count: count])
  end

  def increase_failed_count(id) do
    from(p in Webhook, where: p.id == ^id, select: p.failed_count)
    |> Repo.update_all(inc: [failed_count: 1])
  end

  def deactivate(id, reason) do
    Webhook
    |> where(id: ^id)
    |> update(set: [deactivated: true, deactivate_reason: ^reason])
    |> Repo.update_all([])
  end


  def change(%Webhook{} = webhook) do
    Webhook.changeset(webhook, %{})
  end


end
