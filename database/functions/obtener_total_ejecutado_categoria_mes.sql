DROP FUNCTION IF EXISTS fn_obtener_total_ejecutado_categoria_mes;

DELIMITER $$

CREATE FUNCTION fn_obtener_total_ejecutado_categoria_mes(f_id_categoria INT,
												f_anio INT,
                                                f_mes INT)
RETURNS DECIMAL(8,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
		DECLARE monto_total_mes DECIMAL(8,2);
        
		SELECT SUM(COALESCE(t.monto,0)) INTO monto_total_mes
        FROM transacciones t
        INNER JOIN subcategorias sc ON t.id_subcategoria = sc.id_subcategoria
        INNER JOIN categorias c ON sc.id_categoria = c.id_categoria
        WHERE c.id_categoria = f_id_categoria AND t.anio = f_anio AND t.mes = f_mes
		GROUP BY c.id_categoria;
	
        
        RETURN IFNULL(monto_total_mes,0);
END $$
DELIMITER ;