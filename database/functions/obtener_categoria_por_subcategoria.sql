DROP FUNCTION IF EXISTS fn_obtener_categoria_por_subcategoria;

DELIMITER $$

CREATE FUNCTION fn_obtener_categoria_por_subcategoria(f_id_subcategoria INT)
RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
		DECLARE categoria_retornar INT;
       
		SELECT id_categoria INTO categoria_retornar FROM subcategorias WHERE id_subcategoria = f_id_subcategoria;
        
		RETURN categoria_retornar;
END $$
DELIMITER ;