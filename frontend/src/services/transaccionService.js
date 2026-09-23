import { http, request } from './http'

/**
 * Espejo de TransaccionController / TransaccionRepository.
 * El listado es por presupuesto (`GET /api/transacciones/{id}/presupuesto`), donde
 * `{id}` es en realidad el id_presupuesto (nombre de ruta un poco confuso, pero así
 * está registrada en TransaccionRoutes.java).
 * `eliminar` sí es un DELETE HTTP real, sin body.
 *
 * `tipo` viene del ENUM 'ingreso' | 'gasto' | 'ahorro'.
 * `metodo_pago` viene del ENUM 'efectivo' | 'tarjeta_debito' | 'tarjeta_credito' | 'transferencia'.
 */
export const TRANSACCION_TIPOS = ['ingreso', 'gasto', 'ahorro']
export const METODOS_PAGO = ['efectivo', 'tarjeta_debito', 'tarjeta_credito', 'transferencia']

export const transaccionService = {
  listarPorPresupuesto(idPresupuesto) {
    return request(http.get(`/api/transacciones/${idPresupuesto}/presupuesto`))
  },

  consultar(id) {
    return request(http.get(`/api/transacciones/${id}`))
  },

  crear(payload) {
    // payload: { p_usuario_dni, p_id_presupuesto, p_anio, p_mes, p_id_subcategoria, p_tipo,
    //            p_descripcion, p_monto, p_fecha_ocurrido, p_metodo_pago, p_num_factura,
    //            p_observaciones, p_creado_por }
    // p_fecha_ocurrido debe ir como "YYYY-MM-DDTHH:mm:ss" (LocalDateTime).
    return request(http.post('/api/transacciones', payload))
  },

  actualizar(id, payload) {
    // payload: { p_id_presupuesto, p_anio, p_mes, p_id_subcategoria, p_tipo, p_descripcion,
    //            p_monto, p_fecha_ocurrido, p_metodo_pago, p_num_factura, p_observaciones,
    //            p_creado_por }
    // OJO: ActualizarTransaccionRequest usa la llave "p_creado_por" también para el update
    // (no "p_modificado_por" como en las demás entidades) — probablemente un detalle a
    // revisar en el backend, pero el frontend debe respetar la llave tal cual existe hoy.
    return request(http.put(`/api/transacciones/${id}`, payload))
  },

  eliminar(id) {
    return request(http.delete(`/api/transacciones/${id}`))
  },

  registrarCompleta(payload) {
    // payload: { p_usuario_dni, p_id_presupuesto, p_anio, p_mes, p_id_subcategoria, p_tipo,
    //            p_descripcion, p_monto, p_fecha, p_metodo_pago, p_num_factura,
    //            p_observaciones, p_creado_por, p_id_obligacion }
    // Espejo de sp_registrar_transaccion_completa: valida vigencia del presupuesto,
    // que el tipo coincida con la categoría, y opcionalmente vincula la transacción
    // a una obligación fija (p_id_obligacion puede ir null).
    return request(http.post('/api/transacciones/completa', payload))
  },
}
