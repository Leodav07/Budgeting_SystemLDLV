CREATE TABLE IF NOT EXISTS `usuarios` (
	`usuario_dni` VARCHAR(18) NOT NULL,
	`primer_nombre` VARCHAR(20) NOT NULL,
	`segundo_nombre` VARCHAR(20),
	`primer_apellido` VARCHAR(20) NOT NULL,
	`segundo_apellido` VARCHAR(20),
	`email` VARCHAR(50) NOT NULL UNIQUE,
	`fecha_registro` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`salario` DECIMAL(8,2) NOT NULL,
	`estado` BOOLEAN DEFAULT true,
	`creado_por` VARCHAR(100) NOT NULL,
	`creado_en` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`modificado_por` VARCHAR(100),
	`modificado_en` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(`usuario_dni`)
);

CREATE TABLE IF NOT EXISTS `presupuestos` (
	`id_presupuesto` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`usuario_dni` VARCHAR(18) NOT NULL,
	`nombre` VARCHAR(40) NOT NULL,
	`descripcion` VARCHAR(200),
	`anio_inicio` MEDIUMINT NOT NULL,
	`mes_inicio` TINYINT NOT NULL,
	`anio_fin` MEDIUMINT NOT NULL,
	`mes_fin` TINYINT NOT NULL,
	`total_ingresos` DECIMAL(8,2) NOT NULL DEFAULT 0,
	`total_gastos` DECIMAL(8,2) NOT NULL DEFAULT 0,
	`total_ahorro` DECIMAL(8,2) NOT NULL DEFAULT 0,
	`fecha_creacion` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`estado` ENUM('activo','cerrado','borrador') NOT NULL DEFAULT 'borrador',
	`creado_por` VARCHAR(100) NOT NULL,
	`creado_en` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`modificado_por` VARCHAR(100),
	`modificado_en` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(`id_presupuesto`)
);

CREATE TABLE IF NOT EXISTS `categorias` (
	`id_categoria` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`nombre` VARCHAR(50) NOT NULL,
	`descripcion` VARCHAR(250),
	`tipo` ENUM('ingreso','gasto','ahorro') NOT NULL,
	`icono_nombre` VARCHAR(250),
	`color_hex` VARCHAR(50),
	`orden` INTEGER,
	`creado_por` VARCHAR(100) NOT NULL,
	`creado_en` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`modificado_por` VARCHAR(100),
	`modificado_en` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(`id_categoria`)
);

CREATE TABLE IF NOT EXISTS `subcategorias` (
	`id_subcategoria` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`id_categoria` INTEGER UNSIGNED NOT NULL,
	`nombre` VARCHAR(50) NOT NULL,
	`descripcion` VARCHAR(255),
	`estado` BOOLEAN DEFAULT true,
	`por_defecto` BOOLEAN DEFAULT false,
	`creado_por` VARCHAR(100) NOT NULL,
	`creado_en` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`modificado_por` VARCHAR(100),
	`modificado_en` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(`id_subcategoria`)
);

CREATE TABLE IF NOT EXISTS `presupuestos_detalles` (
	`id_pdetalle` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`id_presupuesto` INTEGER UNSIGNED NOT NULL,
	`id_subcategoria` INTEGER UNSIGNED NOT NULL,
	`monto_asignado` DECIMAL(8,2) NOT NULL,
	`justificacion_monto` VARCHAR(255),
	`creado_por` VARCHAR(100) NOT NULL,
	`creado_en` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`modificado_por` VARCHAR(100),
	`modificado_en` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(`id_pdetalle`)
);

CREATE TABLE IF NOT EXISTS `obligaciones_fijas` (
	`id_obligacion` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`usuario_dni` VARCHAR(18) NOT NULL,
	`id_subcategoria` INTEGER UNSIGNED NOT NULL,
	`nombre` VARCHAR(50) NOT NULL,
	`descripcion` VARCHAR(255),
	`monto_fijo` DECIMAL(8,2) NOT NULL,
	`vence_dia` TINYINT NOT NULL,
	`vigente` BOOLEAN DEFAULT true,
	`fecha_inicio` DATE NOT NULL,
	`fecha_final` DATE,
	`creado_por` VARCHAR(100) NOT NULL,
	`creado_en` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`modificado_por` VARCHAR(100),
	`modificado_en` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(`id_obligacion`)
);

CREATE TABLE IF NOT EXISTS `transacciones` (
	`id_transaccion` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
	`usuario_dni` VARCHAR(18) NOT NULL,
	`id_presupuesto` INTEGER UNSIGNED NOT NULL,
	`anio` MEDIUMINT NOT NULL,
	`mes` TINYINT NOT NULL,
	`id_subcategoria` INTEGER UNSIGNED NOT NULL,
	`tipo` ENUM('ingreso','gasto','ahorro') NOT NULL,
	`descripcion` VARCHAR(255),
	`monto` DECIMAL(8,2) NOT NULL,
	`fecha_ocurrido` DATETIME NOT NULL,
	`metodo_pago` ENUM('efectivo','tarjeta_debito','tarjeta_credito','transferencia') NOT NULL,
	`num_factura` VARCHAR(20),
	`observaciones` VARCHAR(255),
	`fecha_registro` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`creado_por` VARCHAR(100) NOT NULL,
	`creado_en` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`modificado_por` VARCHAR(100),
	`modificado_en` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(`id_transaccion`)
);

CREATE TABLE IF NOT EXISTS `obligaciones_transaccion` (
	`id_transaccion` INTEGER UNSIGNED NOT NULL,
	`id_obligacion` INTEGER UNSIGNED NOT NULL,
	`creado_por` VARCHAR(100) NOT NULL,
	`creado_en` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`modificado_por` VARCHAR(100),
	`modificado_en` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE `obligaciones_transaccion`
ADD PRIMARY KEY (`id_transaccion`, `id_obligacion`);

ALTER TABLE `presupuestos`
ADD FOREIGN KEY(`usuario_dni`) REFERENCES `usuarios`(`usuario_dni`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `obligaciones_fijas`
ADD FOREIGN KEY(`usuario_dni`) REFERENCES `usuarios`(`usuario_dni`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `transacciones`
ADD FOREIGN KEY(`usuario_dni`) REFERENCES `usuarios`(`usuario_dni`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `subcategorias`
ADD FOREIGN KEY(`id_categoria`) REFERENCES `categorias`(`id_categoria`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `presupuestos_detalles`
ADD FOREIGN KEY(`id_subcategoria`) REFERENCES `subcategorias`(`id_subcategoria`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `obligaciones_fijas`
ADD FOREIGN KEY(`id_subcategoria`) REFERENCES `subcategorias`(`id_subcategoria`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `transacciones`
ADD FOREIGN KEY(`id_subcategoria`) REFERENCES `subcategorias`(`id_subcategoria`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `presupuestos_detalles`
ADD FOREIGN KEY(`id_presupuesto`) REFERENCES `presupuestos`(`id_presupuesto`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `transacciones`
ADD FOREIGN KEY(`id_presupuesto`) REFERENCES `presupuestos`(`id_presupuesto`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `obligaciones_transaccion`
ADD FOREIGN KEY(`id_transaccion`) REFERENCES `transacciones`(`id_transaccion`)
ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE `obligaciones_transaccion`
ADD FOREIGN KEY(`id_obligacion`) REFERENCES `obligaciones_fijas`(`id_obligacion`)
ON UPDATE NO ACTION ON DELETE NO ACTION;