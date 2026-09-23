-- ============================================================================
-- Datos de prueba realistas — Sistema de Presupuesto Personal
-- ============================================================================
-- Genera 5 usuarios, categorías/subcategorías compartidas, un presupuesto por
-- usuario que cubre los DOS MESES anteriores al actual, 2 obligaciones fijas
-- por usuario y un volumen alto de transacciones distribuidas de forma
-- realista (salario a inicio de mes, compras entre semana/fin de semana,
-- pagos de obligaciones 0-2 días antes de su vencimiento, ahorro a fin de
-- mes, montos variables mes a mes).
--
-- IMPORTANTE — usuarios y contraseñas:
-- Este script NO crea los usuarios ni sus contraseñas. La contraseña se
-- guarda hasheada con el mismo algoritmo (PBKDF2) que usa el backend Java
-- (PasswordAuthentication.hash), y ese hash no se puede generar desde SQL
-- puro. Los 5 usuarios de prueba se crean por separado llamando al endpoint
-- real de la aplicación (POST /api/usuarios), así el hash queda correcto y
-- se puede iniciar sesión con ellos de verdad. Las credenciales están al
-- final de la respuesta donde se entregó este script.
--
-- Este script asume que esos 5 usuarios (con los DNI usados abajo) ya
-- existen en la tabla `usuarios` antes de ejecutarlo.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. LIMPIEZA — borra todo en orden seguro de llaves foráneas
-- ----------------------------------------------------------------------------
DELETE FROM obligaciones_transaccion;
DELETE FROM transacciones;
DELETE FROM presupuestos_detalles;
DELETE FROM obligaciones_fijas;
DELETE FROM presupuestos;
DELETE FROM subcategorias;
DELETE FROM categorias;

ALTER TABLE categorias AUTO_INCREMENT = 1;
ALTER TABLE subcategorias AUTO_INCREMENT = 1;
ALTER TABLE presupuestos AUTO_INCREMENT = 1;
ALTER TABLE presupuestos_detalles AUTO_INCREMENT = 1;
ALTER TABLE obligaciones_fijas AUTO_INCREMENT = 1;
ALTER TABLE transacciones AUTO_INCREMENT = 1;

-- ----------------------------------------------------------------------------
-- 2. CATEGORÍAS Y SUBCATEGORÍAS (compartidas por todos los usuarios)
-- ----------------------------------------------------------------------------
-- Cada CALL a sp_insertar_categoria dispara el trigger que crea la
-- subcategoría "General" automáticamente.

CALL sp_insertar_categoria('Salario Principal', 'Ingreso mensual por empleo formal', 'ingreso', 'wallet', '#059669', 1, 'seed_script');
CALL sp_insertar_categoria('Ingresos Adicionales', 'Freelance e ingresos extra', 'ingreso', 'plus-circle', '#10b981', 2, 'seed_script');
CALL sp_insertar_categoria('Alimentación', 'Supermercado y restaurantes', 'gasto', 'shopping-cart', '#dc2626', 1, 'seed_script');
CALL sp_insertar_categoria('Transporte', 'Combustible y transporte público', 'gasto', 'car', '#ea580c', 2, 'seed_script');
CALL sp_insertar_categoria('Vivienda', 'Alquiler y mantenimiento del hogar', 'gasto', 'home', '#b45309', 3, 'seed_script');
CALL sp_insertar_categoria('Servicios Públicos', 'Internet, energía y agua', 'gasto', 'zap', '#0284c7', 4, 'seed_script');
CALL sp_insertar_categoria('Entretenimiento', 'Streaming y salidas', 'gasto', 'film', '#7c3aed', 5, 'seed_script');
CALL sp_insertar_categoria('Salud', 'Farmacia y consultas médicas', 'gasto', 'heart', '#db2777', 6, 'seed_script');
CALL sp_insertar_categoria('Fondo de Emergencia', 'Ahorro programado mensual', 'ahorro', 'piggy-bank', '#4f46e5', 1, 'seed_script');

