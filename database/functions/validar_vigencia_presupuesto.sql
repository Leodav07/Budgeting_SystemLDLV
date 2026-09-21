DROP FUNCTION IF EXISTS fn_validar_vigencia_presupuesto;

DELIMITER $$

CREATE FUNCTION fn_validar_vigencia_presupuesto(f_fecha DATE,
												f_id_presupuesto INT)
RETURNS BOOLEAN
NOT DETERMINISTIC
READS SQL DATA
BEGIN
		DECLARE fecha_a_calcular INT;
        DECLARE valido BOOLEAN;
        SET fecha_a_calcular = (YEAR(f_fecha) * 100) + MONTH(f_fecha);
		IF EXISTS (SELECT 1 FROM presupuestos WHERE id_presupuesto = f_id_presupuesto AND
					((anio_inicio * 100) + mes_inicio) <= fecha_a_calcular AND ((anio_fin * 100) + mes_fin) >= fecha_a_calcular) THEN
                    SET valido = true;
			ELSE
					SET valido = false;
                    
		END IF;
		RETURN valido;
END $$
DELIMITER ;