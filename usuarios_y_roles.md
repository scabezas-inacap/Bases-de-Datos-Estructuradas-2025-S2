# Usuarios y Roles
Con una hoja de trabajo del usuario **SYSTEM**, Listar todos los usuarios y roles del sistema:
```sql
SELECT
  *
FROM
  dba_users;
```
Modificar para sacar el prefijo de Oracle:
```sql
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
```
Ver el listado de usuarios y la fecha de expiracion de la contraseña
```sql
SELECT 
    username,
    lock_date,
    expiry_date,
    profile
FROM 
    dba_users
WHERE username='HR';
```
Limitar a que la contraseña expire en **90 días**
```sql
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME 90;
```
Crear **mal** 2 usuarios con privilegios de DBA:
```sql
CREATE USER user1 IDENTIFIED BY inacap;
GRANT DBA TO user1;
```
```sql
CREATE USER user2 IDENTIFIED BY inacap;
GRANT DBA TO user2;
```
Con una conexión en **user1** eliminar el **user2**
```sql
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
```
```sql
DROP USER USER2;
```
Con el usuario **system** hacer 3 usuarios:
- Jenny: Con rol *rol_hr_mgr* que podrá: eliminar empleados e insertar empleados
- David: con rol *rol_hr_clerk* que podrá: crear trabajos, seleccionar empleados y actualizar empleados.
- Rachel: con rol *rol_hr_clerk* que podrá: crear trabajos, seleccionar empleados y actualizar empleados.

Creamos los usuarios:
```sql
CREATE USER jenny IDENTIFIED BY inacap ACCOUNT UNLOCK;
```
```sql
CREATE USER david IDENTIFIED BY inacap ACCOUNT UNLOCK;
```
```sql
CREATE USER rachel IDENTIFIED BY inacap ACCOUNT UNLOCK;
```
Creamos y asignamos el rol **ROL_HR_MGR**
```sql
CREATE ROLE ROL_HR_MGR;
GRANT CREATE SESSION TO ROL_HR_MGR;
GRANT INSERT, DELETE ON HR.employees TO ROL_HR_MGR;
GRANT ROL_HR_CLERK TO jenny;
```
Creamos y asignamos el rol **ROL_HR_CLERK**
```sql
CREATE ROLE ROL_HR_CLERK;
GRANT CREATE SESSION TO ROL_HR_CLERK;
GRANT INSERT ON HR.jobs TO ROL_HR_CLERK;
GRANT SELECT, UPDATE ON HR.employees TO ROL_HR_CLERK;
GRANT ROL_HR_CLERK TO david, rachel;
```
