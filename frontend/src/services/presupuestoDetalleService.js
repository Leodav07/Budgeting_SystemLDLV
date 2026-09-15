import { http, request } from './http'

/**
 * Espejo de PresupuestoDetalleController / PresupuestoDetalleRepository.
 * El listado es por presupuesto (`GET /api/presupuestos/{id}/presupuestos_detalles`).
 * `eliminar` es PATCH (baja lógica), sin body.
 *
 * Nota: `ActualizarPresupuestoDetalle` pide en el body un `p_id_presupuesto_detalle`
 * además del id que ya va en la URL, pero el repositorio nunca lo lee (solo usa el
 * id de la URL). Lo mandamos igual para respetar el contrato del DTO tal cual está
 * definido hoy, aunque el backend lo ignore.
 */
export const presupuestoDetalleService = {
  listarPorPresupuesto(idPresupuesto) {
    return request(http.get(`/api/presupuestos/${idPresupuesto}/presupuestos_detalles`))
  },

  consultar(id) {
    return request(http.get(`/api/presupuestos_detalles/${id}`))
  },

  crear(payload) {
    // payload: { p_id_presupuesto, p_id_subcategoria, p_monto_asignado, p_justificacion_monto, p_creado_por }
    return request(http.post('/api/presupuestos_detalles', payload))
  },

  actualizar(id, payload) {
    // payload: { p_id_presupuesto_detalle, p_monto_asignado, p_justificacion_monto, p_modificado_por }
    return request(http.put(`/api/presupuestos_detalles/${id}`, payload))
  },

  eliminar(id) {
    return request(http.patch(`/api/presupuestos_detalles/${id}`))
  },
}
