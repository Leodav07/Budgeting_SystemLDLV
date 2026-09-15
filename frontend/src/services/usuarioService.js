import { http, request } from './http'

/**
 * Espejo de UsuarioController / UsuarioRepository.
 * El identificador de negocio es el DNI (String), no un id numérico.
 * `eliminar` es un PATCH (baja lógica -> columna `estado`), no un DELETE real.
 */
export const usuarioService = {
  listar() {
    return request(http.get('/api/usuarios'))
  },

  consultar(dni) {
    return request(http.get(`/api/usuarios/${dni}`))
  },

  crear(payload) {
    // payload: { dni, p_nombre, s_nombre, p_apellido, s_apellido, correo_elec, psalario, pcreado_por }
    return request(http.post('/api/usuarios', payload))
  },

  actualizar(dni, payload) {
    // payload: { p_nombre, s_nombre, p_apellido, s_apellido, correo_elec, psalario, p_modificado_por }
    return request(http.put(`/api/usuarios/${dni}`, payload))
  },

  eliminar(dni, payload) {
    // payload: { p_modificado_por }
    return request(http.patch(`/api/usuarios/${dni}`, payload))
  },
}
