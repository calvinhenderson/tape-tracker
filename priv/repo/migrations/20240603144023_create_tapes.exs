defmodule Tracker.Repo.Migrations.CreateTapes do
  use Ecto.Migration

  def change do
    create table(:tapes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :state, :string
      add :last_installed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
