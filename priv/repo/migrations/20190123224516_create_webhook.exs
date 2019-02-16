defmodule Espy.Repo.Migrations.CreateWebhook do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:webhooks) do
      add :hook_id, :integer
      add :url, :string
      add :failed_count, :integer
      add :deactivated, :boolean, default: false, null: false
      add :deactivate_reason, :string
      add :deleted, :boolean, default: false, null: false
      add :app_id, references(:apps, on_delete: :nothing)

      timestamps()
    end

    create_if_not_exists index(:webhooks, [:app_id])
    create_if_not_exists index(:webhooks, [:hook_id])
  end
end
