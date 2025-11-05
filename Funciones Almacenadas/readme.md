# Funciones Almacenadas

Nos permite que el desarrollador backend no sepa SQL. Porque en realidad, no tiene por qué saber SQL.

Es por eso que le entregamos un listado de funciones almacenadas que le retornen los datos solicitados de manera explícita.

## Función almacenada que retornan un solo registro dependiendo del ID

```sql
CREATE OR REPLACE FUNCTION FX_CATEGORIA_GET_BY_ID(p_id IN NUMBER)
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id, nombre, descripcion, super_id, activo
        FROM foro_categoria
        -- WHERE activo = 1 -- Comentado para que traiga todo
        WHERE id = p_id
        ORDER BY nombre;

    RETURN v_cursor;
END;
/
```

## Función almacenada que retorna todos los registros de una tabla

```sql
CREATE OR REPLACE FUNCTION FX_CATEGORIA_GET_ALL
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT id, nombre, descripcion, super_id, activo
        FROM foro_categoria
        -- WHERE activo = 1 -- Comentado para que traiga todo
        ORDER BY nombre;

    RETURN v_cursor;
END;
/
```

## Función Almacenada que apaga un registro

```sql
CREATE OR REPLACE FUNCTION FX_CATEGORIA_DISABLE
    (p_id IN foro_categoria.id%TYPE)
RETURN NUMBER
IS
    -- Variable para almacenar el ID para el mensaje de error
    v_id_not_found foro_categoria.id%TYPE := p_id;
BEGIN
    -- 1. Intentamos realizar el borrado lógico
    -- Solo actualizamos si el registro EXISTE y está ACTIVO
    UPDATE foro_categoria
    SET activo = 0
    WHERE id = p_id
      AND activo = 1; -- Importante: Solo apagar si está encendido

    -- 2. Verificamos si la actualización realmente hizo algo
    -- SQL%ROWCOUNT nos dice cuántas filas fueron afectadas.
    
    IF SQL%ROWCOUNT = 0 THEN
        -- Si no se afectaron filas, pueden ser dos casos:
        -- a) El ID no existe.
        -- b) El ID existe, pero ya estaba en activo = 0.
        -- En ambos casos, el registro no se "apagó" en esta ejecución.
        -- Para fines de esta función, lo reportamos como un fallo (0).
        
        -- (Opcional) Podemos verificar si existe para dar un mensaje más claro
        DECLARE
            v_count NUMBER;
        BEGIN
            SELECT COUNT(1) INTO v_count FROM foro_categoria WHERE id = p_id;
            IF v_count = 0 THEN
                RAISE NO_DATA_FOUND; -- Forzamos la excepción de "No Encontrado"
            ELSE
                -- Si existe, pero ya estaba inactivo
                DBMS_OUTPUT.PUT_LINE('Info: La categoria ' || p_id || ' ya estaba inactiva.');
                RETURN 0; -- Indicamos que no se hizo el cambio (opcional)
            END IF;
        END;
    END IF;

    -- 3. Si SQL%ROWCOUNT > 0, la actualización fue exitosa
    RETURN 1; -- Éxito

EXCEPTION
    -- 4. Manejo de Excepciones Específicas
    
    WHEN NO_DATA_FOUND THEN
        -- Esta excepción se dispara si el SELECT COUNT(1) falla (nuestro RAISE)
        DBMS_OUTPUT.PUT_LINE('Error (NO_DATA_FOUND): No existe una categoria con ID: ' || v_id_not_found);
        RETURN 0; -- Fracaso

    -- 5. Manejo de Todas las Demás Excepciones
    WHEN OTHERS THEN
        -- Esta es la captura genérica para errores inesperados (ej. ORA-...)
        DBMS_OUTPUT.PUT_LINE('Error inesperado al apagar categoria (' || SQLCODE || '): ' || SQLERRM);
        RETURN 0; -- Fracaso
END;
/
```