-- Subcategorías explícitas adicionales (además de "General" por cada categoría)
SET @cat_salario   = (SELECT id_categoria FROM categorias WHERE nombre = 'Salario Principal');
SET @cat_freelance = (SELECT id_categoria FROM categorias WHERE nombre = 'Ingresos Adicionales');
SET @cat_alimento  = (SELECT id_categoria FROM categorias WHERE nombre = 'Alimentación');
SET @cat_transporte = (SELECT id_categoria FROM categorias WHERE nombre = 'Transporte');
SET @cat_vivienda  = (SELECT id_categoria FROM categorias WHERE nombre = 'Vivienda');
SET @cat_servicios = (SELECT id_categoria FROM categorias WHERE nombre = 'Servicios Públicos');
SET @cat_entret    = (SELECT id_categoria FROM categorias WHERE nombre = 'Entretenimiento');
SET @cat_salud     = (SELECT id_categoria FROM categorias WHERE nombre = 'Salud');
SET @cat_ahorro    = (SELECT id_categoria FROM categorias WHERE nombre = 'Fondo de Emergencia');

CALL sp_insertar_subcategoria(@cat_salario, 'Salario Base', 'Sueldo mensual fijo', 'seed_script');
CALL sp_insertar_subcategoria(@cat_freelance, 'Freelance', 'Proyectos independientes', 'seed_script');
CALL sp_insertar_subcategoria(@cat_alimento, 'Supermercado', 'Compras de despensa', 'seed_script');
CALL sp_insertar_subcategoria(@cat_alimento, 'Restaurantes', 'Comidas fuera de casa', 'seed_script');
CALL sp_insertar_subcategoria(@cat_transporte, 'Combustible', 'Gasolina del vehículo', 'seed_script');
CALL sp_insertar_subcategoria(@cat_transporte, 'Transporte Público', 'Bus, taxi, apps de transporte', 'seed_script');
CALL sp_insertar_subcategoria(@cat_vivienda, 'Alquiler', 'Pago mensual de renta', 'seed_script');
CALL sp_insertar_subcategoria(@cat_servicios, 'Internet', 'Servicio de internet residencial', 'seed_script');
CALL sp_insertar_subcategoria(@cat_servicios, 'Energía Eléctrica', 'Factura de electricidad', 'seed_script');
CALL sp_insertar_subcategoria(@cat_entret, 'Streaming', 'Suscripciones de video/música', 'seed_script');
CALL sp_insertar_subcategoria(@cat_entret, 'Salidas', 'Cine, salidas con amigos', 'seed_script');
CALL sp_insertar_subcategoria(@cat_salud, 'Farmacia', 'Medicamentos y cuidado personal', 'seed_script');
CALL sp_insertar_subcategoria(@cat_ahorro, 'Ahorro Mensual', 'Aporte al fondo de emergencia', 'seed_script');

-- IDs de las subcategorías que vamos a usar para presupuestos/obligaciones/transacciones
SET @sc_salario      = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Salario Base');
SET @sc_freelance    = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Freelance');
SET @sc_super        = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Supermercado');
SET @sc_resto        = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Restaurantes');
SET @sc_combustible  = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Combustible');
SET @sc_transporte   = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Transporte Público');
SET @sc_alquiler     = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Alquiler');
SET @sc_internet     = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Internet');
SET @sc_electricidad = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Energía Eléctrica');
SET @sc_streaming    = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Streaming');
SET @sc_salidas      = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Salidas');
SET @sc_farmacia     = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Farmacia');
SET @sc_ahorro       = (SELECT id_subcategoria FROM subcategorias WHERE nombre = 'Ahorro Mensual');

-- ----------------------------------------------------------------------------
-- 3. RANGO DE FECHAS — los 2 meses completos anteriores al mes actual
-- ----------------------------------------------------------------------------
SET @mes1_inicio = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 2 MONTH), '%Y-%m-01');
SET @mes2_fin    = LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH));
SET @anio1 = YEAR(@mes1_inicio);
SET @mes1  = MONTH(@mes1_inicio);
SET @anio2 = YEAR(@mes2_fin);
SET @mes2  = MONTH(@mes2_fin);

-- ----------------------------------------------------------------------------
-- 4. PROCEDIMIENTO TEMPORAL: genera un mes completo de transacciones realistas
--    para un usuario (salario, ingreso extra opcional, pago de las 2
--    obligaciones cerca de su vencimiento, varias compras variables
--    distribuidas en el mes, y el aporte de ahorro).
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_seed_generar_mes_usuario;

