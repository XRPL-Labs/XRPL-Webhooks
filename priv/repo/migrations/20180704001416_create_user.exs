defmodule EspyWeb.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:user) do
      add :provider, :string
      add :uid, :string
      add :token, :string
      add :name, :string
      add :is_active, :boolean, default: true, null: false
      add :email, :string
      add :avatar, :string

      timestamps()
    end

  end
end