## Función Almacenada que enciende un registro
```sql
CREATE OR REPLACE FUNCTION FX_CATEGORIA_ENABLE
    (p_id IN foro_categoria.id%TYPE)
RETURN NUMBER
IS
    -- Variable para almacenar el ID para el mensaje de error
    v_id_not_found foro_categoria.id%TYPE := p_id;
BEGIN
    -- 1. Intentamos realizar la activación lógica
    -- Solo actualizamos si el registro EXISTE y está INACTIVO
    UPDATE foro_categoria
    SET activo = 1
    WHERE id = p_id
      AND activo = 0; -- Importante: Solo encender si está apagado

    -- 2. Verificamos si la actualización realmente hizo algo
    IF SQL%ROWCOUNT = 0 THEN
        -- Si no se afectaron filas, pueden ser dos casos:
        -- a) El ID no existe.
        -- b) El ID existe, pero ya estaba en activo = 1.
        
        -- Verificamos si existe para dar un mensaje más claro
        DECLARE
            v_count NUMBER;
        BEGIN
            SELECT COUNT(1) INTO v_count FROM foro_categoria WHERE id = p_id;
            
            IF v_count = 0 THEN
                RAISE NO_DATA_FOUND; -- Forzamos la excepción de "No Encontrado"
            ELSE
                -- Si existe, pero ya estaba activo
                DBMS_OUTPUT.PUT_LINE('Info: La categoria ' || p_id || ' ya estaba activa.');
                RETURN 0; -- Indicamos que no se hizo el cambio
            END IF;
        END;
    END IF;

    -- 3. Si SQL%ROWCOUNT > 0, la actualización fue exitosa
    RETURN 1; -- Éxito

EXCEPTION
    -- 4. Manejo de Excepciones Específicas
    
    WHEN NO_DATA_FOUND THEN
        -- Esta excepción se dispara si el SELECT COUNT(1) falla (nuestro RAISE)
        DBMS_OUTPUT.PUT_LINE('Error (NO_DATA_FOUND): No existe una categoria con ID: ' || v_id_not_found);
        RETURN 0; -- Fracaso

    -- 5. Manejo de Todas las Demás Excepciones
    WHEN OTHERS THEN
        -- Esta es la captura genérica para errores inesperados
        DBMS_OUTPUT.PUT_LINE('Error inesperado al activar categoria (' || SQLCODE || '): ' || SQLERRM);
        RETURN 0; -- Fracaso
END;
/
```

## Función Almacenada que actualiza registros

```sql
CREATE OR REPLACE FUNCTION FX_CATEGORIA_UPDATE
(
    p_id           IN foro_categoria.id%TYPE,
    p_nombre       IN foro_categoria.nombre%TYPE,
    p_descripcion  IN foro_categoria.descripcion%TYPE,
    p_super_id     IN foro_categoria.super_id%TYPE
)
RETURN NUMBER
IS
    -- Declaramos excepciones personalizadas para errores comunes
    e_parent_key_not_found EXCEPTION; -- Error de FK (el super_id no existe)
    PRAGMA EXCEPTION_INIT(e_parent_key_not_found, -2291); -- ORA-02291
    
    -- ORA-00001 (Unique constraint) ya tiene un nombre: DUP_VAL_ON_INDEX
    
BEGIN
    -- 1. Intentamos la actualización
    UPDATE foro_categoria
    SET
        nombre = p_nombre,
        descripcion = p_descripcion,
        super_id = p_super_id
    WHERE
        id = p_id;

    -- 2. Verificamos si la actualización realmente encontró el registro
    IF SQL%ROWCOUNT = 0 THEN
        -- Si no se afectaron filas, es porque el p_id no existe.
        -- Forzamos la excepción NO_DATA_FOUND para manejarla abajo.
        RAISE NO_DATA_FOUND;
    END IF;

    -- 3. Si todo va bien, retornamos éxito
    RETURN 1;

EXCEPTION
    -- 4. Manejo de Excepciones Específicas

    WHEN NO_DATA_FOUND THEN
        -- Se dispara si nuestro RAISE (SQL%ROWCOUNT = 0) se activa.
        DBMS_OUTPUT.PUT_LINE('Error (NO_DATA_FOUND): No existe categoria con ID: ' || p_id);
        RETURN 0; -- Fracaso

    WHEN DUP_VAL_ON_INDEX THEN
        -- Se dispara si p_nombre ya existe y hay una constraint UNIQUE(nombre)
        DBMS_OUTPUT.PUT_LINE('Error (DUP_VAL_ON_INDEX): El nombre "' || p_nombre || '" ya existe en otra categoria.');
        RETURN 0; -- Fracaso
        
    WHEN e_parent_key_not_found THEN
        -- Se dispara si p_super_id no existe en la tabla foro_categoria (FK)
        DBMS_OUTPUT.PUT_LINE('Error (FK Violada): El ID de categoria superior (super_id) "' || p_super_id || '" no existe.');
        RETURN 0; -- Fracaso

    WHEN OTHERS THEN
        -- Captura genérica para cualquier otro problema
        DBMS_OUTPUT.PUT_LINE('Error inesperado al actualizar (' || SQLCODE || '): ' || SQLERRM);
        RETURN 0; -- Fracaso
END;
/
```

