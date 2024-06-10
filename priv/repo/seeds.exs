# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tracker.Repo.insert!(%Tracker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

1..10
|> Enum.reduce([], fn i, acc ->
  {:ok, tape} = Tracker.Tapes.create_tape(%{name: to_string(i), state: :stored})
  [tape | acc]
end)
|> Enum.reverse()
|> List.first()
|> Tracker.Tapes.install_tape()
