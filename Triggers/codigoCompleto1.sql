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
CREATE SEQUENCE SEQ_FORO_USUARIO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_FORO_CATEGORIA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_FORO_ENTRADA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_FORO_COMENTARIO START WITH 1 INCREMENT BY 1;
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