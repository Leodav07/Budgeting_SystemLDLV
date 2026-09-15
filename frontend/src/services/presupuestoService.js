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
 *
 * ⚠️ Al momento de escribir esto, `PresupuestoController.listarPresupuestos`
 * todavía lee `ctx.pathParam("estado")` en vez de `ctx.queryParam("estado")` —
 * esa línea sigue rota (la ruta solo declara `{id}}`, no `{estado}`) y esta
 * llamada va a fallar hasta que se corrija. El resto del contrato (ruta, DTO)
 * ya está bien.
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
}
