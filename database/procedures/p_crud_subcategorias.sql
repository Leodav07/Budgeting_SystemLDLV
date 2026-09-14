-- 1. sp insertar subcategoria

DROP PROCEDURE IF EXISTS sp_insertar_subcategoria;

DELIMITER $$

CREATE PROCEDURE sp_insertar_subcategoria(IN p_id_categoria INT,
									IN p_nombre VARCHAR(50),
									IN p_descripcion VARCHAR(255),
                                    IN p_creado_por VARCHAR(100))
BEGIN

	IF NOT EXISTS (SELECT 1 FROM categorias WHERE p_id_categoria = id_categoria) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CATEGORIA_NO_EXISTE';
	END IF;
    
	INSERT INTO subcategorias (id_categoria, nombre, descripcion, estado, por_defecto,
						  creado_por)
    VALUES (p_id_categoria, p_nombre, p_descripcion, true, false, p_creado_por);
END $$

DELIMITER ;

-- 2. sp actualizar subcategoria

DROP PROCEDURE IF EXISTS sp_actualizar_subcategoria;

DELIMITER $$

CREATE PROCEDURE sp_actualizar_subcategoria(IN p_id_subcategoria INT,
										 IN p_nombre VARCHAR(50),
                                         IN p_descripcion VARCHAR(255),
										 IN p_estado BOOLEAN,
										 IN p_modificado_por VARCHAR(100))

BEGIN 

	IF NOT EXISTS (SELECT 1 FROM subcategorias WHERE p_id_subcategoria = id_subcategoria) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SUBCATEGORIA_NO_EXISTE';
	END IF;
    
	UPDATE subcategorias
    SET nombre = p_nombre, descripcion = p_descripcion, estado = p_estado, modificado_por = p_modificado_por
	WHERE id_subcategoria = p_id_subcategoria;
END $$

DELIMITER ;


-- 3. sp eliminar subcategoria

DROP PROCEDURE IF EXISTS sp_eliminar_subcategoria;

DELIMITER $$

CREATE PROCEDURE sp_eliminar_subcategoria(IN p_id_subcategoria INT)

BEGIN 
	IF EXISTS (SELECT 1 FROM presupuestos_detalles WHERE id_subcategoria = p_id_subcategoria) 
				OR EXISTS (SELECT 1 FROM transacciones WHERE id_subcategoria = p_id_subcategoria) THEN
				SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'No es posible eliminar esta categoria ya que esta en uso en presupuestos o transacciones.';
			ELSE
				DELETE FROM subcategorias WHERE id_subcategoria = p_id_subcategoria;
	END IF;
		
END $$

DELIMITER ;


-- 4. consultar subcategoria especifica
DROP PROCEDURE IF EXISTS sp_consultar_subcategoria;

DELIMITER $$

CREATE PROCEDURE sp_consultar_subcategoria(IN p_id_subcategoria INT)

BEGIN 
	SELECT c.id_categoria, c.nombre AS nombre_categoria, c.descripcion AS descripcion_categoria, c.tipo, sc.nombre AS nombre_subcategoria,
    sc.descripcion AS descripcion_subcategoria, sc.estado, sc.por_defecto
    FROM categorias c 
    INNER JOIN subcategorias sc ON sc.id_categoria = c.id_categoria 
    WHERE sc.id_subcategoria = p_id_subcategoria;
END $$

DELIMITER ;


-- 5. sp listar subcategorias por categoria

DROP PROCEDURE IF EXISTS sp_listar_subcategorias_por_categoria;

DELIMITER $$

CREATE PROCEDURE sp_listar_subcategorias_por_categoria(IN p_id_categoria INT)

BEGIN 
	SELECT c.id_categoria, c.nombre AS nombre_categoria, c.descripcion AS descripcion_categoria, c.tipo, sc.nombre AS nombre_subcategoria,
    sc.descripcion AS descripcion_subcategoria, sc.estado, sc.por_defecto
    FROM categorias c 
    INNER JOIN subcategorias sc ON sc.id_categoria = c.id_categoria
    WHERE c.id_categoria = p_id_categoria;
 
END $$

DELIMITER ;