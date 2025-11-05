# Triggers en Oracle


## 📚 Contenido para Enseñar Triggers en Oracle

### 1\. Conceptos Fundamentales

  * **Definición:** ¿Qué es un **Trigger**? Es un bloque de código PL/SQL o Java asociado a una tabla y que se ejecuta de manera **automática** e **implícita** cuando ocurre un evento específico (DML o DDL) en la base de datos.
  * **Propósito Principal:** Aplicar reglas de negocio complejas, mantener la integridad referencial avanzada, registrar auditorías y automatizar tareas.
  * **Eventos:** Tipos de operaciones que disparan un *trigger* (INSERT, UPDATE, DELETE en tablas; CREATE, ALTER, DROP en la base de datos).

-----

### 2\. Sintaxis y Componentes Clave

La sintaxis básica de `CREATE TRIGGER` y sus partes esenciales:

  * **Momento del Disparo (`Timing`):**
      * `BEFORE`: Se ejecuta **antes** del evento (útil para validaciones o modificar datos).
      * `AFTER`: Se ejecuta **después** del evento (útil para auditoría o acciones secundarias).
      * `INSTEAD OF`: Utilizado en **vistas** para realizar acciones en las tablas base.
  * **Nivel de Disparo (`Level`):**
      * `FOR EACH ROW`: El *trigger* se ejecuta una vez por **cada fila afectada** por el evento (el más común).
      * `FOR EACH STATEMENT`: El *trigger* se ejecuta solo **una vez** por la sentencia SQL completa, sin importar cuántas filas se vean afectadas.
  * **Cláusula `WHEN` (Opcional):** Permite especificar una **condición adicional** para que el *trigger* se dispare.
  * **Variables de Referencia (`:OLD` y `:NEW`):** Acceden a los valores de las filas **antes** (`:OLD`) y **después** (`:NEW`) de la modificación (solo a nivel de fila).

-----

### 3\. Tipos de Triggers Comunes

  * **Triggers DML:** Se disparan por INSERT, UPDATE, o DELETE en tablas.
  * **Triggers DDL:** Se disparan por CREATE, ALTER, o DROP (útiles para monitorear cambios en la estructura de la DB).
  * **Triggers de Sistema/Base de Datos:** Se disparan por eventos como `STARTUP`, `SHUTDOWN`, o un `LOGON` de usuario.

-----

### 4\. Consideraciones Prácticas y Riesgos

  * **Orden de Ejecución:** Oracle no garantiza un orden de ejecución específico si varios *triggers* del mismo tipo operan sobre la misma tabla y evento.
  * **Triggers Mutantes:** Se produce un error cuando un *trigger* a nivel de fila intenta leer o modificar la tabla que lo disparó. Es crucial explicar cómo evitar esto (por ejemplo, con *compound triggers* o *triggers* a nivel de sentencia).
  * **Rendimiento:** Un uso excesivo o mal diseñado de *triggers* puede afectar significativamente el rendimiento de la base de datos.

-----

## 📝 Enunciado de Ejercicio para Laboratorio (Nivel Intermedio)

Este ejercicio es ideal para un laboratorio o evaluación, ya que requiere crear tablas, insertar datos y aplicar un *trigger* de auditoría.

### 🎯 Objetivo del Ejercicio

Crear un **Trigger BEFORE DELETE** a nivel de fila que registre automáticamente cuando se quiere eliminar un registro, se utilice la función almacenada y retorne un error.

### 🛠️ Pasos del Ejercicio

Contexto: Una empresa necesita hacer una página web tipo foro.

El Foro tendrá Entradas, las cuales tienen:
- título
- fecha
- contenido (texto)
- están en un categoría

Las categorías pueden contener a otras categorías y lo que interesa es almacenar, es la jerarquía de éstas para las entradas.

- nombre
- superior
- descripcion

Las entradas tendrán comentarios, pueden tener uno o más comentarios de los usuarios.

Los comentarios son solo texto, se debe mostrar el usuario y la fecha en que se hizo el comentario (post).

- comentario
- fecha
- usuario


#### 1\. Creación de las Tablas (Prerrequisito)

