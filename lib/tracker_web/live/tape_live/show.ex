defmodule TrackerWeb.TapeLive.Show do
  use TrackerWeb, :live_view

  alias Tracker.Tapes
  import TrackerWeb.TapeLive.TapeComponents

  @impl true
  def mount(_params, _session, socket) do
    Tapes.subscribe_to_state()

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:tape, Tapes.get_tape!(id))
     |> stream(:events, Tapes.list_state_events(id))}
  end

  @impl true
  def handle_info(%Tapes.StateEvent{} = event, socket) do
    socket =
      if event.tape_id == socket.assigns.tape.id do
        socket
        |> stream_delete(:events, event)
        |> stream_insert(:events, event, at: 0)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(_event, socket) do
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Tape"
  defp page_title(:edit), do: "Edit Tape"
end
