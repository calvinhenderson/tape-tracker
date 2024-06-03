defmodule TrackerWeb.TapeLive.Index do
  use TrackerWeb, :live_view

  alias Tracker.Tapes
  alias Tracker.Tapes.Tape

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :tapes, Tapes.list_tapes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tape")
    |> assign(:tape, Tapes.get_tape!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tape")
    |> assign(:tape, %Tape{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tapes")
    |> assign(:tape, nil)
  end

  @impl true
  def handle_info({TrackerWeb.TapeLive.FormComponent, {:saved, tape}}, socket) do
    {:noreply, stream_insert(socket, :tapes, tape)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tape = Tapes.get_tape!(id)
    {:ok, _} = Tapes.delete_tape(tape)

    {:noreply, stream_delete(socket, :tapes, tape)}
  end
end
