-- ============================================================================
-- Seed de datos de prueba para Sistema de Presupuesto Personal
-- ============================================================================
-- Se apoya EXCLUSIVAMENTE en los stored procedures ya existentes (CALL sp_...),
-- nunca en INSERT directos, para que pase por las mismas validaciones (SIGNAL)
-- y triggers que usa la API real. Es seguro ejecutarlo una sola vez: si lo
-- vuelves a correr vas a chocar con validaciones de duplicado (USUARIO_YA_EXISTE,
-- SUBCATEGORIA_YA_ASOCIADA, etc.) — eso es intencional, no un bug del script.
--
-- Complementa los datos que ya tenías (usuario 0801199912345 "Leo Reyes" y sus
-- presupuestos "Presupuesto Ene-Mar" / "Presupuesto Abr-Jun" de 2025), no los
-- reemplaza.
--
-- Cómo correrlo:
--   mysql -u root -p budget_system < database/test_data/seed_demo.sql
--   (o ábrelo y ejecútalo en MySQL Workbench / MySQL Shell contra budget_system)
-- ============================================================================

-- ---------- 1. Usuario adicional ----------
CALL sp_insertar_usuario('502340811', 'Ana', 'Maria', 'Vargas', 'Jimenez',
                          'ana.vargas.demo@example.com', 950000.00, 'seed');

-- ---------- 2. Categorías nuevas (cada una dispara el trigger que crea su
--               subcategoría "General" automáticamente) ----------
CALL sp_insertar_categoria('Alimentacion', 'Gastos de comida y supermercado', 'gasto',
                            'utensils', '#f97316', 1, 'seed');
CALL sp_insertar_categoria('Transporte', 'Movilidad, combustible y mantenimiento', 'gasto',
                            'car', '#0ea5e9', 2, 'seed');
CALL sp_insertar_categoria('Servicios y Suscripciones', 'Internet, telefono, streaming', 'gasto',
                            'wifi', '#a855f7', 3, 'seed');
CALL sp_insertar_categoria('Ahorro Programado', 'Fondo de ahorro mensual', 'ahorro',
                            'piggy-bank', '#6366f1', 1, 'seed');

-- Recuperamos los ids recien creados por nombre (NO usar LAST_INSERT_ID() aqui:
-- el trigger de "subcategoria General" hace su propio INSERT justo despues y
-- pisa el LAST_INSERT_ID() de la categoria).
SELECT id_categoria INTO @cat_alimentacion FROM categorias WHERE nombre = 'Alimentacion' LIMIT 1;
SELECT id_categoria INTO @cat_transporte FROM categorias WHERE nombre = 'Transporte' LIMIT 1;
SELECT id_categoria INTO @cat_servicios FROM categorias WHERE nombre = 'Servicios y Suscripciones' LIMIT 1;
SELECT id_categoria INTO @cat_ahorro FROM categorias WHERE nombre = 'Ahorro Programado' LIMIT 1;
SELECT id_categoria INTO @cat_salario FROM categorias WHERE nombre = 'Salario Principal' LIMIT 1;

-- ---------- 3. Subcategorías explícitas (además de las "General" del trigger) ----------
CALL sp_insertar_subcategoria(@cat_alimentacion, 'Supermercado', 'Compras de mercado', 'seed');
CALL sp_insertar_subcategoria(@cat_alimentacion, 'Restaurantes', 'Comidas fuera de casa', 'seed');
CALL sp_insertar_subcategoria(@cat_transporte, 'Combustible', 'Gasolina', 'seed');
CALL sp_insertar_subcategoria(@cat_transporte, 'Cuota y mantenimiento', 'Cuota del vehiculo y mantenimiento', 'seed');
CALL sp_insertar_subcategoria(@cat_servicios, 'Internet y telefono', 'Plan de internet y telefonia', 'seed');
CALL sp_insertar_subcategoria(@cat_servicios, 'Streaming', 'Suscripciones de streaming', 'seed');
CALL sp_insertar_subcategoria(@cat_ahorro, 'Fondo de emergencia', 'Ahorro para emergencias', 'seed');

