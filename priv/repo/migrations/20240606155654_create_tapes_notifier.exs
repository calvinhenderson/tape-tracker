defmodule Tracker.Repo.Migrations.CreateTapesNotifier do
  @moduledoc """
  Creates a database-level notification for when the state changes on a particular tape.
  """
  use Ecto.Migration

  def change do
    create table(:tapes_state_events) do
      add :id, :binary_id, primary_key: true
      add :tape_id, references(:tapes, type: :binary_id)
      add :old_state, :string
      add :new_state, :string
      timestamps(updated_at: false)
    end

    execute """
            CREATE OR REPLACE FUNCTION notify_tapes_changed()
              RETURNS trigger as $trigger$
              DECLARE
                payload TEXT;
              BEGIN
                IF (TG_OP = 'UPDATE') AND (OLD.state IS DISTINCT FROM NEW.state) THEN
                  INSERT INTO
                    tapes_state_events
                    (id,    old_state, new_state)
                    NEW.id, OLD.state, NEW.state;

                  payload := row_to_json(NEW);
                  PERFORM pg_notify('tapes_state_changed', payload);
                END IF;

                RETURN NEW;
              END;
              $trigger$ LANGUAGE plpgsql;
            """,
            "DROP FUNCTION notify_tapes_changed();"

    execute """
            CREATE TRIGGER tapes_state_changed_trigger
              AFTER UPDATE ON tapes FOR EACH ROW
              WHEN (OLD.state IS DISTINCT FROM NEW.state)
              EXECUTE PROCEDURE notify_tapes_changed();
            """,
            "DROP TRIGGER tapes_state_changed_trigger;"
  end
end
