-- Reporte 1

DROP PROCEDURE IF EXISTS sp_reporte1;

DELIMITER $$

CREATE PROCEDURE sp_reporte1(IN dni VARCHAR(18),
							IN p_anio_d MEDIUMINT,
                            IN p_mes_d TINYINT,
                            IN p_anio_h MEDIUMINT,
                            IN p_mes_h TINYINT)
BEGIN

	IF EXISTS (SELECT 1 FROM usuarios WHERE usuario_dni = dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "USUARIO_YA_EXISTE";
    END IF;
    
	WITH t1 AS(
    SELECT
		SUM(CASE WHEN tipo = 'ingreso' THEN monto ELSE 0 END) AS ingresos,
		SUM(CASE WHEN tipo = 'gasto' THEN monto ELSE 0 END) AS gastos,
        anio, mes
        FROM transacciones WHERE usuario_dni = dni AND
        (anio*100) + mes >= (p_anio_d*100) + p_mes_d AND (anio*100) + mes <= (p_anio_h*100) + p_mes_h
        GROUP BY anio, mes
        )
	SELECT t1.*, (t1.ingresos - t1.gastos) AS balance FROM t1
    ORDER BY t1.anio, t1.mes;

END $$

DELIMITER ;


-- Reporte 2

DROP PROCEDURE IF EXISTS sp_reporte2;

DELIMITER $$

CREATE PROCEDURE sp_reporte2(IN dni VARCHAR(18),
							IN p_anio MEDIUMINT,
                            IN p_mes TINYINT
                            )
BEGIN


	IF EXISTS (SELECT 1 FROM usuarios WHERE usuario_dni = dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "USUARIO_YA_EXISTE";
    END IF;
    
	WITH t1 AS (
    SELECT c.nombre AS nombre_categoria, SUM(COALESCE(t.monto, 0)) AS monto_total,
    COUNT(*) AS conteo_transacciones 
    FROM transacciones t
    INNER JOIN subcategorias sc ON sc.id_subcategoria = t.id_subcategoria
    INNER JOIN categorias c ON c.id_categoria = sc.id_categoria
    WHERE c.tipo = 'gasto' AND t.usuario_dni = dni AND t.anio = p_anio AND t.mes = p_mes
    GROUP BY c.id_categoria
		),
	t2 AS (
		SELECT t1.*, SUM(t1.monto_total) OVER () AS gran_total
        FROM t1
    )
    
    SELECT t2.*, IFNULL((t2.monto_total/t2.gran_total)*100, 0) AS porcentaje FROM t2;
    
END $$

DELIMITER ;

-- Reporte 3

DROP PROCEDURE IF EXISTS sp_reporte3;

DELIMITER $$

CREATE PROCEDURE sp_reporte3(IN dni VARCHAR(18),
							IN p_anio MEDIUMINT,
                            IN p_mes TINYINT,
                            IN p_tipo VARCHAR(20),
                            IN p_id_presupuesto INT
                            )
BEGIN

	IF EXISTS (SELECT 1 FROM usuarios WHERE usuario_dni = dni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "USUARIO_YA_EXISTE";
    END IF;
	
    WITH t1 AS (
		SELECT pd.id_presupuesto, pd.id_subcategoria, sc.nombre AS nombre_subcategoria, ANY_VALUE(pd.monto_asignado) AS monto_presupuestado,
        c.id_categoria, c.nombre as nombre_categoria, SUM(COALESCE(t.monto,0)) AS monto_gastado
        FROM presupuestos_detalles pd 
        INNER JOIN subcategorias sc ON pd.id_subcategoria = sc.id_subcategoria
        INNER JOIN categorias c ON sc.id_categoria = c.id_categoria
        LEFT JOIN transacciones t ON sc.id_subcategoria = t.id_subcategoria AND t.anio = p_anio AND t.mes = p_mes
        INNER JOIN presupuestos p ON pd.id_presupuesto = p.id_presupuesto
        WHERE p.usuario_dni = dni AND c.tipo = p_tipo AND pd.id_presupuesto = p_id_presupuesto
        GROUP BY sc.id_subcategoria, pd.id_presupuesto, c.id_categoria, c.nombre
    )
    
	SELECT t1.*, SUM(t1.monto_presupuestado) OVER (PARTITION BY t1.id_categoria) AS total_categoria FROM t1;
  
    
    
    
END $$

DELIMITER ;