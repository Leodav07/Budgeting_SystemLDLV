DROP FUNCTION IF EXISTS fn_obtener_balance_subcategoria;

DELIMITER $$

CREATE FUNCTION fn_obtener_balance_subcategoria(f_id_presupuesto INT,
												f_id_subcategoria INT,
												f_anio MEDIUMINT,
												f_mes TINYINT)
RETURNS DECIMAL(8,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
	DECLARE monto_presupuestado DECIMAL(8,2);
    DECLARE monto_ejecutado DECIMAL(8,2);
    DECLARE balance DECIMAL(8,2);
    
	SET monto_ejecutado = fn_calcular_monto_ejecutado(f_id_subcategoria, f_anio, f_mes);
    
    SELECT COALESCE(monto_asignado, 0) INTO monto_presupuestado FROM presupuestos_detalles WHERE id_presupuesto = f_id_presupuesto 
																							AND id_subcategoria = f_id_subcategoria;
	
    SET balance = monto_presupuestado - monto_ejecutado;
    
    RETURN balance;
    
END $$

DELIMITER ;