SELECT id_subcategoria INTO @sub_supermercado FROM subcategorias WHERE id_categoria = @cat_alimentacion AND nombre = 'Supermercado' LIMIT 1;
SELECT id_subcategoria INTO @sub_restaurantes FROM subcategorias WHERE id_categoria = @cat_alimentacion AND nombre = 'Restaurantes' LIMIT 1;
SELECT id_subcategoria INTO @sub_combustible FROM subcategorias WHERE id_categoria = @cat_transporte AND nombre = 'Combustible' LIMIT 1;
SELECT id_subcategoria INTO @sub_cuota_vehiculo FROM subcategorias WHERE id_categoria = @cat_transporte AND nombre = 'Cuota y mantenimiento' LIMIT 1;
SELECT id_subcategoria INTO @sub_internet FROM subcategorias WHERE id_categoria = @cat_servicios AND nombre = 'Internet y telefono' LIMIT 1;
SELECT id_subcategoria INTO @sub_streaming FROM subcategorias WHERE id_categoria = @cat_servicios AND nombre = 'Streaming' LIMIT 1;
SELECT id_subcategoria INTO @sub_fondo_emergencia FROM subcategorias WHERE id_categoria = @cat_ahorro AND nombre = 'Fondo de emergencia' LIMIT 1;
SELECT id_subcategoria INTO @sub_salario_general FROM subcategorias WHERE id_categoria = @cat_salario AND por_defecto = 1 LIMIT 1;

-- ---------- 4. Presupuesto nuevo para Ana (año actual completo) ----------
-- OJO: total_ingresos/gastos/ahorro son DECIMAL(8,2), tope real ~999999.99 (6
-- dígitos enteros), no da para un ingreso anual (12 * 950000 se pasa). Usamos
-- el monto de un mes como estimado de referencia.
CALL sp_insertar_presupuesto('502340811', 'Presupuesto Anual 2026', 'Presupuesto del año en curso',
                              2026, 1, 2026, 12, 950000.00, 0.00, 0.00, 'seed');

SELECT id_presupuesto INTO @pres_ana_2026 FROM presupuestos WHERE usuario_dni = '502340811' AND nombre = 'Presupuesto Anual 2026' LIMIT 1;

-- Presupuestos que ya tenías creados manualmente para Leo:
SELECT id_presupuesto INTO @pres_leo_q1 FROM presupuestos WHERE usuario_dni = '0801199912345' AND nombre = 'Presupuesto Ene-Mar' LIMIT 1;
SELECT id_presupuesto INTO @pres_leo_q2 FROM presupuestos WHERE usuario_dni = '0801199912345' AND nombre = 'Presupuesto Abr-Jun' LIMIT 1;

-- ---------- 5. Detalles de presupuesto (montos asignados por subcategoría) ----------
CALL sp_insertar_presupuesto_detalle(@pres_leo_q1, @sub_salario_general, 850000.00, 'Ingreso mensual esperado', 'seed');
CALL sp_insertar_presupuesto_detalle(@pres_leo_q1, @sub_supermercado, 100000.00, 'Presupuesto de mercado', 'seed');
CALL sp_insertar_presupuesto_detalle(@pres_leo_q1, @sub_combustible, 50000.00, 'Presupuesto de gasolina', 'seed');

CALL sp_insertar_presupuesto_detalle(@pres_ana_2026, @sub_salario_general, 950000.00, 'Ingreso mensual esperado', 'seed');
CALL sp_insertar_presupuesto_detalle(@pres_ana_2026, @sub_supermercado, 90000.00, 'Presupuesto de mercado', 'seed');
CALL sp_insertar_presupuesto_detalle(@pres_ana_2026, @sub_fondo_emergencia, 100000.00, 'Aporte mensual a ahorro', 'seed');

-- ---------- 6. Obligaciones fijas (requieren subcategoría de tipo 'gasto') ----------
CALL sp_insertar_obligacion('0801199912345', @sub_internet, 'Internet residencial', 'Plan de internet del hogar',
                             32000.00, 15, '2025-01-15', NULL, 'seed');
