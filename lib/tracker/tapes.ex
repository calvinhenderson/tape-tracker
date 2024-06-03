defmodule Tracker.Tapes do
  @moduledoc """
  The Tapes context.
  """

  import Ecto.Query, warn: false
  alias Tracker.Repo

  alias Tracker.Tapes.Tape

  @doc """
  Returns the list of tapes.

  ## Examples

      iex> list_tapes()
      [%Tape{}, ...]

  """
  def list_tapes do
    Repo.all(Tape)
  end

  @doc """
  Gets a single tape.

  Raises `Ecto.NoResultsError` if the Tape does not exist.

  ## Examples

      iex> get_tape!(123)
      %Tape{}

      iex> get_tape!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tape!(id), do: Repo.get!(Tape, id)

  @doc """
  Creates a tape.

  ## Examples

      iex> create_tape(%{field: value})
      {:ok, %Tape{}}

      iex> create_tape(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tape(attrs \\ %{}) do
    %Tape{}
    |> Tape.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tape.

  ## Examples

      iex> update_tape(tape, %{field: new_value})
      {:ok, %Tape{}}

      iex> update_tape(tape, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tape(%Tape{} = tape, attrs) do
    tape
    |> Tape.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tape.

  ## Examples

      iex> delete_tape(tape)
      {:ok, %Tape{}}

      iex> delete_tape(tape)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tape(%Tape{} = tape) do
    Repo.delete(tape)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tape changes.

  ## Examples

      iex> change_tape(tape)
      %Ecto.Changeset{data: %Tape{}}

  """
  def change_tape(%Tape{} = tape, attrs \\ %{}) do
    Tape.changeset(tape, attrs)
  end

  @doc """
  Installs a tape. Any currently installed tapes will be checked in.

  ## Examples

      iex> install_tape(tape)
      {:ok, %Tape{state: :installed}}
  """
  def install_tape(tape) do
    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:check_in, Tape.installed_query(), set: [state: :in_storage])
    |> Ecto.Multi.update(:install, Tape.installed(tape))
    |> Repo.transaction()
  end

  @doc """
  Checks a tape in.

  ## Examples

      iex> check_in_tape(tape)
      {:ok, %Tape{state: :in_storage}}
  """
  def check_in_tape(tape) do
    tape
    |> Tape.in_storage()
    |> Repo.update()
  end
end
