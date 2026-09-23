-- sp calcular monto ejecutado en un mes especifico

DROP PROCEDURE IF EXISTS sp_calcular_monto_ejecutado_mes;

DELIMITER $$

CREATE PROCEDURE sp_calcular_monto_ejecutado_mes(IN p_id_subcategoria INT,
												 IN p_id_presupuesto INT,
                                                 IN p_anio MEDIUMINT,
                                                 IN p_mes TINYINT,
                                                 OUT p_monto_ejecutado DECIMAL(8,2))
BEGIN

	SELECT SUM(COALESCE(monto,0)) INTO p_monto_ejecutado FROM transacciones
    WHERE id_subcategoria = p_id_subcategoria AND id_presupuesto = p_id_presupuesto AND
    anio = p_anio AND mes = p_mes;
	
    SET p_monto_ejecutado = IFNULL(p_monto_ejecutado, 0);
END $$

DELIMITER ;

-- sp calcular porcentaje de ejecuacion en el mes

DROP PROCEDURE IF EXISTS sp_calcular_porcentaje_ejecucion_mes;

DELIMITER $$

CREATE PROCEDURE sp_calcular_porcentaje_ejecucion_mes(IN p_id_subcategoria INT,
												 IN p_id_presupuesto INT,
                                                 IN p_anio MEDIUMINT,
                                                 IN p_mes TINYINT,
                                                 OUT p_porcentaje DECIMAL(8,2))
BEGIN

	DECLARE monto_ejecutado DECIMAL(8,2);
    DECLARE monto_mensual_presupuestado DECIMAL(8,2);
    
    SET monto_ejecutado = fn_calcular_monto_ejecutado(p_id_subcategoria, p_anio, p_mes);
    
	SELECT monto_asignado INTO monto_mensual_presupuestado FROM presupuestos_detalles WHERE p_id_presupuesto = id_presupuesto 
    AND p_id_subcategoria = id_subcategoria;
    
    SET p_porcentaje = (monto_ejecutado / monto_mensual_presupuestado) * 100;
    SET p_porcentaje = IFNULL(p_porcentaje, 0);

END $$

DELIMITER ;

-- sp obtener resumen categoria mes

DROP PROCEDURE IF EXISTS sp_obtener_resumen_categoria_mes;

DELIMITER $$

CREATE PROCEDURE sp_obtener_resumen_categoria_mes(IN p_id_categoria INT,
												 IN p_id_presupuesto INT,
                                                 IN p_anio MEDIUMINT,
                                                 IN p_mes TINYINT,
                                                 OUT p_monto_presupuestado DECIMAL(8,2),
                                                 OUT p_monto_ejecutado DECIMAL(8,2),
                                                 OUT p_porcentaje DECIMAL(8,2))
BEGIN
	SET p_monto_presupuestado = fn_obtener_total_categoria_mes(p_id_categoria, p_id_presupuesto, p_anio, p_mes);
    SET p_monto_ejecutado = fn_obtener_total_ejecutado_categoria_mes(p_id_categoria, p_anio, p_mes);
    SET p_porcentaje = (p_monto_ejecutado/p_monto_presupuestado) * 100;
	SET p_porcentaje = IFNULL(p_porcentaje, 0);

END $$

DELIMITER ;

-- sp calcular el balance mensual


DROP PROCEDURE IF EXISTS sp_calcular_balance_mensual;

DELIMITER $$

CREATE PROCEDURE sp_calcular_balance_mensual(IN p_dni_usuario VARCHAR(18),
												 IN p_id_presupuesto INT,
                                                 IN p_anio MEDIUMINT,
                                                 IN p_mes TINYINT,
                                                 OUT p_total_ingresos DECIMAL(8,2),
                                                 OUT p_total_gastos DECIMAL(8,2),
                                                 OUT p_total_ahorros DECIMAL(8,2),
                                                 OUT p_balance_final DECIMAL(8,2))
