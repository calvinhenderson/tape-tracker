defmodule TrackerWeb.EnumHelpers do
  @moduledoc """
  Convenience methods for creating select inputs for enums.
  """

  @doc """
  Translates an enum value using gettext.
  """
  def translate_enum(value) when is_atom(value) do
    value =
      value
      |> Atom.to_string()
      |> humanize()

    Gettext.dgettext(TrackerWeb.Gettext, "enums", value)
  end

  @doc """
  Returns all translated enum values for the select options.
  """
  def translate_select_enums(module, field) do
    module
    |> Ecto.Enum.values(field)
    |> Enum.map(&{translate_enum(&1), &1})
  end

  defp humanize(string) do
    string
    |> String.replace("_", " ")
    |> String.upcase(:ascii)
  end
end