```sql
CREATE TABLE foro_usuario(
    id          NUMBER(9) PRIMARY KEY,
    username    VARCHAR2(50) NOT NULL UNIQUE,
    password    VARCHAR2(32) NOT NULL,
    email       VARCHAR2(50) NOT NULL UNIQUE,
    created_at  TIMESTAMP DEFAULT SYSDATE NOT NULL,
    activo      NUMBER(1) DEFAULT 0 NOT NULL
);

CREATE TABLE foro_categoria(
    id          NUMBER(9) PRIMARY KEY,
    nombre      VARCHAR2(50) NOT NULL UNIQUE,
    descripcion VARCHAR2(500) NOT NULL UNIQUE,
    super_id    NUMBER(9),
    activo      NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT FK_CATE_SUÉR_ID FOREIGN KEY (super_id) REFERENCES foro_categoria(id)
);

CREATE TABLE foro_entrada(
    id              NUMBER(9) PRIMARY KEY,
    titulo          VARCHAR2(50) NOT NULL UNIQUE,
    contenido       VARCHAR2(500) NOT NULL UNIQUE,
    created_at      TIMESTAMP DEFAULT SYSDATE NOT NULL,
    categoria_id    NUMBER(9) NOT NULL,
    usuario_id      NUMBER(9) NOT NULL,
    activo          NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT FK_ENTR_CATE_ID FOREIGN KEY (categoria_id) REFERENCES foro_categoria(id),
    CONSTRAINT FK_ENTR_USUA_ID FOREIGN KEY (usuario_id) REFERENCES foro_usuario(id)
);


CREATE TABLE foro_comentario(
    id          NUMBER(9) PRIMARY KEY,
    entrada_id  NUMBER(9) NOT NULL,
    texto       VARCHAR2(500) NOT NULL UNIQUE,
    created_at  TIMESTAMP DEFAULT SYSDATE NOT NULL,
    usuario_id  NUMBER(9) NOT NULL,
    activo      NUMBER(1) DEFAULT 0 NOT NULL,
    CONSTRAINT FK_COME_ENTR_ID FOREIGN KEY (entrada_id) REFERENCES foro_entrada(id),
    CONSTRAINT FK_COME_USUA_ID FOREIGN KEY (usuario_id) REFERENCES foro_usuario(id)
);
```
#### 2\. Secuencias

```sql
CREATE SEQUENCE SEQ_FORO_USUARIO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_FORO_CATEGORIA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_FORO_ENTRADA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_FORO_COMENTARIO START WITH 1 INCREMENT BY 1;
```
#### 3\. Datos de Ejemplo

```sql
INSERT INTO foro_usuario (id, username, password, email, activo)
VALUES (SEQ_FORO_USUARIO.NEXTVAL, 'scabezas', '4d186321c1a7f0f354b297e8914ab240','scabezas@scabezas.cl', 1);
INSERT INTO foro_usuario (id, username, password, email, activo)
VALUES (SEQ_FORO_USUARIO.NEXTVAL, 'lcalquin', '4d186321c1a7f0f354b297e8914ab240', 'lcalquin@um.cl', 1);
INSERT INTO foro_usuario (id, username, password, email, activo)
VALUES (SEQ_FORO_USUARIO.NEXTVAL, 'ehenriquez', '4d186321c1a7f0f354b297e8914ab240', 'ehenriquez@um.cl', 1);
INSERT INTO foro_usuario (id, username, password, email, activo)
VALUES (SEQ_FORO_USUARIO.NEXTVAL, 'rgres', '4d186321c1a7f0f354b297e8914ab240', 'rgres@um.cl', 1);
INSERT INTO foro_usuario (id, username, password, email, activo)
VALUES (SEQ_FORO_USUARIO.NEXTVAL, 'nrios', '4d186321c1a7f0f354b297e8914ab240', 'nrios@um.cl', 1);
INSERT INTO foro_usuario (id, username, password, email, activo)
VALUES (SEQ_FORO_USUARIO.NEXTVAL, 'amontaner', '4d186321c1a7f0f354b297e8914ab240', 'amontaner@um.cl', 1);

INSERT INTO foro_categoria (id, nombre, descripcion, super_id, activo) 
VALUES (SEQ_FORO_CATEGORIA.NEXTVAL, 'Hagalo Ud Mismo', 'Ven y comparte tus creaciones, ideas o soluciones. Aquí encontraras datos y tips, de como fabricar novedosos inventos en tu hogar, entre y disfrute creando!...', null, 1);
INSERT INTO foro_categoria (id, nombre, descripcion, super_id, activo) 
VALUES (SEQ_FORO_CATEGORIA.NEXTVAL, 'Hogar', 'Cosas del hogar', 1, 1);
INSERT INTO foro_categoria (id, nombre, descripcion, super_id, activo) 
VALUES (SEQ_FORO_CATEGORIA.NEXTVAL, 'Entretencion', 'Jueguitos', 1, 1);

INSERT INTO foro_entrada (id, titulo, contenido, categoria_id, usuario_id, activo)
VALUES (SEQ_FORO_ENTRADA.NEXTVAL, 'Jardin Flotante', 'Hagalo asi, uno dos', 21, 1, 1);
INSERT INTO foro_entrada (id, titulo, contenido, categoria_id, usuario_id, activo)
VALUES (SEQ_FORO_ENTRADA.NEXTVAL, 'Mesa de Pool', 'Hagalo de esta otra forma', 3, 2, 1);

INSERT INTO foro_comentario (id, entrada_id, texto, usuario_id, activo)
VALUES (SEQ_FORO_COMENTARIO.NEXTVAL, 1, 'No es flotante, está en tierra', 3, 1);
INSERT INTO foro_comentario (id, entrada_id, texto, usuario_id, activo)
VALUES (SEQ_FORO_COMENTARIO.NEXTVAL, 1, 'Si es flotante, está en el agua', 4, 1);
INSERT INTO foro_comentario (id, entrada_id, texto, usuario_id, activo)
VALUES (SEQ_FORO_COMENTARIO.NEXTVAL, 1, 'Me aburro, prefiero jugar en el telefono', 5, 1);

commit;
```