DELIMITER $$
CREATE PROCEDURE sp_seed_generar_mes_usuario(
    IN p_dni VARCHAR(18), IN p_id_presupuesto INT, IN p_anio INT, IN p_mes INT,
    IN p_salario_base DECIMAL(8,2),
    IN p_id_obl_alquiler INT, IN p_vence_alquiler INT, IN p_monto_alquiler DECIMAL(8,2),
    IN p_id_obl_internet INT, IN p_vence_internet INT, IN p_monto_internet DECIMAL(8,2)
)
BEGIN
    DECLARE v_ultimo_dia INT;
    DECLARE v_dia INT;
    DECLARE v_i INT;
    DECLARE v_n INT;

    SET v_ultimo_dia = DAY(LAST_DAY(STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-01'), '%Y-%m-%d')));

    -- Salario, día 1 del mes (con leve variación por bonos/descuentos)
    CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_salario, 'ingreso',
        'Pago de nómina mensual', ROUND(p_salario_base + (RAND() * 600 - 300), 2),
        STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-01'), '%Y-%m-%d'), 'transferencia', NULL, NULL, 'seed_script', NULL);

    -- Ingreso adicional, ~50% de probabilidad por mes (variabilidad entre meses)
    IF RAND() < 0.5 THEN
        SET v_dia = 8 + FLOOR(RAND() * 15);
        CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_freelance, 'ingreso',
            'Proyecto freelance', ROUND(700 + RAND() * 1300, 2),
            STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', v_dia), '%Y-%m-%d'), 'transferencia', NULL, NULL, 'seed_script', NULL);
    END IF;

    -- Pago de alquiler, 0-2 días antes de su vencimiento, vinculado a la obligación
    SET v_dia = GREATEST(1, LEAST(v_ultimo_dia, p_vence_alquiler - FLOOR(RAND() * 3)));
    CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_alquiler, 'gasto',
        'Pago de alquiler mensual', p_monto_alquiler,
        STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', v_dia), '%Y-%m-%d'), 'transferencia', NULL, NULL, 'seed_script', p_id_obl_alquiler);

    -- Pago de internet, 0-2 días antes de su vencimiento, vinculado a la obligación
    SET v_dia = GREATEST(1, LEAST(v_ultimo_dia, p_vence_internet - FLOOR(RAND() * 3)));
    CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_internet, 'gasto',
        'Pago de servicio de internet', p_monto_internet,
        STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', v_dia), '%Y-%m-%d'), 'tarjeta_debito', NULL, NULL, 'seed_script', p_id_obl_internet);

    -- Energía eléctrica, un pago a mitad de mes (no vinculado a obligación)
    CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_electricidad, 'gasto',
        'Factura de energía eléctrica', ROUND(450 + RAND() * 250, 2),
        STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', LEAST(v_ultimo_dia, 14 + FLOOR(RAND() * 4))), '%Y-%m-%d'),
        'tarjeta_debito', NULL, NULL, 'seed_script', NULL);

    -- Supermercado: 3-5 compras, cualquier día del mes
    SET v_n = 3 + FLOOR(RAND() * 3);
    SET v_i = 0;
    WHILE v_i < v_n DO
        SET v_dia = 1 + FLOOR(RAND() * v_ultimo_dia);
        CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_super, 'gasto',
            'Compra de supermercado', ROUND(320 + RAND() * 480, 2),
            STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', v_dia), '%Y-%m-%d'), 'tarjeta_debito', NULL, NULL, 'seed_script', NULL);
        SET v_i = v_i + 1;
    END WHILE;

    -- Restaurantes: 2-4 salidas, con sesgo a fin de semana (día % 7 IN (5,6,0) aprox.)
    SET v_n = 2 + FLOOR(RAND() * 3);
    SET v_i = 0;
    WHILE v_i < v_n DO
        SET v_dia = LEAST(v_ultimo_dia, 3 + FLOOR(RAND() * 6) * 7 + FLOOR(RAND() * 3));
        CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_resto, 'gasto',
            'Comida fuera de casa', ROUND(180 + RAND() * 320, 2),
            STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', v_dia), '%Y-%m-%d'), 'tarjeta_credito', NULL, NULL, 'seed_script', NULL);
        SET v_i = v_i + 1;
    END WHILE;

    -- Combustible: 2-3 cargas
    SET v_n = 2 + FLOOR(RAND() * 2);
    SET v_i = 0;
    WHILE v_i < v_n DO
        SET v_dia = 1 + FLOOR(RAND() * v_ultimo_dia);
        CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_combustible, 'gasto',
            'Carga de combustible', ROUND(400 + RAND() * 250, 2),
            STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', v_dia), '%Y-%m-%d'), 'tarjeta_debito', NULL, NULL, 'seed_script', NULL);
        SET v_i = v_i + 1;
    END WHILE;

    -- Transporte público: 2-4 viajes sueltos
    SET v_n = 2 + FLOOR(RAND() * 3);
    SET v_i = 0;
    WHILE v_i < v_n DO
        SET v_dia = 1 + FLOOR(RAND() * v_ultimo_dia);
        CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_transporte, 'gasto',
            'Transporte urbano', ROUND(60 + RAND() * 140, 2),
            STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', v_dia), '%Y-%m-%d'), 'efectivo', NULL, NULL, 'seed_script', NULL);
        SET v_i = v_i + 1;
    END WHILE;

    -- Streaming: 1 cobro fijo a inicio de mes
    CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_streaming, 'gasto',
        'Suscripciones de streaming', ROUND(280 + RAND() * 120, 2),
        STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', LEAST(v_ultimo_dia, 3)), '%Y-%m-%d'), 'tarjeta_credito', NULL, NULL, 'seed_script', NULL);

    -- Salidas/entretenimiento: 1-3 veces, con sesgo a fin de semana
    SET v_n = 1 + FLOOR(RAND() * 3);
    SET v_i = 0;
    WHILE v_i < v_n DO
        SET v_dia = LEAST(v_ultimo_dia, 3 + FLOOR(RAND() * 6) * 7 + FLOOR(RAND() * 3));
        CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_salidas, 'gasto',
            'Cine y entretenimiento', ROUND(150 + RAND() * 350, 2),
            STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', v_dia), '%Y-%m-%d'), 'tarjeta_credito', NULL, NULL, 'seed_script', NULL);
        SET v_i = v_i + 1;
    END WHILE;

    -- Farmacia: 0-2 compras
    SET v_n = FLOOR(RAND() * 3);
    SET v_i = 0;
    WHILE v_i < v_n DO
        SET v_dia = 1 + FLOOR(RAND() * v_ultimo_dia);
        CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_farmacia, 'gasto',
            'Medicamentos y farmacia', ROUND(90 + RAND() * 260, 2),
            STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', v_dia), '%Y-%m-%d'), 'efectivo', NULL, NULL, 'seed_script', NULL);
        SET v_i = v_i + 1;
    END WHILE;

    -- Ahorro programado, últimos días del mes (monto variable, nunca exacto)
    CALL sp_registrar_transaccion_completa(p_dni, p_id_presupuesto, p_anio, p_mes, @sc_ahorro, 'ahorro',
        'Aporte al fondo de emergencia', ROUND(900 + RAND() * 700, 2),
        STR_TO_DATE(CONCAT(p_anio, '-', p_mes, '-', GREATEST(1, v_ultimo_dia - FLOOR(RAND() * 3))), '%Y-%m-%d'),
        'transferencia', NULL, NULL, 'seed_script', NULL);
END $$
DELIMITER ;

-- ----------------------------------------------------------------------------
-- 5. USUARIOS DE PRUEBA — presupuesto, obligaciones y transacciones de cada uno
-- ----------------------------------------------------------------------------
-- Los DNI deben coincidir exactamente con los usuarios ya creados vía la API
-- (ver credenciales al final de la respuesta).

-- ===== Usuario 1: Carlos Martínez =====
SET @dni1 = '11111111111111';
CALL sp_crear_presupuesto_completo(@dni1, 'Presupuesto mensual', 'Presupuesto de los últimos dos meses', @mes1_inicio, @mes2_fin,
    JSON_ARRAY(
        JSON_OBJECT('id_subcategoria', @sc_super, 'monto_mensual', 3800.00),
        JSON_OBJECT('id_subcategoria', @sc_resto, 'monto_mensual', 1500.00),
        JSON_OBJECT('id_subcategoria', @sc_combustible, 'monto_mensual', 1600.00),
        JSON_OBJECT('id_subcategoria', @sc_transporte, 'monto_mensual', 700.00),
        JSON_OBJECT('id_subcategoria', @sc_alquiler, 'monto_mensual', 7000.00),
        JSON_OBJECT('id_subcategoria', @sc_internet, 'monto_mensual', 750.00),
        JSON_OBJECT('id_subcategoria', @sc_electricidad, 'monto_mensual', 600.00),
        JSON_OBJECT('id_subcategoria', @sc_streaming, 'monto_mensual', 350.00),
        JSON_OBJECT('id_subcategoria', @sc_salidas, 'monto_mensual', 900.00),
        JSON_OBJECT('id_subcategoria', @sc_farmacia, 'monto_mensual', 400.00),
        JSON_OBJECT('id_subcategoria', @sc_ahorro, 'monto_mensual', 1200.00)
    ), 'seed_script');
SET @pres1 = (SELECT id_presupuesto FROM presupuestos WHERE usuario_dni = @dni1 ORDER BY id_presupuesto DESC LIMIT 1);

CALL sp_insertar_obligacion(@dni1, @sc_alquiler, 'Alquiler de apartamento', 'Renta mensual', 7000.00, 5, @mes1_inicio, NULL, 'seed_script');
SET @obl1_alquiler = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni1 AND id_subcategoria = @sc_alquiler ORDER BY id_obligacion DESC LIMIT 1);
CALL sp_insertar_obligacion(@dni1, @sc_internet, 'Internet residencial', 'Plan de internet fijo', 750.00, 15, @mes1_inicio, NULL, 'seed_script');
SET @obl1_internet = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni1 AND id_subcategoria = @sc_internet ORDER BY id_obligacion DESC LIMIT 1);

