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
            TO_CHAR(salary,'999G999'),
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
## Implementación
```SQL
-- Habilita la salida para ver los resultados
SET SERVEROUTPUT ON;

DECLARE
    -- 1. Variable para recibir el cursor (el resultado de la función)
    v_cursor_employees      SYS_REFCURSOR;
    
    -- 2. Variables para almacenar temporalmente los datos de cada fila
    v_empleado_id hr.employees.employee_id%TYPE;
    v_sueldo      VARCHAR2(9);
    v_trabajo_id      hr.employees.job_id%TYPE;
BEGIN
    -- ***********************************************
    -- PASO 1: Llama a la función y asigna el cursor
    -- ***********************************************
    v_cursor_employees := FX_EMPLEADOS_GET_ALL();
    
    DBMS_OUTPUT.PUT_LINE('--- Datos de Empleados (Esquema HR) ---');
    DBMS_OUTPUT.PUT_LINE('ID | Salario | Puesto');
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    
    -- *************************************************
    -- PASO 2: Itera sobre el cursor usando FETCH y LOOP
    -- *************************************************
    LOOP
        -- Extrae los datos de la fila actual del cursor a las variables
        FETCH v_cursor_employees INTO v_empleado_id, v_sueldo, v_trabajo_id;
        
        -- Condición de salida: termina el ciclo si no hay más filas
        EXIT WHEN v_cursor_employees%NOTFOUND;
        
        -- Muestra los datos por consola
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_empleado_id, 3) || ' | ' || 
            RPAD(v_sueldo, 7)      || ' | ' || 
            v_trabajo_id
        );
    END LOOP;
    
    -- ***********************************************
    -- PASO 3: Cierra el cursor al finalizar
    -- ***********************************************
    CLOSE v_cursor_employees;

END;
/
```
