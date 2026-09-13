-- 1. sp crear usuario
SELECT * FROM usuarios;
DROP PROCEDURE IF EXISTS sp_insertar_usuario;

DELIMITER $$

CREATE PROCEDURE sp_insertar_usuario(IN dni VARCHAR(18),
									IN p_nombre VARCHAR(20),
									IN s_nombre VARCHAR(20),
									IN p_apellido VARCHAR(20),
									IN s_apellido VARCHAR(20),
                                    IN correo_elec VARCHAR(50),
                                    IN psalario DECIMAL(8,2),
									IN pcreado_por VARCHAR(100))
BEGIN
	IF EXISTS (SELECT 1 FROM usuarios WHERE usuario_dni = dni) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "USUARIO_YA_EXISTE";
	END IF;
    
	INSERT INTO usuarios (usuario_dni, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido,
						  email, salario, creado_por)
    VALUES (dni, p_nombre, s_nombre, p_apellido, s_apellido, correo_elec, psalario, pcreado_por);
END $$

DELIMITER ;

-- 2. actualizar usuario

DROP PROCEDURE IF EXISTS sp_actualizar_usuario;

DELIMITER $$

CREATE PROCEDURE sp_actualizar_usuario(IN dni VARCHAR(18),
									IN p_nombre VARCHAR(20),
									IN s_nombre VARCHAR(20),
									IN p_apellido VARCHAR(20),
									IN s_apellido VARCHAR(20),
                                    IN correo_elec VARCHAR(50),
                                    IN psalario DECIMAL(8,2),
									IN p_modificado_por VARCHAR(100))
BEGIN
	IF NOT EXISTS (
    SELECT 1
    FROM usuarios
    WHERE usuario_dni = dni
	) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'USUARIO_NO_EXISTE';
	END IF;

	UPDATE usuarios
    SET	primer_nombre = p_nombre, segundo_nombre = s_nombre, 
		primer_apellido = p_apellido, segundo_apellido = s_apellido, 
        email = correo_elec, salario = psalario, modificado_por = p_modificado_por
    WHERE usuario_dni = dni;
END $$

DELIMITER ;


-- 3. eliminar usuario

DROP PROCEDURE IF EXISTS sp_eliminar_usuario;

DELIMITER $$

CREATE PROCEDURE sp_eliminar_usuario(IN dni VARCHAR(18),
									IN p_modificado_por VARCHAR(100))
BEGIN 
	IF NOT EXISTS (
    SELECT 1
    FROM usuarios
    WHERE usuario_dni = dni
	) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'USUARIO_NO_EXISTE';
	END IF;
    
	UPDATE usuarios
	SET estado = false, modificado_por = p_modificado_por
	WHERE usuario_dni = dni;
END $$

DELIMITER ;

-- 4. consultar usuario especifico

DROP PROCEDURE IF EXISTS sp_consultar_usuario;

DELIMITER $$

CREATE PROCEDURE sp_consultar_usuario(IN dni VARCHAR(18))

    
BEGIN

	IF NOT EXISTS (
    SELECT 1
    FROM usuarios
    WHERE usuario_dni = dni
	) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'USUARIO_NO_EXISTE';
	END IF;
    
	SELECT usuario_dni, 
			primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, 
            email, fecha_registro, salario, estado
    FROM usuarios
    WHERE usuario_dni = dni;
END $$

DELIMITER ;


-- 5. Listar usuarios 

DROP PROCEDURE IF EXISTS sp_listar_usuarios;

DELIMITER $$

CREATE PROCEDURE sp_listar_usuarios()
BEGIN
    
	SELECT usuario_dni,
		primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, email, fecha_registro, salario,
        estado
	FROM usuarios;
END $$

DELIMITER ;

