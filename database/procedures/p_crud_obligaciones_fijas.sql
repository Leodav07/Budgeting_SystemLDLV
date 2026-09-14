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
		SIGNAL SQLSTATE '45009' SET MESSAGE_TEXT = 'SUBCATEGORIA_NO_EXISTE_DESACTIVADA';
	END IF;
    
	IF p_fecha_final IS NOT NULL THEN
		IF p_fecha_final < p_fecha_inicio THEN
			SIGNAL SQLSTATE '45010' SET MESSAGE_TEXT = 'FECHA_FINAL_MAYOR';
		END IF;
	END IF;
    
    IF NOT EXISTS (SELECT 1 FROM subcategorias s
		INNER JOIN categorias c ON s.id_categoria = c.id_categoria
        WHERE s.id_subcategoria = p_id_subcategoria AND c.tipo = 'gasto') THEN
		SIGNAL SQLSTATE '45011' SET MESSAGE_TEXT = 'SUBCATEGORIA_NO_GASTO';
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
										IN p_id_subcategoria INT,
                                        IN p_nombre VARCHAR(50),
                                        IN p_descripcion VARCHAR(255),
                                        IN p_monto_fijo DECIMAL (8,2),
                                        IN p_vence_dia TINYINT,
                                        IN p_fecha_inicio DATE,
                                        IN p_fecha_final DATE,
                                        IN p_modificado_por VARCHAR(100))

BEGIN 

	IF NOT EXISTS (SELECT 1 FROM obligaciones_fijas WHERE p_id_obligacion = id_obligacion) THEN
		SIGNAL SQLSTATE'45000' SET MESSAGE_TEXT = 'OBLIGACION_NO_EXISTE';
        END IF;
        
	IF NOT EXISTS (SELECT 1 FROM subcategorias WHERE id_subcategoria = p_id_subcategoria AND estado = true) THEN
		SIGNAL SQLSTATE '45009' SET MESSAGE_TEXT = 'SUBCATEGORIA_NO_EXISTE_DESACTIVADA';
	END IF;
    
	IF p_fecha_final IS NOT NULL THEN
		IF p_fecha_final < p_fecha_inicio THEN
			SIGNAL SQLSTATE '45010' SET MESSAGE_TEXT = 'FECHA_FINAL_MAYOR';
		END IF;
	END IF;
    
    IF NOT EXISTS (SELECT 1 FROM subcategorias s
		INNER JOIN categorias c ON s.id_categoria = c.id_categoria
        WHERE s.id_subcategoria = p_id_subcategoria AND c.tipo = 'gasto') THEN
		SIGNAL SQLSTATE '45011' SET MESSAGE_TEXT = 'SUBCATEGORIA_NO_GASTO';
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

CREATE PROCEDURE sp_eliminar_obligacion(IN p_id_obligacion INT,
										IN p_modificado_por VARCHAR(100))
BEGIN
	IF NOT EXISTS (SELECT 1 FROM obligaciones_fijas WHERE p_id_obligacion = id_obligacion) THEN
		SIGNAL SQLSTATE'45000' SET MESSAGE_TEXT = 'OBLIGACION_NO_EXISTE';
        END IF;
        
	UPDATE obligaciones_fijas
    SET vigente = false, modificado_por = p_modificado_por
    WHERE id_obligacion = p_id_obligacion;
END $$

DELIMITER ;

-- 4. sp consultar obligacion especifica

DROP PROCEDURE IF EXISTS sp_consultar_obligacion;

DELIMITER $$

CREATE PROCEDURE sp_consultar_obligacion(IN p_id_obligacion INT)
BEGIN 

IF NOT EXISTS (SELECT 1 FROM obligaciones_fijas WHERE p_id_obligacion = id_obligacion) THEN
		SIGNAL SQLSTATE'45000' SET MESSAGE_TEXT = 'OBLIGACION_NO_EXISTE';
        END IF;
        
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

CREATE PROCEDURE sp_listar_obligaciones_usuario(IN p_usuario_dni VARCHAR(18),
												IN p_vigente BOOLEAN)
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM usuarios WHERE p_usuario_dni = usuario_dni) THEN
		SIGNAL SQLSTATE'45000' SET MESSAGE_TEXT = 'USUARIO_NO_EXISTE';
        END IF;
        
	SELECT o.usuario_dni, o.id_subcategoria, o.nombre AS nombre_obligacion, o.descripcion AS descripcion_obligacion,
		o.monto_fijo, o.vence_dia, o.vigente, o.fecha_inicio, o.fecha_final
	FROM obligaciones_fijas o
    WHERE o.usuario_dni = p_usuario_dni AND o.vigente = p_vigente;
END $$

DELIMITER ;