CALL sp_seed_generar_mes_usuario(@dni1, @pres1, @anio1, @mes1, 24000.00, @obl1_alquiler, 5, 7000.00, @obl1_internet, 15, 750.00);
CALL sp_seed_generar_mes_usuario(@dni1, @pres1, @anio2, @mes2, 24000.00, @obl1_alquiler, 5, 7000.00, @obl1_internet, 15, 750.00);

-- ===== Usuario 2: María Fernández =====
SET @dni2 = '22222222222222';
CALL sp_crear_presupuesto_completo(@dni2, 'Presupuesto mensual', 'Presupuesto de los últimos dos meses', @mes1_inicio, @mes2_fin,
    JSON_ARRAY(
        JSON_OBJECT('id_subcategoria', @sc_super, 'monto_mensual', 4500.00),
        JSON_OBJECT('id_subcategoria', @sc_resto, 'monto_mensual', 2000.00),
        JSON_OBJECT('id_subcategoria', @sc_combustible, 'monto_mensual', 1400.00),
        JSON_OBJECT('id_subcategoria', @sc_transporte, 'monto_mensual', 500.00),
        JSON_OBJECT('id_subcategoria', @sc_alquiler, 'monto_mensual', 8500.00),
        JSON_OBJECT('id_subcategoria', @sc_internet, 'monto_mensual', 900.00),
        JSON_OBJECT('id_subcategoria', @sc_electricidad, 'monto_mensual', 700.00),
        JSON_OBJECT('id_subcategoria', @sc_streaming, 'monto_mensual', 400.00),
        JSON_OBJECT('id_subcategoria', @sc_salidas, 'monto_mensual', 1300.00),
        JSON_OBJECT('id_subcategoria', @sc_farmacia, 'monto_mensual', 350.00),
        JSON_OBJECT('id_subcategoria', @sc_ahorro, 'monto_mensual', 2500.00)
    ), 'seed_script');
