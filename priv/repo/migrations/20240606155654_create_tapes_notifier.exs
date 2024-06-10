defmodule Tracker.Repo.Migrations.CreateTapesNotifier do
  @moduledoc """
  Creates a database-level notification for when the state changes on a particular tape.
  """
  alias Phoenix.LiveViewTest.DOM
  use Ecto.Migration

  def change do
    ## Audit table
    create table(:tapes_state_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tape_id, references(:tapes, type: :binary_id)
      add :old_state, :string
      add :new_state, :string
      timestamps(updated_at: false)
    end

    ## Audit Events

    execute """
            CREATE OR REPLACE FUNCTION audit_tapes_changed()
              RETURNS trigger as $trigger$
              BEGIN
                IF (TG_OP = 'UPDATE') AND (OLD.state IS DISTINCT FROM NEW.state) THEN
                  INSERT INTO tapes_state_events (id, tape_id, old_state, new_state, inserted_at)
                    VALUES (gen_random_uuid(), NEW.id, OLD.state, NEW.state, NOW());
                END IF;

                RETURN NEW;
              END;
              $trigger$ LANGUAGE plpgsql;
            """,
            "DROP FUNCTION audit_tapes_changed();"

    execute """
            CREATE TRIGGER tapes_state_changed_trigger
              AFTER UPDATE ON tapes FOR EACH ROW
              WHEN (OLD.state IS DISTINCT FROM NEW.state)
              EXECUTE PROCEDURE audit_tapes_changed();
            """,
            "DROP TRIGGER tapes_state_changed_trigger ON tapes;"

    ## Notifications

    execute """
            CREATE OR REPLACE FUNCTION notify_tapes_state_events()
            RETURNS trigger as $trigger$
            DECLARE
              rec RECORD;
              payload TEXT;
              key TEXT;
              val TEXT;
              items TEXT[];
            BEGIN
              CASE TG_OP
              WHEN 'INSERT', 'UPDATE' THEN
                rec := NEW;
              ELSE
                rec := OLD;
              END CASE;

              WITH cte AS (
                SELECT events.*, tapes AS tape
                FROM tapes_state_events events
                JOIN tapes ON tapes.id = events.tape_id
                WHERE events.id = rec.id
              ) SELECT row_to_json(cte) FROM cte INTO payload;

              PERFORM pg_notify('tapes_state_event', payload);

            RETURN NEW;
            END;
            $trigger$ LANGUAGE plpgsql;
            """,
            "DROP FUNCTION notify_tapes_state_events;"

    execute """
            CREATE TRIGGER tapes_state_event_created_trigger
              AFTER INSERT OR UPDATE ON tapes_state_events
              FOR EACH ROW EXECUTE PROCEDURE notify_tapes_state_events();
            """,
            "DROP TRIGGER tapes_state_event_created_trigger ON tapes_state_events;"
  end
end
