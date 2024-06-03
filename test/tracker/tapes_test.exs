defmodule Tracker.TapesTest do
  use Tracker.DataCase

  alias Tracker.Tapes

  describe "tapes" do
    alias Tracker.Tapes.Tape

    import Tracker.TapesFixtures

    @invalid_attrs %{name: nil, state: nil}

    test "list_tapes/0 returns all tapes" do
      tape = tape_fixture()
      assert Tapes.list_tapes() == [tape]
    end

    test "get_tape!/1 returns the tape with given id" do
      tape = tape_fixture()
      assert Tapes.get_tape!(tape.id) == tape
    end

    test "create_tape/1 with valid data creates a tape" do
      new_state = Ecto.Enum.values(Tape, :state) |> List.first()
      valid_attrs = %{name: "some name", state: to_string(new_state)}

      assert {:ok, %Tape{} = tape} = Tapes.create_tape(valid_attrs)
      assert tape.name == "some name"
      assert tape.state == new_state
    end

    test "create_tape/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tapes.create_tape(@invalid_attrs)
    end

    test "update_tape/2 with valid data updates the tape" do
      tape = tape_fixture()
      new_state = Ecto.Enum.values(Tape, :state) |> List.last()
      update_attrs = %{name: "some updated name", state: to_string(new_state)}

      assert {:ok, %Tape{} = tape} = Tapes.update_tape(tape, update_attrs)
      assert tape.name == "some updated name"
      assert tape.state == new_state
    end

    test "update_tape/2 with invalid data returns error changeset" do
      tape = tape_fixture()
      assert {:error, %Ecto.Changeset{}} = Tapes.update_tape(tape, @invalid_attrs)
      assert tape == Tapes.get_tape!(tape.id)
    end

    test "delete_tape/1 deletes the tape" do
      tape = tape_fixture()
      assert {:ok, %Tape{}} = Tapes.delete_tape(tape)
      assert_raise Ecto.NoResultsError, fn -> Tapes.get_tape!(tape.id) end
    end

    test "change_tape/1 returns a tape changeset" do
      tape = tape_fixture()
      assert %Ecto.Changeset{} = Tapes.change_tape(tape)
    end
  end
end
