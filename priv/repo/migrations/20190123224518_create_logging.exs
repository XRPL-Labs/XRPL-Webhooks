defmodule EspyWeb.Repo.Migrations.CreateLogging do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:logging) do
      add :response_time, :integer
      add :response_status, :integer
      add :retry_count, :integer
      add :object_id, :string
      add :webhook_id, references(:webhooks, on_delete: :nothing)
      add :app_id, references(:apps, on_delete: :nothing)

      timestamps()
    end

    create_if_not_exists index(:logging, [:webhook_id])
    create_if_not_exists index(:logging, [:app_id])
  end
end
