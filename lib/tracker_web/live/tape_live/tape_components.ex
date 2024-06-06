defmodule TrackerWeb.TapeLive.TapeComponents do
  @moduledoc """
  Presentation components for the Tape schema.
  """

  use TrackerWeb, :html

  @doc """
  Renders a tape in the style of a card

  ## Examples

      <.tape_card tape={@tape} />

      <.tape_card tape={@tape}>
        <:actions>
          <.link path={~p"/tapes/\#{@tape.id}"}>Edit</.link>
        </:actions>
      </tape>
  """
  attr :tape, Tracker.Tapes.Tape, required: true
  attr :compact, :boolean, default: false
  slot :actions, required: false
  attr :rest, :global

  def tape_card(assigns) do
    ~H"""
    <div class={["card w-auto bg-base-100 shadow-xl"]} {@rest}>
      <figure :if={!@compact}>
        <img src="/images/cassette.png" class="max-w-48 md:max-w-64" alt="Casset Tape" />
      </figure>
      <div class="card-body">
        <h1 class="card-title flex flex-wrap text-2xl">
          <span><%= @tape.name %></span>
          <span class={["badge ml-auto", @tape.state in [:installed] && "badge-ghost"]}>
            <%= translate_enum(@tape.state) %>
          </span>
        </h1>
        <div :if={@actions} class="card-actions justify-end">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </div>
    """
  end
end
