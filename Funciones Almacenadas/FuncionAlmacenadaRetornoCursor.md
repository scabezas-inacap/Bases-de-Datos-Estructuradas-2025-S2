# Funciones almacenadas que retornan un conjunto de datos del tipo CURSOR
## Función Almacenada
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
    DBMS_OUTPUT.PUT_LINE('ID  | Salario  | Puesto');
    DBMS_OUTPUT.PUT_LINE('-------------------------');
    
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
            RPAD(v_sueldo, 8)      || ' | ' || 
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
## Salida Esperada
```sql
--- Datos de Empleados (Esquema HR) ---
ID  | Salario  | Puesto
-------------------------
132 |    2.100 | ST_CLERK
128 |    2.200 | ST_CLERK
136 |    2.200 | ST_CLERK
127 |    2.400 | ST_CLERK
135 |    2.400 | ST_CLERK
119 |    2.500 | PU_CLERK
131 |    2.500 | ST_CLERK
140 |    2.500 | ST_CLERK
144 |    2.500 | ST_CLERK
182 |    2.500 | SH_CLERK
191 |    2.500 | SH_CLERK
118 |    2.600 | PU_CLERK
143 |    2.600 | ST_CLERK
198 |    2.600 | SH_CLERK
199 |    2.600 | SH_CLERK
126 |    2.700 | ST_CLERK
139 |    2.700 | ST_CLERK
117 |    2.800 | PU_CLERK
130 |    2.800 | ST_CLERK
183 |    2.800 | SH_CLERK
195 |    2.800 | SH_CLERK
116 |    2.900 | PU_CLERK
134 |    2.900 | ST_CLERK
190 |    2.900 | SH_CLERK
187 |    3.000 | SH_CLERK
197 |    3.000 | SH_CLERK
115 |    3.100 | PU_CLERK
142 |    3.100 | ST_CLERK
181 |    3.100 | SH_CLERK
196 |    3.100 | SH_CLERK
125 |    3.200 | ST_CLERK
138 |    3.200 | ST_CLERK
180 |    3.200 | SH_CLERK
194 |    3.200 | SH_CLERK
129 |    3.300 | ST_CLERK
133 |    3.300 | ST_CLERK
186 |    3.400 | SH_CLERK
141 |    3.500 | ST_CLERK
137 |    3.600 | ST_CLERK
189 |    3.600 | SH_CLERK
188 |    3.800 | SH_CLERK
193 |    3.900 | SH_CLERK
192 |    4.000 | SH_CLERK
185 |    4.100 | SH_CLERK
107 |    4.200 | IT_PROG
184 |    4.200 | SH_CLERK
200 |    4.400 | AD_ASST
105 |    4.800 | IT_PROG
106 |    4.800 | IT_PROG
124 |    5.800 | ST_MAN
104 |    6.000 | IT_PROG
202 |    6.000 | MK_REP
173 |    6.100 | SA_REP
167 |    6.200 | SA_REP
179 |    6.200 | SA_REP
166 |    6.400 | SA_REP
123 |    6.500 | ST_MAN
203 |    6.500 | HR_REP
165 |    6.800 | SA_REP
113 |    6.900 | FI_ACCOUNT
155 |    7.000 | SA_REP
161 |    7.000 | SA_REP
178 |    7.000 | SA_REP
164 |    7.200 | SA_REP
172 |    7.300 | SA_REP
171 |    7.400 | SA_REP
154 |    7.500 | SA_REP
160 |    7.500 | SA_REP
111 |    7.700 | FI_ACCOUNT
112 |    7.800 | FI_ACCOUNT
122 |    7.900 | ST_MAN
120 |    8.000 | ST_MAN
153 |    8.000 | SA_REP
159 |    8.000 | SA_REP
110 |    8.200 | FI_ACCOUNT
121 |    8.200 | ST_MAN
206 |    8.300 | AC_ACCOUNT
177 |    8.400 | SA_REP
176 |    8.600 | SA_REP
175 |    8.800 | SA_REP
103 |    9.000 | IT_PROG
109 |    9.000 | FI_ACCOUNT
152 |    9.000 | SA_REP
158 |    9.000 | SA_REP
157 |    9.500 | SA_REP
163 |    9.500 | SA_REP
151 |    9.500 | SA_REP
170 |    9.600 | SA_REP
204 |   10.000 | PR_REP
169 |   10.000 | SA_REP
156 |   10.000 | SA_REP
150 |   10.000 | SA_REP
162 |   10.500 | SA_REP
149 |   10.500 | SA_MAN
148 |   11.000 | SA_MAN
114 |   11.000 | PU_MAN
174 |   11.000 | SA_REP
168 |   11.500 | SA_REP
147 |   12.000 | SA_MAN
205 |   12.008 | AC_MGR
108 |   12.008 | FI_MGR
201 |   13.000 | MK_MAN
146 |   13.500 | SA_MAN
145 |   14.000 | SA_MAN
102 |   17.000 | AD_VP
101 |   17.000 | AD_VP
100 |   24.000 | AD_PRES

Procedimiento PL/SQL terminado correctamente.
```
