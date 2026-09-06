-- 1. sp insertar obligacion fija

DROP PROCEDURE IF EXISTS sp_insertar_obligacion;

DELIMITER $$

CREATE PROCEDURE sp_insertar_obligacion(IN p_usuario_dni VARCHAR(18),
										IN p_id_subcategoria INT,
                                        IN p_nombre VARCHAR(50),
                                        IN p_descripcion VARCHAR(255),
                                        IN p_monto_fijo DECIMAL (8,2),
                                        IN p_vence_dia TINYINT,
                                        IN p_fecha_inicio DATE,
                                        IN p_fecha_final DATE,
                                        IN p_creado_por VARCHAR(100))

BEGIN 
	IF NOT EXISTS (SELECT 1 FROM subcategorias WHERE id_subcategoria = p_id_subcategoria AND estado = true) THEN
		SIGNAL SQLSTATE '40009' SET MESSAGE_TEXT = 'La categoria no existe o no esta activa.';
	END IF;
    
	IF p_fecha_final IS NOT NULL THEN
		IF p_fecha_final < p_fecha_inicio THEN
			SIGNAL SQLSTATE '40010' SET MESSAGE_TEXT = 'La fecha final debe ser mayor que la fecha inicial.';
		END IF;
	END IF;
    
    IF NOT (SELECT 1 FROM subcategorias s
		INNER JOIN categorias c ON s.id_categoria = c.id_categoria
        WHERE s.id_subcategoria = p_id_subcategoria AND c.tipo = 'gasto') THEN
		SIGNAL SQLSTATE '40011' SET MESSAGE_TEXT = 'La subcategoria debe pertenecer al tipo GASTO dentro de categoria.';
	END IF;
    
    INSERT INTO obligaciones_fijas (usuario_dni, id_subcategoria, nombre, descripcion, monto_fijo,
				vence_dia, fecha_inicio, fecha_final, creado_por)
		VALUES (p_usuario_dni, p_id_subcategoria, p_nombre, p_descripcion, p_monto_fijo, 
        p_vence_dia, p_fecha_inicio, p_fecha_final, p_creado_por);

END $$

DELIMITER ;


-- 2. sp actualizar obligaciones fijas

DROP PROCEDURE IF EXISTS sp_actualizar_obligacion;

DELIMITER $$

CREATE PROCEDURE sp_actualizar_obligacion(IN p_id_obligacion INT,
                                        IN p_nombre VARCHAR(50),
                                        IN p_descripcion VARCHAR(255),
                                        IN p_monto_fijo DECIMAL (8,2),
                                        IN p_vence_dia TINYINT,
                                        IN p_fecha_inicio DATE,
                                        IN p_fecha_final DATE,
                                        IN p_modificado_por VARCHAR(100))

BEGIN 
IF NOT EXISTS (SELECT 1 FROM subcategorias WHERE id_subcategoria = p_id_subcategoria AND estado = true) THEN
		SIGNAL SQLSTATE '40009' SET MESSAGE_TEXT = 'La categoria no existe o no esta activa.';
	END IF;
    
	IF p_fecha_final IS NOT NULL THEN
		IF p_fecha_final < p_fecha_inicio THEN
			SIGNAL SQLSTATE '40010' SET MESSAGE_TEXT = 'La fecha final debe ser mayor que la fecha inicial.';
		END IF;
	END IF;
    
    IF NOT (SELECT 1 FROM subcategorias s
		INNER JOIN categorias c ON s.id_categoria = c.id_categoria
        WHERE s.id_subcategoria = p_id_subcategoria AND c.tipo = 'gasto') THEN
		SIGNAL SQLSTATE '40011' SET MESSAGE_TEXT = 'La subcategoria debe pertenecer al tipo GASTO dentro de categoria.';
	END IF;
    
    UPDATE obligaciones_fijas
    SET nombre = p_nombre, descripcion = p_descripcion, monto_fijo = p_monto_fijo,
    vence_dia = p_vence_dia, fecha_inicio = p_fecha_inicio, fecha_final = p_fecha_final,
    modificado_por = p_modificado_por
    WHERE id_obligacion = p_id_obligacion;
    
END $$

DELIMITER ;

-- 3. sp eliminar obligacion

DROP PROCEDURE IF EXISTS sp_eliminar_obligacion;

DELIMITER $$

CREATE PROCEDURE sp_eliminar_obligacion(IN p_id_obligacion INT)
BEGIN
	UPDATE obligaciones_fijas
    SET vigente = false
    WHERE id_obligacion = p_id_obligacion;
END $$

DELIMITER ;

-- 4. sp consultar obligacion especifica

DROP PROCEDURE IF EXISTS sp_consultar_obligacion;

DELIMITER $$

CREATE PROCEDURE sp_consultar_obligacion(IN p_id_obligacion INT)
BEGIN 
	SELECT o.usuario_dni, o.id_subcategoria, o.nombre AS nombre_obligacion, o.descripcion AS descripcion_obligacion,
		o.monto_fijo, o.vence_dia, o.vigente, o.fecha_inicio, o.fecha_final,
        sc.nombre AS nombre_subcategoria, sc.descripcion AS descripcion_subcategoria, sc.estado, sc.por_defecto
	FROM obligaciones_fijas o
    INNER JOIN subcategorias sc ON o.id_subcategoria = sc.id_subcategoria
    WHERE o.id_obligacion = p_id_obligacion;
END $$

DELIMITER ;


-- 5. sp listar obligaciones usuario

DROP PROCEDURE IF EXISTS sp_listar_obligaciones_usuario;

DELIMITER $$

CREATE PROCEDURE sp_listar_obligaciones_usuario(IN p_usuario_dni INT,
												IN p_vigente BOOLEAN)
BEGIN 
	SELECT o.usuario_dni, o.id_subcategoria, o.nombre AS nombre_obligacion, o.descripcion AS descripcion_obligacion,
		o.monto_fijo, o.vence_dia, o.vigente, o.fecha_inicio, o.fecha_final
	FROM obligaciones_fijas o
    WHERE o.usuario_dni = p_usuario_dni AND o.vigente = p_vigente;
END $$

DELIMITER ;


