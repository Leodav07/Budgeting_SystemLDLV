DROP FUNCTION IF EXISTS fn_dias_hasta_vencimiento;

DELIMITER $$

CREATE FUNCTION fn_dias_hasta_vencimiento(f_id_obligacion INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
		DECLARE dia_efectivo INT;
		DECLARE fecha_candidata DATE;
        
        SELECT LEAST(vence_dia, DAY(LAST_DAY(CURDATE()))) INTO dia_efectivo
        FROM obligaciones_fijas
        WHERE id_obligacion = f_id_obligacion;
      
		SET fecha_candidata = STR_TO_DATE(CONCAT_WS('-', YEAR(CURDATE()), LPAD(MONTH(CURDATE()), 2, '0'), LPAD(dia_efectivo, 2, '0')), 
    '	%Y-%m-%d');		
        
        RETURN DATEDIFF(fecha_candidata, CURDATE());
END $$
DELIMITER ;