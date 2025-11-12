# Funciones almacenadas que retornan un conjunto de datos del tipo CURSOR

```sql
CREATE OR REPLACE FUNCTION FX_EMPLEADOS_GET_ALL
RETURN SYS_REFCURSOR 
IS
    v_retorno SYS_REFCURSOR;
BEGIN
    -- SE ABRE EL CURSOR
    OPEN v_retorno FOR
        SELECT
            employee_id,
            salary,
            job_id
        FROM
            employees
        ORDER BY
            salary;
    
    -- devuelve el cursor
    RETURN v_retorno;
END FX_EMPLEADOS_GET_ALL;
/
```
