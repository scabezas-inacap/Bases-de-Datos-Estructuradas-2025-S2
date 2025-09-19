CREATE USER hr IDENTIFIED BY hr
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
ACCOUNT UNLOCK;

GRANT CREATE SESSION TO hr;        -- puede conectarse
GRANT CREATE TABLE TO hr;          -- puede crear tablas
GRANT CREATE VIEW TO hr;           -- puede crear vistas
GRANT CREATE SEQUENCE TO hr;       -- puede crear secuencias
GRANT CREATE PROCEDURE TO hr;      -- puede crear procedimientos
GRANT CREATE TRIGGER TO hr;        -- puede crear triggers
GRANT CREATE TYPE TO hr;           -- puede crear tipos de datos
