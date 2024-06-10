defmodule Tracker.Repo do
  use Ecto.Repo,
    otp_app: :tracker,
    adapter: Ecto.Adapters.Postgres

  def after_connect(config) do
    config
    |> dbg()
  end

  defp with_current_user(op, opts) do
    %{id: user_id} = Process.get(:current_user)

    transaction(fn ->
      query("set session 'current_user' = '#{user_id}'")
      apply(__MODULE__, op, opts)
    end)
  end
end
