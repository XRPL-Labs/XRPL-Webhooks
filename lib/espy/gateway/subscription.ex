defmodule Espy.Gateway.Subscription do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Espy.Repo
  alias Espy.Gateway.{ App, Subscription }

  schema "subscriptions" do
    field :subscription_id, :integer
    field :address, :string

    belongs_to :app, App
    timestamps()
  end

  @doc false
  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:app_id, :address])
    |> cast_assoc(:app)
    |> validate_required([:app_id, :address])
    |> validate_address
    |> put_subscrition_id()
  end


  def get_all do
    Repo.all(Subscription)
  end

  def put_subscrition_id(changeset) do
    change(changeset, subscription_id:  Enum.random(1000000..99999999))
  end

  def validate_address(changeset) do
    case get_field(changeset, :address) do
      nil -> changeset
      address ->
	case address |> Utils.Base58.valid? do
	  false -> add_error(changeset, :address, "invalid ripple address")
	  true -> changeset
	end
    end
  end

  def create(attrs \\ %{}) do
    case Repo.get_by(Subscription, attrs) do
      nil  -> %Subscription{} # Subscription not found, we build one
      object -> object          # Subscription exists, let's use it
    end
    |> Subscription.changeset(attrs)
    |> Repo.insert_or_update
  end

 def list_by_app(app_id) do
    Repo.all(from a in Subscription, where: a.app_id == ^app_id, order_by: [desc: a.id])
 end

 def delete(params) do
   case Repo.get_by(Subscription, params) do
     nil -> {:error, :not_found}
     subscription -> Repo.delete subscription
   end
 end


 def change(%Subscription{} = subscription) do
    Subscription.changeset(subscription, %{})
 end


end
