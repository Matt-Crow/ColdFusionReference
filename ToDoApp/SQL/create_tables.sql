/*
    Run this script to create the tables used by this application. 
*/

CREATE TABLE tda.users (
    user_id serial PRIMARY KEY,
    user_name varchar(20) UNIQUE,
    password_hash varchar(128),
    password_salt varchar(128),
    is_admin bit DEFAULT b'0'
);