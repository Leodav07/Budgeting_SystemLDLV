-- 1. sp crear categoria

DROP PROCEDURE IF EXISTS sp_insertar_categoria;

DELIMITER $$

CREATE PROCEDURE sp_insertar_categoria(IN p_nombre VARCHAR(50),
									IN p_descripcion VARCHAR(250),
									IN p_tipo VARCHAR(20),
									IN p_icono_nombre VARCHAR(250),
									IN p_color_hex VARCHAR(50),
                                    IN p_orden INT,
                                    IN p_creado_por VARCHAR(100))
BEGIN
	INSERT INTO categorias (nombre, descripcion, tipo, icono_nombre, color_hex,
						  orden, creado_por)
    VALUES (p_nombre, p_descripcion, p_tipo, p_icono_nombre, p_color_hex, p_orden, p_creado_por);
END $$

DELIMITER ;

-- 1.1. trigger crear subcategoria por defecto

DROP TRIGGER IF EXISTS pordefecto_subcategoria_trigger;

DELIMITER $$
CREATE TRIGGER pordefecto_subcategoria_trigger
AFTER INSERT ON categorias
FOR EACH ROW
BEGIN
	INSERT INTO subcategorias (id_categoria, nombre, descripcion, por_defecto, creado_por)
	VALUES (NEW.id_categoria, 'General', 'Sin descripcion', true, 'trigger');
END $$
DELIMITER ;


-- 2. sp actualizar categoria
DROP PROCEDURE IF EXISTS sp_actualizar_categoria;

DELIMITER $$

CREATE PROCEDURE sp_actualizar_categoria(IN p_id_categoria INT,
									IN p_nombre VARCHAR(50),
									IN p_descripcion VARCHAR(250),
									IN p_modificado_por VARCHAR(100))
BEGIN
	IF NOT EXISTS (
    SELECT 1
    FROM categorias
    WHERE id_categoria = p_id_categoria
	) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'CATEGORIA_NO_EXISTE';
	END IF;
    
	UPDATE categorias
    SET	nombre = p_nombre, descripcion = p_descripcion, 
		modificado_por = p_modificado_por
    WHERE id_categoria = p_id_categoria;
END $$

DELIMITER ;


-- 3. sp eliminar categoria

DROP PROCEDURE IF EXISTS sp_eliminar_categoria;

DELIMITER $$

CREATE PROCEDURE sp_eliminar_categoria(IN p_categoria_id INT)
BEGIN

	DECLARE conteo INT;
    
    IF NOT EXISTS (
    SELECT 1
    FROM categorias
    WHERE id_categoria = p_id_categoria
	) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'CATEGORIA_NO_EXISTE';
	END IF;
    
    SELECT COUNT(*) INTO conteo
    FROM subcategorias 
    WHERE id_categoria = p_categoria_id AND por_defecto = false AND estado = true;
    
    IF conteo > 0 THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'SUBCATEGORIA_ACTIVA';
	ELSE
		DELETE FROM categorias WHERE id_categoria = p_categoria_id;
	END IF;
END $$

DELIMITER ;

-- 4. sp consultar categoria especifica

DROP PROCEDURE IF EXISTS sp_consultar_categoria;

DELIMITER $$

CREATE PROCEDURE sp_consultar_categoria(IN p_categoria_id INT)
BEGIN
IF NOT EXISTS (
    SELECT 1
    FROM categorias
    WHERE id_categoria = p_id_categoria
	) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'CATEGORIA_NO_EXISTE';
	END IF;
SELECT id_categoria, nombre, descripcion, tipo, icono_nombre, color_hex, orden FROM categorias WHERE p_categoria_id = id_categoria;
END $$

DELIMITER ;

-- 5. sp listar categorias

DROP PROCEDURE IF EXISTS sp_listar_categorias;

DELIMITER $$

CREATE PROCEDURE sp_listar_categorias(IN p_tipo VARCHAR(20))
BEGIN
	SELECT  id_categoria, nombre, descripcion, tipo, icono_nombre, color_hex, orden FROM categorias
    WHERE (p_tipo IS NULL OR p_tipo = tipo);
END $$

DELIMITER ;