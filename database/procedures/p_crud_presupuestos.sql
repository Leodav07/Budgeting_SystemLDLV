-- 1. sp insertar presupuesto

DROP PROCEDURE IF EXISTS sp_insertar_presupuesto;

DELIMITER $$

CREATE PROCEDURE sp_insertar_presupuesto(IN p_usuario_dni VARCHAR(18),
										 IN p_nombre VARCHAR(40),
                                         IN p_descripcion VARCHAR(200),
										 IN p_anio_inicio DATE,
                                         IN p_mes_inicio DATE,
                                         IN p_anio_final DATE,
                                         IN p_mes_final DATE,
                                         IN p_total_ingresos DECIMAL(8,2),
                                         IN p_total_gastos DECIMAL(8,2),
                                         IN p_total_ahorro DECIMAL(8,2))

BEGIN 
	INSERT INTO presupuestos (usuario_dni, nombre, descripcion, anio_inicio, mes_inicio, anio_fin, mes_fin,
							total_ingresos, total_gastos, total_ahorro, estado)
	VALUES (p_usuario_dni, p_nombre, p_descripcion, p_anio_inicio, p_mes_inicio, p_anio_final, p_mes_final, p_total_ingresos,
			p_total_gastos, p_total_ahorro, 'activo');
END $$

DELIMITER ;


-- 2. sp actualizar presupuesto

DROP PROCEDURE IF EXISTS sp_actualizar_presupuesto;

DELIMITER $$

CREATE PROCEDURE sp_actualizar_presupuesto(IN p_id_presupuesto INT,
										 IN p_nombre VARCHAR(40),
                                         IN p_descripcion VARCHAR(200),
										 IN p_anio_inicio DATE,
                                         IN p_mes_inicio DATE,
                                         IN p_anio_final DATE,
                                         IN p_mes_final DATE,
                                         IN p_total_ingresos DECIMAL(8,2),
                                         IN p_total_gastos DECIMAL(8,2),
                                         IN p_total_ahorro DECIMAL(8,2),
                                         IN p_estado VARCHAR(20),
										 IN p_modificado_por VARCHAR(100))

BEGIN 
	UPDATE presupuestos
    SET usuario_dni = p_usuario_dni, nombre = p_nombre, descripcion = p_descripcion, anio_fin = p_anio_final, mes_fin = p_mes_final, 
            total_ingresos = p_total_ingresos, total_gastos = p_total_gastos, total_ahorro = p_total_ahorro, estado = p_estado,
            modificado_por = p_modificado_por
	WHERE id_presupuesto = p_id_presupuesto;
END $$

DELIMITER ;

-- 3. sp eliminar presupuesto

DROP PROCEDURE IF EXISTS sp_eliminar_presupuesto;

DELIMITER $$

CREATE PROCEDURE sp_eliminar_presupuesto(IN p_id_presupuesto INT)
BEGIN
	IF EXISTS (SELECT 1 FROM transacciones WHERE id_presupuesto = p_id_presupuesto) THEN
		SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'No se pudo eliminar el presupuesto, esta asociada a una transaccion';
	ELSE
		DELETE FROM presupuestos WHERE id_presupuesto = p_id_presupuesto;
	END IF;
END $$

DELIMITER ;

-- 4. sp consultar presupuesto especifico

DROP PROCEDURE IF EXISTS sp_consultar_presupuesto;

DELIMITER $$

CREATE PROCEDURE sp_consultar_presupuesto(IN p_id_presupuesto INT)
BEGIN 
	SELECT usuario_dni, nombre, descripcion, anio_inicio, mes_inicio, anio_fin, mes_fin, total_ingresos, 
			total_gastos, total_ahorro, fecha_creacion, estado
	FROM presupuestos
    WHERE id_presupuesto = p_id_presupuesto;
END $$

DELIMITER ;


-- 5. sp listar presupuesto de usuario