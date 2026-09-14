-- 1. sp insertar presupuesto

DROP PROCEDURE IF EXISTS sp_insertar_presupuesto;

DELIMITER $$

CREATE PROCEDURE sp_insertar_presupuesto(IN p_usuario_dni VARCHAR(18),
										 IN p_nombre VARCHAR(40),
                                         IN p_descripcion VARCHAR(200),
										 IN p_anio_inicio MEDIUMINT,
                                         IN p_mes_inicio TINYINT,
                                         IN p_anio_final MEDIUMINT,
                                         IN p_mes_final TINYINT,
                                         IN p_total_ingresos DECIMAL(8,2),
                                         IN p_total_gastos DECIMAL(8,2),
                                         IN p_total_ahorro DECIMAL(8,2),
										 IN p_creado_por VARCHAR(100))

BEGIN 
	IF p_anio_inicio > p_anio_final THEN
		SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'ANIO_FINAL_MENOR';
	END IF;
    
    IF p_anio_inicio = p_anio_final THEN
		IF p_mes_inicio > p_mes_final THEN
			SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'MES_FINAL_MENOR';
		END IF;
	END IF;
    
    IF EXISTS (SELECT 1 FROM presupuestos WHERE usuario_dni = p_usuario_dni AND estado = 'activo'
					AND (anio_inicio * 100 + mes_inicio) <= (p_anio_final * 100 + p_mes_final) 
                    AND (anio_fin * 100 + mes_fin) >= (p_anio_inicio * 100 + p_mes_inicio)) THEN
                    SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'TRASLAPACION';
			END IF;
            
	INSERT INTO presupuestos (usuario_dni, nombre, descripcion, anio_inicio, mes_inicio, anio_fin, mes_fin,
							total_ingresos, total_gastos, total_ahorro, estado, creado_por)
	VALUES (p_usuario_dni, p_nombre, p_descripcion, p_anio_inicio, p_mes_inicio, p_anio_final, p_mes_final, p_total_ingresos,
			p_total_gastos, p_total_ahorro, 'activo', p_creado_por);
END $$

DELIMITER ;


-- 2. sp actualizar presupuesto

DROP PROCEDURE IF EXISTS sp_actualizar_presupuesto;

DELIMITER $$

CREATE PROCEDURE sp_actualizar_presupuesto(IN p_usuario_dni VARCHAR(18),
										IN p_id_presupuesto INT,
										 IN p_nombre VARCHAR(40),
                                         IN p_descripcion VARCHAR(200),
										 IN p_anio_inicio MEDIUMINT,
                                         IN p_mes_inicio TINYINT,
                                         IN p_anio_final MEDIUMINT,
                                         IN p_mes_final TINYINT,
                                         IN p_total_ingresos DECIMAL(8,2),
                                         IN p_total_gastos DECIMAL(8,2),
                                         IN p_total_ahorro DECIMAL(8,2),
                                         IN p_estado VARCHAR(20),
										 IN p_modificado_por VARCHAR(100))

BEGIN 

IF NOT EXISTS (SELECT 1 FROM presupuestos WHERE p_id_presupuesto = id_presupuesto) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PRESUPUESTO_NO_EXISTE';
	END IF;
    
IF p_anio_inicio > p_anio_final THEN
		SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'ANIO_FINAL_MENOR';
	END IF;
    
    IF p_anio_inicio = p_anio_final THEN
		IF p_mes_inicio > p_mes_final THEN
			SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'MES_FINAL_MENOR';
		END IF;
	END IF;
    
    IF EXISTS (SELECT 1 FROM presupuestos WHERE usuario_dni = p_usuario_dni AND estado = 'activo'
					AND (anio_inicio * 100 + mes_inicio) <= (p_anio_final * 100 + p_mes_final) 
                    AND (anio_fin * 100 + mes_fin) >= (p_anio_inicio * 100 + p_mes_inicio)) THEN
                    SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'TRASLAPACION';
			END IF;
            
	UPDATE presupuestos
    SET nombre = p_nombre, descripcion = p_descripcion, anio_inicio = p_anio_inicio, mes_inicio = p_mes_inicio, 
			anio_fin = p_anio_final, mes_fin = p_mes_final, 
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
	
    IF NOT EXISTS (SELECT 1 FROM presupuestos WHERE p_id_presupuesto = id_presupuesto) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PRESUPUESTO_NO_EXISTE';
	END IF;
    
    
	IF EXISTS (SELECT 1 FROM transacciones WHERE id_presupuesto = p_id_presupuesto) THEN
		SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'PRESUPUESTO_ASOCIADO';
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

    IF NOT EXISTS (SELECT 1 FROM presupuestos WHERE p_id_presupuesto = id_presupuesto) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PRESUPUESTO_NO_EXISTE';
	END IF;
    
	SELECT usuario_dni, nombre, descripcion, anio_inicio, mes_inicio, anio_fin, mes_fin, total_ingresos, 
			total_gastos, total_ahorro, fecha_creacion, estado
	FROM presupuestos
    WHERE id_presupuesto = p_id_presupuesto;
END $$

DELIMITER ;


-- 5. sp listar presupuesto de usuario

DROP PROCEDURE IF EXISTS sp_listar_presupuestos_usuario;

DELIMITER $$

CREATE PROCEDURE sp_listar_presupuestos_usuario(IN p_usuario_dni VARCHAR(18), IN p_estado VARCHAR(20))
BEGIN 
	SELECT id_presupuesto, usuario_dni, nombre, descripcion, anio_inicio, mes_inicio, anio_fin, mes_fin, total_ingresos, 
			total_gastos, total_ahorro, fecha_creacion, estado
	FROM presupuestos
    WHERE usuario_dni = p_usuario_dni AND 
		(p_estado IS NULL OR p_estado = estado);
END $$

DELIMITER ;

