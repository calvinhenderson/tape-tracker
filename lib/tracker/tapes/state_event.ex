defmodule Tracker.Tapes.StateEvent do
  @moduledoc """
  For reading state change events from the tapes table.
  This resource should be read-only as it is managed via database triggers.
  """
  use Ecto.Schema

  import Ecto.Query
  alias Tracker.Tapes

  @state_values Ecto.Enum.values(Tapes.Tape, :state)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tapes_state_events" do
    belongs_to :tape, Tapes.Tape
    field :old_state, Ecto.Enum, values: @state_values
    field :new_state, Ecto.Enum, values: @state_values
    timestamps(updated_at: false)
  end

  def query_for_tape(:all) do
    from event in __MODULE__,
      join: t in Tape,
      on: event.tape_id == t.id,
      select: event
  end

  def query_for_tape(tape_id) do
    from event in __MODULE__,
      join: t in Tape,
      on: event.tape_id == ^tape_id,
      where: t.id == ^tape_id,
      select: event
  end
end
