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
    DECLARE porcentaje DECIMAL(8,2);
    
    SET monto_ejecutado = fn_calcular_monto_ejecutado(f_id_subcategoria, f_anio, f_mes);
    
	SELECT monto_asignado INTO monto_mensual_presupuestado FROM presupuestos_detalles WHERE f_id_presupuesto = id_presupuesto 
    AND f_id_subcategoria = id_subcategoria;
    
    SET  p_porcentaje = (monto_ejecutado / IFNULL(monto_mensual_presupuestado, 0)) * 100;

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
	SET p_monto_presupuestado = fn_calcular_total_categoria_mes(p_id_categoria, p_id_presupuestado, p_anio, p_mes);
    SET p_monto_ejecutado = fn_calcular_monto_ejecutado(p_id_categoria, p_anio, p_mes);
    SET p_porcentaje = (p_monto_presupuestado/p_monto_ejecutado) * 100;

END $$

DELIMITER ;
