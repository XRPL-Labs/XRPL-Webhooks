defmodule Espy.Repo.Migrations.CreateApps do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:apps) do
      add :name, :string
      add :app_id, :integer, null: false
      add :description, :text
      add :url, :string
      add :active, :boolean, default: false, null: false
      add :deleted, :boolean, default: false, null: false
      add :api_key, :string
      add :api_secret, :string
      add :user_id, references(:user, on_delete: :nothing)

      timestamps()
    end

    create_if_not_exists index(:apps, [:user_id])
    create_if_not_exists index(:apps, [:app_id])
  end
end
