DROP PROCEDURE IF EXISTS sp_auth;

DELIMITER $$

CREATE PROCEDURE sp_auth(IN dni VARCHAR(18),
							IN p_contrasenia VARCHAR(255),
                            OUT p_token VARCHAR(255))
BEGIN
	IF NOT EXISTS (SELECT 1 FROM usuarios u INNER JOIN table_login_usuario tb WHERE u.usuario_dni = dni AND tb.usuario_dni = dni) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "USUARIO_NO_EXISTE";
	END IF;
    
    SELECT contrasenia INTO p_token FROM table_login_usuario WHERE usuario_dni = dni;
    
END $$

DELIMITER ;