SET @pres2 = (SELECT id_presupuesto FROM presupuestos WHERE usuario_dni = @dni2 ORDER BY id_presupuesto DESC LIMIT 1);

CALL sp_insertar_obligacion(@dni2, @sc_alquiler, 'Alquiler de apartamento', 'Renta mensual', 8500.00, 3, @mes1_inicio, NULL, 'seed_script');
SET @obl2_alquiler = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni2 AND id_subcategoria = @sc_alquiler ORDER BY id_obligacion DESC LIMIT 1);
CALL sp_insertar_obligacion(@dni2, @sc_internet, 'Internet residencial', 'Plan de internet fijo', 900.00, 20, @mes1_inicio, NULL, 'seed_script');
SET @obl2_internet = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni2 AND id_subcategoria = @sc_internet ORDER BY id_obligacion DESC LIMIT 1);

CALL sp_seed_generar_mes_usuario(@dni2, @pres2, @anio1, @mes1, 32000.00, @obl2_alquiler, 3, 8500.00, @obl2_internet, 20, 900.00);
CALL sp_seed_generar_mes_usuario(@dni2, @pres2, @anio2, @mes2, 32000.00, @obl2_alquiler, 3, 8500.00, @obl2_internet, 20, 900.00);

-- ===== Usuario 3: Jorge Rodríguez =====
SET @dni3 = '33333333333333';
CALL sp_crear_presupuesto_completo(@dni3, 'Presupuesto mensual', 'Presupuesto de los últimos dos meses', @mes1_inicio, @mes2_fin,
    JSON_ARRAY(
        JSON_OBJECT('id_subcategoria', @sc_super, 'monto_mensual', 2800.00),
        JSON_OBJECT('id_subcategoria', @sc_resto, 'monto_mensual', 900.00),
        JSON_OBJECT('id_subcategoria', @sc_combustible, 'monto_mensual', 1000.00),
        JSON_OBJECT('id_subcategoria', @sc_transporte, 'monto_mensual', 900.00),
        JSON_OBJECT('id_subcategoria', @sc_alquiler, 'monto_mensual', 4500.00),
        JSON_OBJECT('id_subcategoria', @sc_internet, 'monto_mensual', 600.00),
        JSON_OBJECT('id_subcategoria', @sc_electricidad, 'monto_mensual', 450.00),
        JSON_OBJECT('id_subcategoria', @sc_streaming, 'monto_mensual', 250.00),
        JSON_OBJECT('id_subcategoria', @sc_salidas, 'monto_mensual', 500.00),
        JSON_OBJECT('id_subcategoria', @sc_farmacia, 'monto_mensual', 300.00),
        JSON_OBJECT('id_subcategoria', @sc_ahorro, 'monto_mensual', 700.00)
    ), 'seed_script');
