defmodule Espy.Account.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Espy.Account.User


  schema "user" do
    field :email, :string
    field :provider, :string
    field :token, :string
    field :uid, :string
    field :is_active, :boolean, default: true
    field :name, :string
    field :avatar, :string
    field :level, :string
    timestamps()
  end


  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :uid, :provider, :token, :name, :avatar])
    |> validate_required([:uid, :provider, :name])
  end

end
