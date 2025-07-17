/*
    Run this script to create the tables used by this application. 
*/

CREATE TABLE tda.users (
    user_id serial PRIMARY KEY,
    user_name varchar(20) UNIQUE,
    password_hash varchar(128),
    password_salt varchar(128),
    is_admin bit DEFAULT b'0',
    is_deactivated bit DEFAULT b'0'
);

CREATE TABLE tda.todo_items (
    todo_item_id serial PRIMARY KEY,
    creator_user_id integer REFERENCES tda.users,
    title varchar(64) NOT NULL,
    description varchar(256) NOT NULL DEFAULT '',
    is_completed bit NOT NULL DEFAULT b'0',
    date_created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_completed timestamp DEFAULT NULL
);