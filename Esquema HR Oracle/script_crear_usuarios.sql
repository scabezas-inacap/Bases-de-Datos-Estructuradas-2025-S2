CREATE USER profe IDENTIFIED BY profe
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
ACCOUNT UNLOCK;

GRANT CREATE SESSION TO profe;        -- puede conectarse
GRANT CREATE TABLE TO profe;          -- puede crear tablas
GRANT CREATE VIEW TO profe;           -- puede crear vistas
GRANT CREATE SEQUENCE TO profe;       -- puede crear secuencias
GRANT CREATE PROCEDURE TO profe;      -- puede crear procedimientos
GRANT CREATE TRIGGER TO profe;        -- puede crear triggers
GRANT CREATE TYPE TO profe;           -- puede crear tipos de datos
GRANT CREATE INDEX TO profe;          -- puede crear índices

