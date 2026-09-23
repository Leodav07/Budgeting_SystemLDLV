import { http, request } from './http'

/**
 * Espejo de ReporteController / ReporteRoutes.
 * Los 4 reportes se piden por POST con el filtro en el body (no son CRUD,
 * son consultas analíticas sobre procedimientos almacenados).
 */
export const reporteService = {
  ingresosGastos({ dni, p_anio_d, p_mes_d, p_anio_h, p_mes_h }) {
    return request(http.post('/api/reporteria/reporte1', { dni, p_anio_d, p_mes_d, p_anio_h, p_mes_h }))
  },

  distribucionGastos({ dni, p_anio, p_mes }) {
    return request(http.post('/api/reporteria/reporte2', { dni, p_anio, p_mes }))
  },

  analisisCumplimiento({ dni, p_anio, p_mes, p_tipo, p_id_presupuesto }) {
    return request(http.post('/api/reporteria/reporte3', { dni, p_anio, p_mes, p_tipo, p_id_presupuesto }))
  },

  estadoObligaciones({ dni, p_anio, p_mes }) {
    return request(http.post('/api/reporteria/reporte4', { dni, p_anio, p_mes }))
  },
}