#### 4\. Funciones Almacenadas

```sql
CREATE OR REPLACE FUNCTION FX_CATEGORIA_ADD 
    (p_titulo IN VARCHAR2, p_descripcion IN VARCHAR2, p_super IN NUMBER) RETURN NUMBER IS
BEGIN
    INSERT INTO foro_categoria 
        (id, nombre, descripcion, super_id, activo) 
    VALUES 
        (SEQ_FORO_CATEGORIA.NEXTVAL, p_titulo, p_descripcion, p_super, 1);
    RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al crear categoria');
        RETURN 0;
END;
```

```sql
CREATE OR REPLACE FUNCTION FX_CATEGORIA_DELETE 
    (p_id IN NUMBER) RETURN NUMBER IS
BEGIN
    UPDATE foro_categoria SET activo = 0 WHERE id = p_id;
    RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al eliminar (apagar) categoria');
        RETURN 0;
END;
```

```sql
CREATE OR REPLACE FUNCTION FX_CATEGORIA_REACTIVATE 
    (p_id IN NUMBER) RETURN NUMBER IS
BEGIN
    UPDATE foro_categoria SET activo = 1 WHERE id = p_id;
    RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al eliminar (apagar) categoria');
        RETURN 0;
END;
```


#### 5\. Pruebas de las funciones almacenadas

```sql
SET SERVEROUTPUT ON;

BEGIN
    -- Llama a la función que actualiza ACTIVO = 0
    IF FX_CATEGORIA_DELETE(3) = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Categoria desactivada (Borrado Logico) correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al ejecutar el borrado logico para categoria.');
    END IF;
END;
/
```

```sql
SET SERVEROUTPUT ON;

BEGIN
    -- Llama a la función que actualiza ACTIVO = 0
    IF FX_CATEGORIA_REACTIVATE(3) = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Categoria REactivada (encendido Logico) correctamente.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error al ejecutar el encendido logico para categoria.');
    END IF;
END;
/
```

#### 6\. Trigger

```sql
CREATE OR REPLACE TRIGGER trg_categoria_delete
BEFORE DELETE ON foro_categoria
FOR EACH ROW
DECLARE
    -- 1. Declara esto como una transacción autónoma
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    v_resultado NUMBER;
BEGIN
    -- 2. Ejecuta tu función (que hace el UPDATE)
    -- Esto funciona porque está en una transacción separada.
    v_resultado := FX_CATEGORIA_DELETE(:OLD.id);

    -- 3. CONFIRMA (COMMIT) la transacción autónoma
    -- Esto guarda inmediatamente el cambio de activo = 0.
    COMMIT;

    -- 4. Cancela la operación DELETE original (que ya no se necesita)
    -- El borrado lógico ya se hizo y se guardó.
    RAISE_APPLICATION_ERROR(-20001, 'Borrado Logico: El registro (ID: ' || :OLD.id || ') se ha desactivado (activo = 0). La eliminacion fisica fue prevenida.');
END;
/
```

#### 7\. Prueba del Trigger

```sql
DELETE FROM foro_categoria WHERE id = 3;

SELECT id, activo FROM foro_categoria;
```

-----

Gracias =)