CALL sp_insertar_obligacion('0801199912345', @sub_cuota_vehiculo, 'Cuota del vehiculo', 'Cuota mensual del carro',
                             185000.00, 5, '2025-01-05', NULL, 'seed');
CALL sp_insertar_obligacion('502340811', @sub_streaming, 'Suscripcion streaming', 'Plan familiar de streaming',
                             9000.00, 20, '2026-01-20', NULL, 'seed');

-- ---------- 7. Transacciones ----------
-- Presupuesto de Leo Ene-Mar 2025
CALL sp_insertar_transaccion('0801199912345', @pres_leo_q1, 2025, 1, @sub_salario_general, 'ingreso',
                              'Salario enero', 850000.00, '2025-01-05 10:00:00', 'transferencia', NULL, NULL, 'seed');
CALL sp_insertar_transaccion('0801199912345', @pres_leo_q1, 2025, 1, @sub_supermercado, 'gasto',
                              'Compras del mes', 95000.00, '2025-01-10 14:30:00', 'tarjeta_debito', 'F-0001', NULL, 'seed');
CALL sp_insertar_transaccion('0801199912345', @pres_leo_q1, 2025, 2, @sub_salario_general, 'ingreso',
                              'Salario febrero', 850000.00, '2025-02-05 09:00:00', 'transferencia', NULL, NULL, 'seed');
CALL sp_insertar_transaccion('0801199912345', @pres_leo_q1, 2025, 2, @sub_combustible, 'gasto',
                              'Gasolina', 45000.00, '2025-02-12 18:00:00', 'tarjeta_credito', 'F-0002', NULL, 'seed');
CALL sp_insertar_transaccion('0801199912345', @pres_leo_q1, 2025, 3, @sub_fondo_emergencia, 'ahorro',
                              'Aporte fondo de emergencia', 100000.00, '2025-03-01 08:00:00', 'transferencia', NULL, NULL, 'seed');

-- Presupuesto de Leo Abr-Jun 2025
CALL sp_insertar_transaccion('0801199912345', @pres_leo_q2, 2025, 4, @sub_salario_general, 'ingreso',
                              'Salario abril', 850000.00, '2025-04-05 09:00:00', 'transferencia', NULL, NULL, 'seed');
CALL sp_insertar_transaccion('0801199912345', @pres_leo_q2, 2025, 5, @sub_restaurantes, 'gasto',
                              'Almuerzo familiar', 28000.00, '2025-05-15 12:00:00', 'efectivo', NULL, NULL, 'seed');

-- Presupuesto de Ana 2026
CALL sp_insertar_transaccion('502340811', @pres_ana_2026, 2026, 9, @sub_salario_general, 'ingreso',
                              'Salario septiembre', 950000.00, '2026-09-01 09:00:00', 'transferencia', NULL, NULL, 'seed');
CALL sp_insertar_transaccion('502340811', @pres_ana_2026, 2026, 9, @sub_supermercado, 'gasto',
                              'Mercado semanal', 62000.00, '2026-09-05 13:00:00', 'tarjeta_debito', 'F-1001', NULL, 'seed');
CALL sp_insertar_transaccion('502340811', @pres_ana_2026, 2026, 9, @sub_fondo_emergencia, 'ahorro',
                              'Aporte mensual ahorro', 80000.00, '2026-09-12 08:00:00', 'transferencia', NULL, NULL, 'seed');

-- ---------- 8. Verificación rápida ----------
SELECT 'usuarios' AS tabla, COUNT(*) AS filas FROM usuarios
UNION ALL SELECT 'categorias', COUNT(*) FROM categorias
UNION ALL SELECT 'subcategorias', COUNT(*) FROM subcategorias
UNION ALL SELECT 'presupuestos', COUNT(*) FROM presupuestos
UNION ALL SELECT 'presupuestos_detalles', COUNT(*) FROM presupuestos_detalles
UNION ALL SELECT 'obligaciones_fijas', COUNT(*) FROM obligaciones_fijas
UNION ALL SELECT 'transacciones', COUNT(*) FROM transacciones;
