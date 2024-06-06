defmodule Tracker.Tapes.State do
  @moduledoc """
  Specifies the valid states for tapes.
  """
  use Ecto.Type

  @valid_states ~w(in_storage installed broken retired)a
  def type, do: Ecto.Enum

  def cast(state) when is_binary(state) do
    state
    |> String.to_existing_atom()
    |> check_valid_state()
  end

  def cast(state) when is_atom(state), do: check_valid_state(state)

  def cast(_), do: :error

  def dump(state), do: {:ok, state}

  defp check_valid_state(state) do
    if state in @valid_states do
      {:ok, state}
    else
      :error
    end
  end
end
