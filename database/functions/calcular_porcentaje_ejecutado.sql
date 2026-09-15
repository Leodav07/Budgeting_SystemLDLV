DROP FUNCTION IF EXISTS fn_calcular_porcentaje_ejecutado;

DELIMITER $$

CREATE FUNCTION fn_calcular_porcentaje_ejecutado(f_id_subcategoria INT,
												 f_id_presupuesto INT,
                                                 f_anio MEDIUMINT,
                                                 f_mes TINYINT)
RETURNS DECIMAL(8,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
	DECLARE monto_ejecutado DECIMAL(8,2);
    DECLARE monto_mensual_presupuestado DECIMAL(8,2);
    DECLARE porcentaje DECIMAL(8,2);
    
    SET monto_ejecutado = fn_calcular_monto_ejecutado(f_id_subcategoria, f_anio, f_mes);
    
	SELECT monto_asignado INTO monto_mensual_presupuestado FROM presupuestos_detalles WHERE f_id_presupuesto = id_presupuesto 
    AND f_id_subcategoria = id_subcategoria;
    
    SET porcentaje = (monto_ejecutado / IFNULL(monto_mensual_presupuestado, 0)) * 100;
	RETURN porcentaje;
END $$

DELIMITER ;

SELECT fn_calcular_porcentaje_ejecutado(1, 2, 2025, 1) AS porcentaje; 
