defmodule Tracker.Tapes.Tape do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tapes" do
    field :name, :string
    field :state, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tape, attrs) do
    tape
    |> cast(attrs, [:name, :state])
    |> validate_required([:name, :state])
  end
end
