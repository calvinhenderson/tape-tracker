defmodule Tracker.Tapes.Tape do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @valid_states ~w(in_storage installed broken retired)a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tapes" do
    field :name, :string
    field :state, Ecto.Enum, values: @valid_states

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tape, attrs) do
    tape
    |> cast(attrs, [:name, :state])
    |> validate_required([:name, :state])
    |> validate_inclusion(:state, @valid_states)
  end

  @doc """
  Changes the state of a tape to `:in_storage`
  """
  def in_storage(tape) do
    tape
    |> changeset(%{})
    |> validate_inclusion(:state, ~w(installed broken retired)a)
    |> put_change(:state, :in_storage)
  end

  @doc """
  Changes the state of a tape to `:installed`
  """
  def installed(tape) do
    tape
    |> changeset(%{})
    |> put_change(:state, :installed)
  end

  @doc """
  Returns a query for all installed tapes.
  """
  def installed_query(query \\ Tape) do
    from t in query,
      where: t.state == :installed,
      select: t
  end
end
