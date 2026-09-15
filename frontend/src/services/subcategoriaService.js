import { http, request } from './http'

/**
 * Espejo de SubcategoriaController / SubcategoriaRepository.
 * No existe un GET "listar todas" — el único listado disponible es por
 * categoría (`GET /api/categorias/{id}/subcategorias`), así que esta pantalla
 * siempre necesita un id_categoria de contexto.
 * `eliminar` es DELETE HTTP real, igual que Categoria.
 */
export const subcategoriaService = {
  listarPorCategoria(idCategoria) {
    return request(http.get(`/api/categorias/${idCategoria}/subcategorias`))
  },

  consultar(id) {
    return request(http.get(`/api/subcategorias/${id}`))
  },

  crear(payload) {
    // payload: { p_id_categoria, p_nombre, p_descripcion, p_creado_por }
    return request(http.post('/api/subcategorias', payload))
  },

  actualizar(id, payload) {
    // payload: { p_nombre, p_descripcion, p_estado, p_modificado_por }
    return request(http.put(`/api/subcategorias/${id}`, payload))
  },

  eliminar(id) {
    return request(http.delete(`/api/subcategorias/${id}`))
  },
}
