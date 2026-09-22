
DROP TABLE table_login_usuario;

CREATE TABLE table_login_usuario (
    `usuario_dni` VARCHAR(18) NOT NULL,
	`contrasenia` VARCHAR(255) NOT NULL,
	`creado_por` VARCHAR(100) NOT NULL,
	`creado_en` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`modificado_por` VARCHAR(100),
	`modificado_en` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(`usuario_dni`)
);

ALTER TABLE `table_login_usuario`
ADD FOREIGN KEY(`usuario_dni`) REFERENCES `usuarios`(`usuario_dni`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
