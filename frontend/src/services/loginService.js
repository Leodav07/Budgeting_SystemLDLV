import { http, request } from './http'

/**
 * Espejo de LoginController / LoginRoute (POST /api/login).
 * El backend responde 201 + { mensaje, dni } si las credenciales son válidas,
 * o 401 + { mensaje } si son inválidas (ver LoginController.authLogin).
 */
export const loginService = {
  autenticar(dni, p_contrasenia) {
    return request(http.post('/api/login', { dni, p_contrasenia }))
  },
}
