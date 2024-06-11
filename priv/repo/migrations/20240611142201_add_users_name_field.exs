defmodule Tracker.Repo.Migrations.AddUsersNameField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
    end

    create index(:users, [:name])
  end
end
