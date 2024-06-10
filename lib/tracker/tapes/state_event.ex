defmodule Tracker.Tapes.StateEvent do
  @moduledoc """
  For reading state change events from the tapes table.
  This resource should be read-only as it is managed via database triggers.
  """
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  alias Tracker.Tapes.Tape

  @state_values Ecto.Enum.values(Tape, :state)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tapes_state_events" do
    belongs_to :tape, Tape
    field :old_state, Ecto.Enum, values: @state_values
    field :new_state, Ecto.Enum, values: @state_values
    timestamps(updated_at: false)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:id, :tape_id, :old_state, :new_state, :inserted_at])
    |> cast_assoc(:tape, with: &Tape.event_changeset/2)
    |> validate_inclusion(:new_state, @state_values)
    |> validate_inclusion(:old_state, @state_values)
    |> foreign_key_constraint(:tape_id)
  end

  def query_for_tape(:all), do: base_query()

  def query_for_tape(tape_id) do
    from [_event, t] in base_query(),
      where: t.id == ^tape_id
  end

  defp base_query() do
    from event in __MODULE__,
      join: t in Tape,
      on: event.tape_id == t.id,
      preload: [:tape],
      order_by: [desc: :inserted_at],
      select: event
  end
end
