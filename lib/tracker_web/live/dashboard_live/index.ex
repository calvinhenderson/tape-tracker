defmodule TrackerWeb.DashboardLive.Index do
  use TrackerWeb, :live_view

  import TrackerWeb.TapeLive.TapeComponents

  alias Tracker.Tapes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :tapes, Tapes.list_tapes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("store-tape", %{"id" => tape_id}, socket) do
    Tapes.get_tape!(tape_id)
    |> Tapes.store_tape()
    |> case do
      {:ok, tape} ->
        {:noreply, put_flash(socket, :info, gettext("Checking in ") <> tape.name)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to check in the tape."))}
    end
  end

  @impl true
  def handle_event("install-tape", %{"id" => tape_id}, socket) do
    Tapes.get_tape!(tape_id)
    |> Tapes.install_tape()
    |> case do
      {:ok, %{install: tape}} ->
        {:noreply, put_flash(socket, :info, gettext("Installing ") <> tape.name)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to check in the tape."))}
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tapes")
    |> assign(:tape, nil)
  end
end
