defmodule Tracker.TapesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tracker.Tapes` context.
  """

  @doc """
  Generate a tape.
  """
  def tape_fixture(attrs \\ %{}) do
    {:ok, tape} =
      attrs
      |> Enum.into(%{
        name: "some name",
        state: Ecto.Enum.values(Tracker.Tapes.Tape, :state) |> List.first()
      })
      |> Tracker.Tapes.create_tape()

    tape
  end
end
