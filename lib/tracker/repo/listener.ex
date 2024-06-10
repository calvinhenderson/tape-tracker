defmodule Tracker.Repo.Listener do
  @moduledoc """
  Listens to notifications in the database and broadcasts them to the application.
  """
  alias Phoenix.PubSub
  use GenServer

  @pubsub Tracker.PubSub
  @channel "tapes_state_event"

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def subscribe, do: PubSub.subscribe(@pubsub, @channel)

  @impl true
  def init(_arg) do
    repo_config = Tracker.Repo.config()

    {:ok, pid} = Postgrex.Notifications.start_link(repo_config)
    {:ok, ref} = Postgrex.Notifications.listen(pid, @channel)

    {:ok, {pid, ref}}
  end

  @impl true
  def handle_info({:notification, _pid, _ref, @channel, payload}, state) do
    payload = Jason.decode!(payload)

    event =
      %Tracker.Tapes.StateEvent{}
      |> Tracker.Tapes.change_tape_state_event(payload)
      |> Ecto.Changeset.apply_action!(:validate)

    :ok = PubSub.broadcast_from(@pubsub, self(), @channel, event)

    {:noreply, state}
  end
end