SET @pres3 = (SELECT id_presupuesto FROM presupuestos WHERE usuario_dni = @dni3 ORDER BY id_presupuesto DESC LIMIT 1);

CALL sp_insertar_obligacion(@dni3, @sc_alquiler, 'Alquiler de habitación', 'Renta mensual', 4500.00, 1, @mes1_inicio, NULL, 'seed_script');
SET @obl3_alquiler = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni3 AND id_subcategoria = @sc_alquiler ORDER BY id_obligacion DESC LIMIT 1);
CALL sp_insertar_obligacion(@dni3, @sc_internet, 'Internet residencial', 'Plan de internet fijo', 600.00, 10, @mes1_inicio, NULL, 'seed_script');
SET @obl3_internet = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni3 AND id_subcategoria = @sc_internet ORDER BY id_obligacion DESC LIMIT 1);

CALL sp_seed_generar_mes_usuario(@dni3, @pres3, @anio1, @mes1, 18000.00, @obl3_alquiler, 1, 4500.00, @obl3_internet, 10, 600.00);
CALL sp_seed_generar_mes_usuario(@dni3, @pres3, @anio2, @mes2, 18000.00, @obl3_alquiler, 1, 4500.00, @obl3_internet, 10, 600.00);

-- ===== Usuario 4: Ana Gómez =====
SET @dni4 = '44444444444444';
CALL sp_crear_presupuesto_completo(@dni4, 'Presupuesto mensual', 'Presupuesto de los últimos dos meses', @mes1_inicio, @mes2_fin,
    JSON_ARRAY(
        JSON_OBJECT('id_subcategoria', @sc_super, 'monto_mensual', 5200.00),
        JSON_OBJECT('id_subcategoria', @sc_resto, 'monto_mensual', 2400.00),
        JSON_OBJECT('id_subcategoria', @sc_combustible, 'monto_mensual', 1800.00),
        JSON_OBJECT('id_subcategoria', @sc_transporte, 'monto_mensual', 400.00),
        JSON_OBJECT('id_subcategoria', @sc_alquiler, 'monto_mensual', 10000.00),
        JSON_OBJECT('id_subcategoria', @sc_internet, 'monto_mensual', 950.00),
        JSON_OBJECT('id_subcategoria', @sc_electricidad, 'monto_mensual', 800.00),
        JSON_OBJECT('id_subcategoria', @sc_streaming, 'monto_mensual', 450.00),
        JSON_OBJECT('id_subcategoria', @sc_salidas, 'monto_mensual', 1800.00),
        JSON_OBJECT('id_subcategoria', @sc_farmacia, 'monto_mensual', 450.00),
        JSON_OBJECT('id_subcategoria', @sc_ahorro, 'monto_mensual', 3500.00)
    ), 'seed_script');
