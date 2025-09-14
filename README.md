# Bases de Datos Estructuradas | 2025 Semestre 2
## Docente: Sebastián Cabezas Ríos

## Crear Usuario en base de datos Oracle
```sql
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
create user profe_seba identified by 123;
grant DBA to profe_seba;
```

Su proyecto lo pueden hacer creando un usuario nuevo. Se deben conectar primero con el usuario system.

```sql
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
create user proyecto identified by 123;
grant DBA to proyecto;
```