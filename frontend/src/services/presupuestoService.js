import { http, request } from './http'

/**
 * Espejo de PresupuestoController / PresupuestoRepository.
 * `estado` viene del ENUM de la tabla `presupuestos`: 'activo' | 'cerrado' | 'borrador'.
 * `eliminar` es un PATCH (baja lógica), sin body (el controller no lee ctx.bodyAsClass).
 *
 * `listarPorUsuario` pega a `GET /api/usuarios/{id}/presupuestos?estado=...`.
 * `estado` es opcional: si no se manda, el SP `sp_listar_presupuestos_usuario`
 * ya maneja `p_estado IS NULL` como "sin filtro" (a diferencia del de
 * Obligaciones, este sí soporta "todas" sin problema).
 */
export const PRESUPUESTO_ESTADOS = ['activo', 'cerrado', 'borrador']

export const presupuestoService = {
  listarPorUsuario(usuarioDni, estado) {
    const query = estado ? `?estado=${encodeURIComponent(estado)}` : ''
    return request(http.get(`/api/usuarios/${usuarioDni}/presupuestos${query}`))
  },

  consultar(id) {
    return request(http.get(`/api/presupuestos/${id}`))
  },

  crear(payload) {
    // payload: { p_usuario_dni, p_nombre, p_descripcion, p_anio_inicio, p_mes_inicio,
    //            p_anio_final, p_mes_final, p_total_ingresos, p_total_gastos,
    //            p_total_ahorro, p_creado_por }
    return request(http.post('/api/presupuestos', payload))
  },

  actualizar(id, payload) {
    // payload: igual a crear + { p_estado, p_modificado_por } en vez de p_creado_por
    return request(http.put(`/api/presupuestos/${id}`, payload))
  },

  eliminar(id) {
    return request(http.patch(`/api/presupuestos/${id}`))
  },

  crearCompleto(payload) {
    // payload: { p_usuario_dni, p_nombre, p_descripcion, p_periodo_inicio, p_periodo_fin,
    //            p_lista_subcategorias_json: [{ id_subcategoria, monto_mensual }, ...],
    //            p_creado_por }
    // Espejo de sp_crear_presupuesto_completo: crea el presupuesto y todos sus detalles
    // por subcategoría en una sola transacción atómica.
    return request(http.post('/api/presupuestos/completo', payload))
  },
}
