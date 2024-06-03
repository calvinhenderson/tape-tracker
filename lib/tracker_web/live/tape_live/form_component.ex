defmodule TrackerWeb.TapeLive.FormComponent do
  use TrackerWeb, :live_component

  alias Tracker.Tapes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage tape records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="tape-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:state]} type="text" label="State" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Tape</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{tape: tape} = assigns, socket) do
    changeset = Tapes.change_tape(tape)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"tape" => tape_params}, socket) do
    changeset =
      socket.assigns.tape
      |> Tapes.change_tape(tape_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"tape" => tape_params}, socket) do
    save_tape(socket, socket.assigns.action, tape_params)
  end

  defp save_tape(socket, :edit, tape_params) do
    case Tapes.update_tape(socket.assigns.tape, tape_params) do
      {:ok, tape} ->
        notify_parent({:saved, tape})

        {:noreply,
         socket
         |> put_flash(:info, "Tape updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_tape(socket, :new, tape_params) do
    case Tapes.create_tape(tape_params) do
      {:ok, tape} ->
        notify_parent({:saved, tape})

        {:noreply,
         socket
         |> put_flash(:info, "Tape created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
