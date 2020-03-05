SET myvars.connect TO 'host=localhost user=postgres password=proj693B119 dbname=postgres';

-- Install DbLink extension.
CREATE EXTENSION IF NOT EXISTS dblink;

CREATE OR REPLACE FUNCTION projectb_initdb(dbname TEXT, username TEXT, password TEXT)
RETURNS INT AS
$BODY$
  DECLARE
  BEGIN
    -- Remove db by its `dbname`. --
    PERFORM dblink_connect('connection', (SELECT current_setting('myvars.connect')));
    PERFORM dblink_exec('connection', format('UPDATE pg_database SET datallowconn = false WHERE datname = %L;', dbname));
    PERFORM * FROM dblink('connection', format('SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = %L AND pid <> pg_backend_pid();', dbname, 'postgres')) as t1(test TEXT);    
    PERFORM dblink_exec('connection', 'DROP DATABASE IF EXISTS ' || quote_ident(dbname));
    PERFORM dblink('connection','COMMIT;');
    -- Recreate the user. --
    PERFORM dblink_exec('connection', format('DROP ROLE IF EXISTS %I', username));
    PERFORM dblink_exec('connection', format('CREATE USER %I WITH PASSWORD %L', username, password));
    -- Create the db. --
    PERFORM dblink_exec('connection', format('CREATE DATABASE %I OWNER %I', dbname, username));
    PERFORM dblink('connection','COMMIT;');
    PERFORM dblink_disconnect('connection');
    -- Connect to the db and initialize it. --
    PERFORM dblink_connect('connection', format('host=localhost user=postgres password=proj693B119 dbname=%L', dbname));
    PERFORM dblink('connection','CREATE EXTENSION pgcrypto;');
    PERFORM dblink('connection','COMMIT;');
    PERFORM dblink_disconnect('connection');
    RETURN 1;
  END;
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
ALTER FUNCTION projectb_initdb(dbname TEXT, username TEXT, password TEXT)
  OWNER TO postgres;

SELECT projectb_initdb('game_info', 'game_info_user', 'game123pp321');
SELECT projectb_initdb('pinnacle', 'pinnacle_user', 'pinnacle7P321');
SELECT projectb_initdb('oddsportal_soccer', 'op_soccer', 'op_soccer102946');
SELECT projectb_initdb('bet_telegram_bot', 'btb', 'btb386pny');