------

# Implementación de Funciones

## Obtener todos los registros
```sql
SET SERVEROUTPUT ON;

DECLARE
    -- Variables para almacenar los datos del cursor
    v_mi_cursor SYS_REFCURSOR;
    v_id            foro_categoria.id%TYPE;
    v_nombre        foro_categoria.nombre%TYPE;
    v_descripcion   foro_categoria.descripcion%TYPE;
    v_super_id      foro_categoria.super_id%TYPE;
    v_activo        foro_categoria.activo%TYPE;
BEGIN
    -- 1. Obtener el cursor desde la función
    v_mi_cursor := FX_CATEGORIA_GET_ALL();

    -- 2. Recorrer (loop) el cursor para leer sus datos
    LOOP
        -- 3. Cargar la fila actual en las variables
        FETCH v_mi_cursor INTO v_id, v_nombre, v_descripcion, v_super_id, v_activo;
        
        -- 4. Salir del loop cuando no queden más filas
        EXIT WHEN v_mi_cursor%NOTFOUND;

        -- 5. Imprimir los resultados
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ' - Nombre: ' || v_nombre);
    END LOOP;

    -- 6. Cerrar el cursor
    CLOSE v_mi_cursor;
EXCEPTION
    WHEN OTHERS THEN
        IF v_mi_cursor%ISOPEN THEN
            CLOSE v_mi_cursor;
        END IF;
        RAISE;
END;
/
```
## Obtener todos datos de un registro
```sql
SET SERVEROUTPUT ON;

DECLARE
    -- Variables para almacenar los datos del cursor
    v_mi_cursor SYS_REFCURSOR;
    v_id            foro_categoria.id%TYPE;
    v_nombre        foro_categoria.nombre%TYPE;
    v_descripcion   foro_categoria.descripcion%TYPE;
    v_super_id      foro_categoria.super_id%TYPE;
    v_activo        foro_categoria.activo%TYPE;
BEGIN
    -- 1. Obtener el cursor desde la función
    v_mi_cursor := FX_CATEGORIA_GET_BY_ID(1);

    -- 2. Recorrer (loop) el cursor para leer sus datos
    LOOP
        -- 3. Cargar la fila actual en las variables
        FETCH v_mi_cursor INTO v_id, v_nombre, v_descripcion, v_super_id, v_activo;
        
        -- 4. Salir del loop cuando no queden más filas
        EXIT WHEN v_mi_cursor%NOTFOUND;

        -- 5. Imprimir los resultados
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ' - Nombre: ' || v_nombre);
    END LOOP;

    -- 6. Cerrar el cursor
    CLOSE v_mi_cursor;
EXCEPTION
    WHEN OTHERS THEN
        IF v_mi_cursor%ISOPEN THEN
            CLOSE v_mi_cursor;
        END IF;
        RAISE;
END;
/
```
