defmodule TrackerWeb.TapeLiveTest do
  alias Tracker.TapesFixtures
  use TrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tracker.TapesFixtures

  @create_attrs %{
    name: "some name",
    state: Ecto.Enum.values(Tracker.Tapes.Tape, :state) |> List.first()
  }
  @update_attrs %{
    name: "some updated name",
    state: Ecto.Enum.values(Tracker.Tapes.Tape, :state) |> List.last()
  }
  @invalid_attrs %{name: nil, state: @create_attrs[:state]}

  defp create_tape(_) do
    tape = tape_fixture()
    %{tape: tape}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_tape]

    test "lists all tapes", %{conn: conn, tape: tape} do
      {:ok, _index_live, html} = live(conn, ~p"/tapes")

      assert html =~ "Listing Tapes"
      assert html =~ tape.name
    end

    test "saves new tape", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tapes")

      assert index_live |> element("a", "New Tape") |> render_click() =~
               "New Tape"

      assert_patch(index_live, ~p"/tapes/new")

      assert index_live
             |> form("#tape-form", tape: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tape-form", tape: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tapes")

      html = render(index_live)
      assert html =~ "Tape created successfully"
      assert html =~ "some name"
    end

    test "updates tape in listing", %{conn: conn, tape: tape} do
      {:ok, index_live, _html} = live(conn, ~p"/tapes")

      assert index_live |> element("#tapes-#{tape.id} a", "Edit") |> render_click() =~
               "Edit Tape"

      assert_patch(index_live, ~p"/tapes/#{tape}/edit")

      assert index_live
             |> form("#tape-form", tape: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tape-form", tape: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tapes")

      html = render(index_live)
      assert html =~ "Tape updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes tape in listing", %{conn: conn, tape: tape} do
      {:ok, index_live, _html} = live(conn, ~p"/tapes")

      assert index_live |> element("#tapes-#{tape.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tapes-#{tape.id}")
    end
  end

  describe "Show" do
    setup [:create_tape]

    test "displays tape", %{conn: conn, tape: tape} do
      {:ok, _show_live, html} = live(conn, ~p"/tapes/#{tape}")

      assert html =~ "Show Tape"
      assert html =~ tape.name
    end

    test "updates tape within modal", %{conn: conn, tape: tape} do
      {:ok, show_live, _html} = live(conn, ~p"/tapes/#{tape}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tape"

      assert_patch(show_live, ~p"/tapes/#{tape}/show/edit")

      assert show_live
             |> form("#tape-form", tape: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#tape-form", tape: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tapes/#{tape}")

      html = render(show_live)
      assert html =~ "Tape updated successfully"
      assert html =~ "some updated name"
    end
  end
end
