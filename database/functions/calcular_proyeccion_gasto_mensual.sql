DROP FUNCTION IF EXISTS fn_calcular_proyeccion_gasto_mensual;

DELIMITER $$

CREATE FUNCTION fn_calcular_proyeccion_gasto_mensual(f_id_subcategoria INT,
													 f_anio MEDIUMINT,
													  f_mes TINYINT)
RETURNS DECIMAL(8,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
		DECLARE monto_gastado DECIMAL(8,2);
        DECLARE dias_transcurridos INT;
        DECLARE dias_totales INT;
        
	   SET monto_gastado = fn_calcular_monto_ejecutado(f_id_subcategoria, f_anio, f_mes);
       SET dias_transcurridos = DAY(curdate());
       SET dias_totales = DAY(LAST_DAY(CURDATE()));
	   RETURN (monto_gastado / dias_transcurridos) * dias_totales;
       
       
END $$
DELIMITER ;