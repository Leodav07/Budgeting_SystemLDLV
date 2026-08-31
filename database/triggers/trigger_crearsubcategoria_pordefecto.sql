-- 1. Trigger crear subcategoria por defecto

DROP TRIGGER IF EXISTS pordefecto_subcategoria_trigger;

DELIMITER $$
CREATE TRIGGER pordefecto_subcategoria_trigger
AFTER INSERT ON categorias
FOR EACH ROW
BEGIN
	INSERT INTO subcategorias (id_categoria, nombre, descripcion, por_defecto, creado_por)
	VALUES (NEW.id_categoria, 'General', 'Sin descripcion', true, 'trigger');
END $$
DELIMITER ;