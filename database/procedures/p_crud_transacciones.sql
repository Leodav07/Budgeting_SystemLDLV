-- 1. sp insertar transaccion

DROP PROCEDURE IF EXISTS sp_insertar_transaccion;

DELIMITER $$

CREATE PROCEDURE sp_insertar_transaccion(IN p_usuario_dni VARCHAR(18),
													IN p_id_presupuesto INT,
													IN p_anio MEDIUMINT,
                                                    IN p_mes MEDIUMINT,
                                                    IN p_id_subcategoria INT,
                                                    IN p_tipo VARCHAR(20),
                                                    IN p_descripcion VARCHAR(255),
                                                    IN p_monto DECIMAL(8,2),
                                                    IN p_fecha_ocurrido DATETIME,
                                                    IN p_metodo_pago VARCHAR(20),
                                                    IN p_num_factura VARCHAR(20),
                                                    IN p_observaciones VARCHAR(255),
                                                    IN p_creado_por VARCHAR(100))
BEGIN
	IF NOT EXISTS (SELECT 1 FROM subcategorias sc
                INNER JOIN categorias c ON sc.id_categoria = c.id_categoria
                WHERE sc.id_subcategoria = p_id_subcategoria AND c.tipo = p_tipo) THEN
		SIGNAL SQLSTATE '45015' SET MESSAGE_TEXT = 'El tipo de transaccion debe coincidir con el mismo tipo de categoria.';
	END IF;
	
    IF NOT EXISTS (SELECT 1 FROM presupuestos p
                WHERE p.id_presupuesto = p_id_presupuesto
                AND (p.anio_inicio * 100 + p.mes_inicio) <= (p_anio * 100 + p_mes) 
                AND (p.anio_fin * 100 + p.mes_fin) >= (p_anio * 100 + p_mes)) THEN
		SIGNAL SQLSTATE '45016' SET MESSAGE_TEXT = 'El año y mes deben estar dentro del periodo de vigencia del presupuesto asociado.';
	END IF;

	INSERT INTO transacciones (usuario_dni, id_presupuesto, anio, mes, id_subcategoria, tipo, descripcion, monto, fecha_ocurrido, metodo_pago, num_factura, observaciones, creado_por)
    VALUES (p_usuario_dni, p_id_presupuesto, p_anio, p_mes, p_id_subcategoria, p_tipo, p_descripcion, p_monto, p_fecha_ocurrido, p_metodo_pago, p_num_factura, p_observaciones, p_creado_por);
	
END $$

DELIMITER ;

-- 2. sp actualizar transaccion

DROP PROCEDURE IF EXISTS sp_actualizar_transaccion;

DELIMITER $$

CREATE PROCEDURE sp_actualizar_transaccion(IN p_id_transaccion INT,
													IN p_id_presupuesto INT,
													IN p_anio MEDIUMINT,
                                                    IN p_mes MEDIUMINT,
                                                    IN p_id_subcategoria INT,
                                                    IN p_tipo VARCHAR(20),
                                                    IN p_descripcion VARCHAR(255),
                                                    IN p_monto DECIMAL(8,2),
                                                    IN p_fecha_ocurrido DATETIME,
                                                    IN p_metodo_pago VARCHAR(20),
                                                    IN p_num_factura VARCHAR(20),
                                                    IN p_observaciones VARCHAR(255),
                                                    IN p_modificado_por VARCHAR(100))
BEGIN
	IF NOT EXISTS (SELECT 1 FROM subcategorias sc
                INNER JOIN categorias c ON sc.id_categoria = c.id_categoria
                WHERE sc.id_subcategoria = p_id_subcategoria AND c.tipo = p_tipo) THEN
		SIGNAL SQLSTATE '45015' SET MESSAGE_TEXT = 'El tipo de transaccion debe coincidir con el mismo tipo de categoria.';
	END IF;
    
	   IF NOT EXISTS (SELECT 1 FROM presupuestos p
                WHERE p.id_presupuesto = p_id_presupuesto
                AND (p.anio_inicio * 100 + p.mes_inicio) <= (p_anio * 100 + p_mes) 
                AND (p.anio_fin * 100 + p.mes_fin) >= (p_anio * 100 + p_mes)) THEN
		SIGNAL SQLSTATE '45016' SET MESSAGE_TEXT = 'El año y mes deben estar dentro del periodo de vigencia del presupuesto asociado.';
	END IF;
    
    UPDATE transacciones
    SET id_presupuesto = p_id_presupuesto, anio = p_anio, mes = p_mes, id_subcategoria = p_id_subcategoria, tipo = p_tipo,
		descripcion = p_descripcion, monto = p_monto, fecha_ocurrido = p_fecha_ocurrido, metodo_pago = p_metodo_pago, num_factura = p_num_factura, observaciones = p_observaciones, modificado_por = p_modificado_por
	WHERE id_transaccion = p_id_transaccion;

END $$
DELIMITER $$


-- 3. sp consultar eliminar transaccion

DROP PROCEDURE IF EXISTS sp_eliminar_transaccion;

DELIMITER $$

CREATE PROCEDURE sp_eliminar_transaccion(IN p_id_transaccion INT)
BEGIN
	
    IF EXISTS (SELECT 1 FROM transacciones WHERE id_transaccion = p_id_transaccion AND tipo = 'ahorro') THEN
		SIGNAL SQLSTATE '45018' SET MESSAGE_TEXT = 'Problemas al eliminar transacciones de tipo ahorro.';
	END IF;
    
    DELETE FROM transacciones WHERE id_transaccion = p_id_transaccion;

END;

DELIMITER ;

-- 4. sp consultar transaccion especifica

DROP PROCEDURE IF EXISTS sp_consultar_transaccion;

DELIMITER $$

CREATE PROCEDURE sp_consultar_transaccion(IN p_id_transaccion INT)
BEGIN
	
    SELECT usuario_dni, id_presupuesto, anio, mes, id_subcategoria, tipo, descripcion, monto, fecha_ocurrido, metodo_pago, num_factura, observaciones, fecha_registro
    FROM transacciones
    WHERE id_transaccion = p_id_transaccion;

END $$

DELIMITER ;

-- 5. sp listar transaccion presupuesto

DROP PROCEDURE IF EXISTS sp_listar_transacciones_presupuesto;

DELIMITER $$

CREATE PROCEDURE sp_listar_transacciones_presupuesto(IN p_id_presupuesto INT)
BEGIN
	
    SELECT t.usuario_dni, t.id_presupuesto, t.anio, t.mes, t.id_subcategoria, t.tipo, t.descripcion, t.monto, t.fecha_ocurrido, t.metodo_pago, t.num_factura, t.observaciones, t.fecha_registro
    FROM transacciones t
    WHERE t.id_presupuesto = p_id_presupuesto;

END $$

DELIMITER ;