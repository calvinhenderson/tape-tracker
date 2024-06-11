defmodule Tracker.Repo do
  use Ecto.Repo,
    otp_app: :tracker,
    adapter: Ecto.Adapters.Postgres

  @impl true
  def prepare_query(_operation, query, opts) do
    user_id =
      Process.get(:current_user)
      |> case do
        %{id: id} -> id
        _ -> nil
      end

    query!("SELECT set_config('audit.user_id', $1, true);", [user_id])

    {query, opts}
  end
end