BEGIN
	
	SELECT SUM(COALESCE(monto,0)) INTO p_total_ingresos FROM transacciones WHERE tipo = 'ingreso'
    AND usuario_dni = p_dni_usuario AND p_id_presupuesto = id_presupuesto AND anio = p_anio AND mes = p_mes;
    
    SELECT SUM(COALESCE(monto,0)) INTO p_total_gastos FROM transacciones WHERE tipo = 'gasto'
    AND usuario_dni = p_dni_usuario AND p_id_presupuesto = id_presupuesto AND anio = p_anio AND mes = p_mes;
    
    SELECT SUM(COALESCE(monto,0)) INTO p_total_ahorros FROM transacciones WHERE tipo = 'ahorro'
    AND usuario_dni = p_dni_usuario AND p_id_presupuesto = id_presupuesto AND anio = p_anio AND mes = p_mes;
    
	SET p_total_ingresos = IFNULL(p_total_ingresos, 0);
	SET p_total_gastos = IFNULL(p_total_gastos, 0);
    SET p_balance_final = IFNULL(p_total_ingresos,0) - IFNULL(p_total_gastos,0);
    SET p_total_ahorros = IFNULL(p_total_ahorros, 0);
	
END $$

DELIMITER ;


-- sp procesar obligaciones del mes


DROP PROCEDURE IF EXISTS sp_procesar_obligaciones_mes;

DELIMITER $$

CREATE PROCEDURE sp_procesar_obligaciones_mes(IN p_dni_usuario VARCHAR(18),
                                                 IN p_anio MEDIUMINT,
                                                 IN p_mes TINYINT,
                                                 IN p_id_presupuesto INT)
