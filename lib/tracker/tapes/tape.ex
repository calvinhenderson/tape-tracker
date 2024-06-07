defmodule Tracker.Tapes.Tape do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Tracker.Tapes

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tapes" do
    field :name, :string
    field :state, Ecto.Enum, values: [:installed, :stored, :retired, :broken]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tape, attrs) do
    tape
    |> cast(attrs, [:name, :state])
    |> validate_required([:name, :state])
  end

  @doc """
  Changes the state of a tape to `:stored`
  """
  def store(tape) do
    tape
    |> changeset(%{})
    |> put_change(:state, :stored)
  end

  @doc """
  Changes the state of a tape to `:installed`
  """
  def install(tape) do
    tape
    |> changeset(%{})
    |> put_change(:state, :installed)
  end

  @doc """
  Returns a query for all installed tapes.
  """
  def installed_query(query \\ __MODULE__) do
    from t in query,
      where: t.state == :installed,
      select: t
  end
end
