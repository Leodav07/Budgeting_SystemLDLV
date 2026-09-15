DROP FUNCTION IF EXISTS fn_calcular_monto_ejecutado;

DELIMITER $$

CREATE FUNCTION fn_calcular_monto_ejecutado(f_id_subcategoria INT,
											f_anio MEDIUMINT,
                                            f_mes TINYINT)
RETURNS DECIMAL(8,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN 
	DECLARE monto_total DECIMAL(8,2);
    
	SELECT SUM(COALESCE(monto, 0)) INTO monto_total FROM transacciones
    WHERE f_id_subcategoria = id_subcategoria AND anio = f_anio AND mes = f_mes;
    RETURN IFNULL(monto_total,0);
END $$

DELIMITER ;

