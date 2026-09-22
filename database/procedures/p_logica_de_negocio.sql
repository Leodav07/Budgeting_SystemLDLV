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
    
	SELECT monto_asignado INTO monto_mensual_presupuestado FROM presupuestos_detalles WHERE f_id_presupuesto = id_presupuesto 
    AND f_id_subcategoria = id_subcategoria;
    
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
    SET p_porcentaje = (p_monto_presupuestado/p_monto_ejecutado) * 100;
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
	
	
END $$

DELIMITER ;

