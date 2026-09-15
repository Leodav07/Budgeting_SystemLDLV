import { http, request } from './http'

/**
 * Espejo de CategoriaController / CategoriaRepository.
 * `tipo` viene del ENUM de la tabla `categorias`: 'ingreso' | 'gasto' | 'ahorro'.
 * `eliminar` sí es un DELETE HTTP real (a diferencia de Usuario/Presupuesto/Obligacion,
 * que usan PATCH para baja lógica) — el repositorio la borra a través del SP.
 */
export const CATEGORIA_TIPOS = ['ingreso', 'gasto', 'ahorro']

export const categoriaService = {
  listar() {
    return request(http.get('/api/categorias'))
  },

  consultar(id) {
    return request(http.get(`/api/categorias/${id}`))
  },

  crear(payload) {
    // payload: { p_nombre, p_descripcion, p_tipo, p_icono_nombre, p_color_hex, p_orden, p_creado_por }
    return request(http.post('/api/categorias', payload))
  },

  actualizar(id, payload) {
    // payload: { p_nombre, p_descripcion, p_modificado_por }
    return request(http.put(`/api/categorias/${id}`, payload))
  },

  eliminar(id) {
    return request(http.delete(`/api/categorias/${id}`))
  },
}
