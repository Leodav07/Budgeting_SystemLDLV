-- 1. sp insertar presupuesto detalle

DROP PROCEDURE IF EXISTS sp_insertar_presupuesto_detalle;

DELIMITER $$

CREATE PROCEDURE sp_insertar_presupuesto_detalle(IN p_id_presupuesto INT,
										 IN p_id_subcategoria INT,
                                         IN p_monto_asignado DECIMAL(8,2),
										 IN p_justificacion_monto VARCHAR(255),
                                         IN p_creado_por VARCHAR(100))

BEGIN 
	IF NOT EXISTS (SELECT 1 FROM presupuestos WHERE p_id_presupuesto = id_presupuesto) THEN
       SIGNAL SQLSTATE '40007' SET MESSAGE_TEXT = 'PRESUPUESTO_NO_EXISTE'; 
	END IF;
    
	IF NOT EXISTS (SELECT 1 FROM subcategorias WHERE p_id_subcategoria = id_subcategoria AND estado = true) THEN
       SIGNAL SQLSTATE '40007' SET MESSAGE_TEXT = 'SUBCATEGORIA_NO_EXISTE'; 
	END IF;
    
	IF EXISTS (SELECT 1 FROM presupuestos_detalles WHERE p_id_presupuesto = id_presupuesto AND p_id_subcategoria = id_subcategoria) THEN
		SIGNAL SQLSTATE '40008' SET MESSAGE_TEXT = 'SUBCATEGORIA_YA_ASOCIADA';
	END IF;
	
    INSERT INTO presupuestos_detalles (id_presupuesto, id_subcategoria, monto_asignado,
					justificacion_monto, creado_por) 
	VALUES (p_id_presupuesto, p_id_subcategoria, p_monto_asignado, p_justificacion_monto,
		p_creado_por);
        
END $$

DELIMITER ;


-- 2. sp actualizar presupuesto detalle

DROP PROCEDURE IF EXISTS sp_actualizar_presupuesto_detalle;

DELIMITER $$

CREATE PROCEDURE sp_actualizar_presupuesto_detalle(IN p_id_presupuesto_detalle INT,
                                         IN p_monto_asignado DECIMAL(8,2),
										 IN p_justificacion_monto VARCHAR(255),
                                         IN p_modificado_por VARCHAR(100))

BEGIN 
	IF NOT EXISTS (SELECT 1 FROM presupuestos_detalles WHERE p_id_presupuesto_detalle = id_pdetalle) THEN
       SIGNAL SQLSTATE '40007' SET MESSAGE_TEXT = 'PRESUPUESTO_DETALLE_NO_EXISTE'; 
	END IF;
    
    
	UPDATE presupuestos_detalles
    SET monto_asignado = p_monto_asignado, justificacion_monto = p_justificacion_monto,
		modificado_por = p_modificado_por
	WHERE id_pdetalle = p_id_presupuesto_detalle;
END $$

DELIMITER ;

-- 3. sp eliminar presupuesto detalle

DROP PROCEDURE IF EXISTS sp_eliminar_presupuesto_detalle;

DELIMITER $$

CREATE PROCEDURE sp_eliminar_presupuesto_detalle(IN p_id_presupuesto_detalle INT)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM presupuestos_detalles WHERE p_id_presupuesto_detalle = id_pdetalle) THEN
       SIGNAL SQLSTATE '40007' SET MESSAGE_TEXT = 'PRESUPUESTO_DETALLE_NO_EXISTE'; 
	END IF;
    
    
	DELETE FROM presupuestos_detalles 
    WHERE id_pdetalle = p_id_presupuesto_detalle;
END $$

DELIMITER ;

-- 4. sp consultar presupuesto detalle especifico

DROP PROCEDURE IF EXISTS sp_consultar_presupuesto_detalle;

DELIMITER $$

CREATE PROCEDURE sp_consultar_presupuesto_detalle(IN p_id_presupuesto_detalle INT)
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM presupuestos_detalles WHERE p_id_presupuesto_detalle = id_pdetalle) THEN
       SIGNAL SQLSTATE '40007' SET MESSAGE_TEXT = 'PRESUPUESTO_DETALLE_NO_EXISTE'; 
	END IF;
    
	SELECT pd.id_presupuesto, pd.id_subcategoria, pd.monto_asignado, pd.justificacion_monto,
    sc.id_categoria, sc.nombre AS nombre_subcategoria, sc.descripcion AS descripcion_subcategoria, sc.estado AS estado_subcategoria, sc.por_defecto,
    c.nombre AS nombre_categoria, c.descripcion AS descripcion_categoria, c.tipo, c.icono_nombre, c.color_hex, c.orden 
    FROM presupuestos_detalles pd
    INNER JOIN subcategorias sc ON pd.id_subcategoria = sc.id_subcategoria 
    INNER JOIN categorias c ON sc.id_categoria = c.id_categoria
	WHERE pd.id_pdetalle = p_id_presupuesto_detalle;
END $$

DELIMITER ;


-- 5. sp listar presupuesto detalles 

DROP PROCEDURE IF EXISTS sp_listar_detalles_presupuesto;

DELIMITER $$

CREATE PROCEDURE sp_listar_detalles_presupuesto(IN p_id_presupuesto INT)
BEGIN 

	IF NOT EXISTS (SELECT 1 FROM presupuestos WHERE p_id_presupuesto = id_presupuesto) THEN
       SIGNAL SQLSTATE '40007' SET MESSAGE_TEXT = 'PRESUPUESTO_NO_EXISTE'; 
	END IF;
    
    
	SELECT p.usuario_dni, p.nombre AS nombre_presupuesto, p.descripcion AS descripcion_presupuesto, p.anio_inicio, p.mes_inicio, p.anio_fin, p.mes_fin,
	p.total_ingresos, p.total_gastos, p.total_ahorro, p.fecha_creacion, p.estado AS estado_presupuesto,
    pd.id_presupuesto, pd.id_subcategoria, pd.monto_asignado, pd.justificacion_monto,
    sc.id_categoria, sc.nombre AS nombre_subcategoria, sc.descripcion AS descripcion_subcategoria, sc.estado 
    AS estado_subcategoria, sc.por_defecto
    FROM presupuestos p
    INNER JOIN presupuestos_detalles pd ON p.id_presupuesto = pd.id_presupuesto
    INNER JOIN subcategorias sc ON pd.id_subcategoria = sc.id_subcategoria
    WHERE p.id_presupuesto = p_id_presupuesto;

END $$

DELIMITER ;


