-- Create replication user on the master server
CREATE USER repl_user WITH REPLICATION ENCRYPTED PASSWORD 'repl_user';

-- Grant replication privileges to the user on the database
GRANT ALL PRIVILEGES ON DATABASE mydatabase TO repl_user;

ALTER ROLE repl_user WITH LOGIN;