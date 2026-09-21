DROP FUNCTION IF EXISTS fn_obtener_promedio_gasto_subcategoria;

DELIMITER $$

CREATE FUNCTION fn_obtener_promedio_gasto_subcategoria(f_dni_usuario VARCHAR(18),
													f_id_subcategoria INT,
													 cantidad_meses INT)
RETURNS DECIMAL(8,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
		DECLARE x INT;
        DECLARE suma_total DECIMAL(8,2);
        DECLARE gasto_temporal DECIMAL(8,2);
        DECLARE fechas INT;
        DECLARE f_anio, f_mes INT;
        
        SET suma_total = 0;
        SET x = 1;
        SET fechas = (YEAR(CURDATE()) * 100) + MONTH(CURDATE());
		SET f_anio = fechas DIV 100;
		SET f_mes = fechas % 100;
        
        WHILE x <= cantidad_meses DO
            SELECT SUM(COALESCE(monto, 0)) INTO gasto_temporal FROM transacciones
            WHERE usuario_dni = f_dni_usuario AND id_subcategoria = f_id_subcategoria AND anio = f_anio AND mes = f_mes;
            
            SET suma_total = suma_total + COALESCE(gasto_temporal, 0);
            
			SET x = x + 1;

            IF f_mes = 0 THEN
				SET f_anio = f_anio - 1;
                SET f_mes = 12;
			ELSE 
				SET f_mes = f_mes - 1;
			END IF;
            
            
        END WHILE;
       
       return suma_total / cantidad_meses;
       
END $$
DELIMITER ;