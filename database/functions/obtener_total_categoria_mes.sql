DROP FUNCTION IF EXISTS fn_obtener_total_categoria_mes;

DELIMITER $$

CREATE FUNCTION fn_obtener_total_categoria_mes(f_id_categoria INT,
											   f_id_presupuesto INT,
												f_anio MEDIUMINT,
                                                f_mes TINYINT)
RETURNS DECIMAL(8,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
		DECLARE monto_total_mes DECIMAL(8,2);
        
		SELECT SUM(COALESCE(pd.monto_asignado,0)) INTO monto_total_mes
        FROM presupuestos_detalles pd
        INNER JOIN subcategorias sc ON pd.id_subcategoria = sc.id_subcategoria
        INNER JOIN categorias c ON sc.id_categoria = c.id_categoria
        INNER JOIN presupuestos p ON pd.id_presupuesto = p.id_presupuesto
        WHERE c.id_categoria = f_id_categoria AND pd.id_presupuesto = f_id_presupuesto AND 
        ((p.anio_inicio * 100) + p.mes_inicio) <= ((f_anio * 100) + f_mes) AND
        ((p.anio_fin * 100) + p.mes_fin) >= ((f_anio * 100) + f_mes)
		GROUP BY c.id_categoria;
	
        
        RETURN IFNULL(monto_total_mes,0);
END $$
DELIMITER ;