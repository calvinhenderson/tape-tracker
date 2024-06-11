defmodule TrackerWeb.DashboardLive.Index do
  alias Tracker.Accounts.User
  alias Tracker.Accounts
  use TrackerWeb, :live_view

  import TrackerWeb.TapeLive.TapeComponents

  alias Tracker.Tapes

  @events_limit 50

  @impl true
  def mount(_params, _session, socket) do
    :ok = Tapes.subscribe_to_state()

    Process.put(:current_user, socket.assigns.current_user)

    tapes = Tapes.list_tapes()

    installed_tapes =
      tapes |> Enum.filter(&Tapes.installed?/1) |> Enum.sort_by(& &1.updated_at, :desc)

    stored_tapes = tapes |> Enum.filter(&Tapes.stored?/1) |> Enum.sort_by(& &1.updated_at)
    events = Tapes.list_state_events() |> Enum.sort_by(& &1.inserted_at, :desc)

    {:ok,
     socket
     |> stream(:installed_tapes, installed_tapes, at: -1)
     |> stream(:stored_tapes, stored_tapes, at: 0)
     |> stream(:events, events, at: 0, limit: @events_limit)
     |> assign(:form, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("authenticate", %{"badge_id" => badge_id} = params, socket) do
    case Accounts.get_user_by_badge(badge_id) do
      %User{} = user ->
        Process.put(:current_user, user)

        socket =
          socket
          |> assign(:form, nil)
          |> process_event(params["action"], params["params"] |> Jason.decode!())

        Process.put(:current_user, nil)

        {:noreply, socket}

      nil ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "Badge number not found. Did you associate it in your account settings?"
         )
         |> assign_form(Map.put(params, "badge_id", ""))}
    end
  end

  @impl true
  def handle_event(event, params, socket) do
    socket =
      if is_nil(socket.assigns.current_user) do
        socket
        |> assign_form(%{"action" => event, "params" => params |> Jason.encode!()})
      else
        socket
        |> process_event(event, params)
      end

    {:noreply, socket}
  end

  def process_event(socket, "store-tape", %{"id" => tape_id}) do
    Tapes.get_tape!(tape_id)
    |> Tapes.store_tape()
    |> case do
      {:ok, tape} ->
        put_flash(socket, :info, gettext("Checking in ") <> tape.name)

      {:error, _changeset} ->
        put_flash(socket, :error, gettext("Failed to check in the tape."))
    end
  end

  def process_event(socket, "install-tape", %{"id" => tape_id}) do
    Tapes.get_tape!(tape_id)
    |> Tapes.install_tape()
    |> case do
      {:ok, %{install: tape}} ->
        put_flash(socket, :info, gettext("Installing ") <> tape.name)

      {:error, _changeset} ->
        put_flash(socket, :error, gettext("Failed to check in the tape."))
    end
  end

  @impl true
  def handle_info(%Tapes.StateEvent{tape: tape} = event, socket) do
    socket =
      if Tapes.stored?(tape) do
        socket
        |> stream_delete(:installed_tapes, tape)
        |> stream_insert(:stored_tapes, tape, at: -1)
      else
        socket
        |> stream_delete(:stored_tapes, tape)
        |> stream_insert(:installed_tapes, tape, at: 0)
      end

    {:noreply, socket |> stream_insert(:events, event, at: 0, limit: @events_limit)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tapes")
    |> assign(:tape, nil)
  end

  defp assign_form(socket, params \\ %{}) do
    params =
      %{
        "badge_id" => "",
        "action" => nil,
        "params" => nil
      }
      |> Map.merge(params)

    assign(socket, :form, to_form(params))
  end
end