SET @pres4 = (SELECT id_presupuesto FROM presupuestos WHERE usuario_dni = @dni4 ORDER BY id_presupuesto DESC LIMIT 1);

CALL sp_insertar_obligacion(@dni4, @sc_alquiler, 'Alquiler de casa', 'Renta mensual', 10000.00, 5, @mes1_inicio, NULL, 'seed_script');
SET @obl4_alquiler = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni4 AND id_subcategoria = @sc_alquiler ORDER BY id_obligacion DESC LIMIT 1);
CALL sp_insertar_obligacion(@dni4, @sc_internet, 'Internet residencial', 'Plan de internet fijo', 950.00, 18, @mes1_inicio, NULL, 'seed_script');
SET @obl4_internet = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni4 AND id_subcategoria = @sc_internet ORDER BY id_obligacion DESC LIMIT 1);

CALL sp_seed_generar_mes_usuario(@dni4, @pres4, @anio1, @mes1, 40000.00, @obl4_alquiler, 5, 10000.00, @obl4_internet, 18, 950.00);
CALL sp_seed_generar_mes_usuario(@dni4, @pres4, @anio2, @mes2, 40000.00, @obl4_alquiler, 5, 10000.00, @obl4_internet, 18, 950.00);

-- ===== Usuario 5: Luis Pérez =====
SET @dni5 = '55555555555555';
CALL sp_crear_presupuesto_completo(@dni5, 'Presupuesto mensual', 'Presupuesto de los últimos dos meses', @mes1_inicio, @mes2_fin,
    JSON_ARRAY(
        JSON_OBJECT('id_subcategoria', @sc_super, 'monto_mensual', 3200.00),
        JSON_OBJECT('id_subcategoria', @sc_resto, 'monto_mensual', 1100.00),
        JSON_OBJECT('id_subcategoria', @sc_combustible, 'monto_mensual', 1200.00),
        JSON_OBJECT('id_subcategoria', @sc_transporte, 'monto_mensual', 600.00),
        JSON_OBJECT('id_subcategoria', @sc_alquiler, 'monto_mensual', 5500.00),
        JSON_OBJECT('id_subcategoria', @sc_internet, 'monto_mensual', 650.00),
        JSON_OBJECT('id_subcategoria', @sc_electricidad, 'monto_mensual', 500.00),
        JSON_OBJECT('id_subcategoria', @sc_streaming, 'monto_mensual', 300.00),
        JSON_OBJECT('id_subcategoria', @sc_salidas, 'monto_mensual', 700.00),
        JSON_OBJECT('id_subcategoria', @sc_farmacia, 'monto_mensual', 350.00),
        JSON_OBJECT('id_subcategoria', @sc_ahorro, 'monto_mensual', 1000.00)
    ), 'seed_script');
SET @pres5 = (SELECT id_presupuesto FROM presupuestos WHERE usuario_dni = @dni5 ORDER BY id_presupuesto DESC LIMIT 1);

CALL sp_insertar_obligacion(@dni5, @sc_alquiler, 'Alquiler de apartamento', 'Renta mensual', 5500.00, 8, @mes1_inicio, NULL, 'seed_script');
SET @obl5_alquiler = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni5 AND id_subcategoria = @sc_alquiler ORDER BY id_obligacion DESC LIMIT 1);
CALL sp_insertar_obligacion(@dni5, @sc_internet, 'Internet residencial', 'Plan de internet fijo', 650.00, 22, @mes1_inicio, NULL, 'seed_script');
SET @obl5_internet = (SELECT id_obligacion FROM obligaciones_fijas WHERE usuario_dni = @dni5 AND id_subcategoria = @sc_internet ORDER BY id_obligacion DESC LIMIT 1);

CALL sp_seed_generar_mes_usuario(@dni5, @pres5, @anio1, @mes1, 22000.00, @obl5_alquiler, 8, 5500.00, @obl5_internet, 22, 650.00);
CALL sp_seed_generar_mes_usuario(@dni5, @pres5, @anio2, @mes2, 22000.00, @obl5_alquiler, 8, 5500.00, @obl5_internet, 22, 650.00);

-- ----------------------------------------------------------------------------
-- 6. LIMPIEZA DEL PROCEDIMIENTO TEMPORAL
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_seed_generar_mes_usuario;