BEGIN
	
	SELECT * FROM obligaciones_fijas WHERE
    usuario_dni = p_dni_usuario AND vigente = 1 AND fecha_inicio <= LAST_DAY(STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-01'), '%Y-%m-%d')) AND 
    (fecha_final IS NULL OR fecha_final >= STR_TO_DATE(CONCAT(p_anio,'-',p_mes,'-01'), '%Y-%m-%d'));
	
END $$

DELIMITER ;


-- sp cerrar el presupuesto 


DROP PROCEDURE IF EXISTS sp_cerrar_presupuesto;

DELIMITER $$

CREATE PROCEDURE sp_cerrar_presupuesto(IN p_id_presupuesto INT,
										IN p_modificado_por VARCHAR(100))
BEGIN
	DECLARE p_anio_fin MEDIUMINT;
    DECLARE p_mes_fin MEDIUMINT;
    DECLARE p_estado VARCHAR(20);
    
    IF NOT EXISTS (SELECT 1 FROM presupuestos WHERE id_presupuesto = p_id_presupuesto) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PRESUPUESTO_NO_EXISTE';
	END IF;
    
    SELECT anio_fin, mes_fin, estado INTO p_anio_fin, p_mes_fin, p_estado
    FROM presupuestos WHERE id_presupuesto = p_id_presupuesto;
	
    
    IF ((p_anio_fin*100)+p_mes_fin > (YEAR(CURDATE())*100) + MONTH(curdate())) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PRESUPUESTO_AUN_VIGENTE';
	END IF;
	
    UPDATE presupuestos SET estado = 'cerrado', modificado_por = p_modificado_por WHERE id_presupuesto = p_id_presupuesto;
    
    WITH t1 AS (
    SELECT SUM(CASE WHEN tipo = 'ingreso' THEN monto ELSE 0 END) AS ingresos,
		  SUM(CASE WHEN tipo = 'gasto' THEN monto ELSE 0 END) AS gastos,
          SUM(CASE WHEN tipo = 'ahorro' THEN monto ELSE 0 END) AS ahorros
	FROM transacciones WHERE id_presupuesto = p_id_presupuesto
    )
    SELECT IFNULL(t1.ingresos, 0) AS total_ingresos, IFNULL(t1.gastos, 0) AS total_gastos, IFNULL(t1.ahorros, 0) AS total_ahorros, (IFNULL(t1.ingresos, 0) - IFNULL(t1.gastos, 0)) AS balance_final
    FROM t1;
    
END $$

DELIMITER ;

-- sp registrar la transaccion completa

DROP PROCEDURE IF EXISTS sp_registrar_transaccion_completa;

DELIMITER $$

CREATE PROCEDURE sp_registrar_transaccion_completa(IN p_usuario_dni VARCHAR(18), 
													IN p_id_presupuesto INT, 
                                                    IN p_anio MEDIUMINT, 
                                                    IN p_mes TINYINT,
													IN p_id_subcategoria INT, 
                                                    IN p_tipo VARCHAR(20),
                                                    IN p_descripcion VARCHAR(255),
                                                    IN p_monto DECIMAL(8,2), 
                                                    IN p_fecha DATE, 
                                                    IN p_metodo_pago VARCHAR(25),
                                                    IN p_num_factura VARCHAR(20),
                                                    IN p_observaciones VARCHAR(255),
													IN p_creado_por VARCHAR(100))
BEGIN
	DECLARE f_tipo VARCHAR(20);
    DECLARE f_id_categoria INT;
    
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario_dni = p_usuario_dni) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'USUARIO_NO_EXISTE';
	END IF;
    
      IF NOT EXISTS (SELECT 1 FROM subcategorias WHERE id_subcategoria = p_id_subcategoria) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SUBCATEGORIA_NO_EXISTE';
	END IF;
    
    IF NOT(fn_validar_vigencia_presupuesto(STR_TO_DATE(CONCAT(p_anio,'-',p_mes,'-01'), '%Y-%m-%d'), p_id_presupuesto)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TRANSACCION_FUERA_DE_VIGENCIA';
	END IF;
	
    SET f_id_categoria = fn_obtener_categoria_por_subcategoria(p_id_subcategoria);
    
    SELECT tipo INTO f_tipo FROM categorias WHERE id_categoria = f_id_categoria;
    
    IF p_tipo != f_tipo THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TIPO_TRANSACCION_INVALIDO';
	END IF;
    
    INSERT INTO transacciones (usuario_dni, id_presupuesto, anio, mes, id_subcategoria, tipo, descripcion, monto, fecha_ocurrido, metodo_pago, 
							num_factura, observaciones, creado_por)
	VALUES (p_usuario_dni, p_id_presupuesto, p_anio, p_mes, p_id_subcategoria, p_tipo, p_descripcion, p_monto, p_fecha, p_metodo_pago, 
			p_num_factura, p_observaciones, p_creado_por);
    

END $$

DELIMITER ;

-- sp crear presupuesto completo
DROP PROCEDURE IF EXISTS sp_crear_presupuesto_completo;

DELIMITER $$

CREATE PROCEDURE sp_crear_presupuesto_completo(IN p_usuario_dni VARCHAR(18), 
                                               IN p_nombre VARCHAR(40),
                                               IN p_descripcion VARCHAR(200),
                                               IN p_periodo_inicio DATE,
                                               IN p_periodo_fin DATE,
                                               IN p_lista_subcategorias_json JSON,
                                               IN p_creado_por VARCHAR(100))
BEGIN
    DECLARE v_id_generado INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario_dni = p_usuario_dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'USUARIO_NO_EXISTE';
    END IF;

    IF p_periodo_fin < p_periodo_inicio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PERIODO_INVALIDO';
    END IF;

    IF p_lista_subcategorias_json IS NULL OR JSON_LENGTH(p_lista_subcategorias_json) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PRESUPUESTO_SIN_DETALLES';
    END IF;

    IF EXISTS (
        SELECT 1 FROM presupuestos 
        WHERE usuario_dni = p_usuario_dni 
          AND estado = 'activo'
          AND (YEAR(p_periodo_inicio) * 100 + MONTH(p_periodo_inicio)) <= (anio_fin * 100 + mes_fin)
          AND (YEAR(p_periodo_fin) * 100 + MONTH(p_periodo_fin)) >= (anio_inicio * 100 + mes_inicio)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PRESUPUESTO_ACTIVO_SOLAPADO';
    END IF;

    
    START TRANSACTION;

    INSERT INTO presupuestos (usuario_dni, nombre, descripcion, anio_inicio, mes_inicio, anio_fin, mes_fin, estado, creado_por)
    VALUES (
        p_usuario_dni, 
        p_nombre, 
        p_descripcion, 
        YEAR(p_periodo_inicio), 
        MONTH(p_periodo_inicio), 
        YEAR(p_periodo_fin), 
        MONTH(p_periodo_fin), 
        'activo', 
        p_creado_por
    );

    SET v_id_generado = LAST_INSERT_ID();

    INSERT INTO presupuestos_detalles (id_presupuesto, id_subcategoria, monto_asignado, creado_por)
    SELECT 
        v_id_generado, 
        jt.id_subcategoria, 
        jt.monto_mensual, 
        p_creado_por
    FROM JSON_TABLE(
        p_lista_subcategorias_json, '$[*]'
        COLUMNS (
            id_subcategoria INT PATH '$.id_subcategoria',
            monto_mensual DECIMAL(8,2) PATH '$.monto_mensual'
        )
    ) AS jt;

    COMMIT;

END $$

DELIMITER ;

