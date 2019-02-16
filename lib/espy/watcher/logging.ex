defmodule Espy.Watcher.Logging do
  use Ecto.Schema
  alias Espy.Repo
  import Ecto.Changeset
  import Ecto.Query, warn: false


  alias Espy.Watcher.Logging
  alias Espy.Gateway.{App, Webhook}

  @per_page 20

  schema "logging" do
    field :response_time, :integer
    field :response_status, :integer
    field :retry_count, :integer
    field :object_id, :string
    belongs_to :webhook, Webhook
    belongs_to :app, App

    timestamps()
  end

  @required_fields [:response_status, :response_time, :object_id, :retry_count, :webhook_id, :app_id]

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end


  def create_log(attrs \\ %{}) do
    %Logging{}
    |> Logging.changeset(attrs)
    |> Repo.insert!()
  end

  def get_last_x_log(page, app_id) do
    offset = (page - 1 ) * @per_page
    Repo.all(from a in Logging,
      where: a.app_id == ^app_id,
      join: p in assoc(a, :webhook), where: p.deleted == false,
      order_by: [desc: a.id],
      limit: ^@per_page,
      offset: ^offset,
      preload: [:webhook]
    )
  end

  def count(app_id) do
    Repo.all(from a in Logging,
      where: a.app_id == ^app_id,
      join: p in assoc(a, :webhook), where: p.deleted == false,
      select: count(a.id)
    )
  end

end
