defmodule Espy.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:subscriptions) do
      add :subscription_id, :integer
      add :address, :string
      add :app_id, references(:apps, on_delete: :nothing)

      timestamps()
    end

    create_if_not_exists index(:subscriptions, [:app_id])
    create_if_not_exists index(:subscriptions, [:subscription_id])
  end
end
