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
  attr :is_link, :boolean, default: true
  slot :actions, required: false
  attr :rest, :global

  def tape_card(assigns) do
    ~H"""
    <div
      class={[
        "card card-side min-w-60 max-w-xl w-auto bg-base-100 shadow-xl group hover:scale-105"
      ]}
      {@rest}
    >
      <.link navigate={@is_link && ~p"/tapes/#{@tape.id}"}>
        <figure :if={!@compact}>
          <img
            src="/images/cassette.png"
            class={[
              "w-80 group-hover:grayscale-0 group-hover:opacity-100 transition-all duration-500",
              not Tracker.Tapes.installed?(@tape) && "grayscale dark:opacity-50"
            ]}
            alt="Casset Tape"
          />
        </figure>
        <div class="card-body">
          <h1 class="card-title flex flex-wrap text-2xl">
            <span class="mr-auto"><%= @tape.name %></span>
            <.state_badge state={@tape.state} />
          </h1>
          <div :if={@actions} class="card-actions justify-end">
            <%= render_slot(@actions) %>
          </div>
          <p class="text-sm">
            Last installed:
            <span
              id={@tape.id <> "-last_installed_at"}
              phx-hook="FormatTimestamp"
              data-timestamp={@tape.last_installed_at}
            >
              Never
            </span>
          </p>
        </div>
      </.link>
    </div>
    """
  end

  attr :state, :atom, values: [:installed, :stored, :retired, :broken], required: true

  def state_badge(assigns) do
    ~H"""
    <span class={[
      "badge badge-sm",
      @state in [:installed] && "badge-warning",
      @state in [:stored] && "badge-ghost",
      @state in [:retired] && "badge-outline",
      @state in [:broken] && "badge-error"
    ]}>
      <%= translate_enum(@state) %>
    </span>
    """
  end

  attr :events, :list, default: []
  attr :id, :string, required: true

  def tape_timeline(assigns) do
    ~H"""
    <ul id={@id} phx-update="stream" class="timeline timeline-vertical">
      <%= for {id, event} <- @events do %>
        <li id={id} class="group">
          <hr class="group-first:hidden" />
          <div class="group-even:timeline-end timeline-start timeline-box min-w-max">
            <p id={id <> "-timestamp"} data-timestamp={event.inserted_at} phx-hook="FormatTimestamp">
              <%= event.inserted_at %>
            </p>
            <p :if={is_binary(event.user_id)}>
              By
              <b class="tooltip tooltip-top" data-tip={event.user_id}>
                <%= if is_nil(event.user.name), do: "No name", else: event.user.name %>
              </b>
            </p>
            <p :if={is_nil(event.user_id)}>
              By <b>System</b>
            </p>
          </div>
          <.icon name="hero-information-circle" class="timeline-middle mb-8" />
          <.icon
            name="hero-arrow-long-up"
            class="scale-[2.5] timeline-middle -mb-10 text-base-300 group-last:hidden"
          />
          <div class="group-even:timeline-start timeline-end timeline-box w-full min-w-56">
            <.link navigate={~p"/tapes/#{event.tape.id}"}>
              <div class="grid grid-cols-1">
                <.header>Tape <%= event.tape.name %></.header>
                <p>
                  <.state_badge state={event.old_state} />
                  <.icon name="hero-arrow-right" />
                  <.state_badge state={event.new_state} />
                </p>
              </div>
            </.link>
          </div>
          <hr class="group-last:hidden" />
        </li>
      <% end %>
    </ul>
    """
  end
end
