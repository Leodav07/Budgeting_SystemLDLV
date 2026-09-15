import { http, request } from './http'

/**
 * Espejo de ObligacionController / ObligacionRepository.
 * El listado es por usuario (`GET /api/usuarios/{id}/obligaciones`), donde `{id}`
 * es en realidad el DNI del usuario.
 *
 * El filtro `vigente` ya viaja como query param (`?vigente=true|false`), no como
 * body de un GET.
 *
 * ⚠️ Siempre hay que mandar un valor concreto (true/false), nunca omitir el
 * parámetro: `ObligacionRepository.Listar` hace `statement.setBoolean(2, vigente)`,
 * y si `vigente` llega null ahí revienta con NullPointerException (setBoolean
 * no admite null — necesitaría `setObject(2, vigente, Types.BOOLEAN)` para
 * soportar "sin filtro"). Hasta que eso se ajuste en el backend, esta pantalla
 * no ofrece una opción "todas", solo vigentes / no vigentes.
 *
 * `eliminar` es un PATCH (baja lógica), con body { p_modificado_por }.
 */
export const obligacionService = {
  listarPorUsuario(usuarioDni, vigente) {
    return request(http.get(`/api/usuarios/${usuarioDni}/obligaciones?vigente=${vigente}`))
  },

  consultar(id) {
    return request(http.get(`/api/obligaciones/${id}`))
  },

  crear(payload) {
    // payload: { p_usuario_dni, p_id_subcategoria, p_nombre, p_descripcion, p_monto_fijo,
    //            p_vence_dia, p_fecha_inicio, p_fecha_final, p_creado_por }
    // p_fecha_inicio / p_fecha_final deben ir como "YYYY-MM-DD" (java.sql.Date).
    return request(http.post('/api/obligaciones', payload))
  },

  actualizar(id, payload) {
    // payload: { p_usuario_dni, p_id_subcategoria, p_nombre, p_descripcion, p_monto_fijo,
    //            p_vence_dia, p_fecha_inicio, p_fecha_final, p_modificado_por }
    return request(http.put(`/api/obligaciones/${id}`, payload))
  },

  eliminar(id, payload) {
    // payload: { p_modificado_por }
    return request(http.patch(`/api/obligaciones/${id}`, payload))
  },
}
