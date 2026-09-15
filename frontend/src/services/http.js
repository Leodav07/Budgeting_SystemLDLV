import axios from 'axios'

// El backend Javalin (Main.java) no habilita CORS, así que pegarle directo a
// "http://localhost:7070" desde el navegador fallaría en modo `npm run dev`.
// Por eso dejamos baseURL vacío: las peticiones van a rutas relativas
// ("/api/usuarios", etc.) contra el propio origen de Vite, y el proxy que ya
// está declarado en vite.config.js ("/api" -> http://localhost:7070) reenvía
// todo al backend sin que el navegador vea un origen distinto.
// Si algún día sirves el build de producción sin ese proxy (por ejemplo,
// `vite preview` o un hosting estático), vas a necesitar o habilitar CORS en
// Javalin o poner un proxy real delante — ahí sí tocaría el backend.
export const API_BASE_URL = ''

export const http = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

/**
 * El backend responde los errores de negocio a través de `ApiExceptionController`
 * con el formato `{ codigo, mensaje }` (ver Main.java -> app.exception(...)).
 * Sin embargo, algunos controllers todavía arman su propio 404 a mano con
 * `Map.of("mensaje", "...")`, sin `codigo`. ApiError normaliza ambos casos
 * para que el resto del frontend nunca tenga que preocuparse por la diferencia.
 */
export class ApiError extends Error {
  constructor({ message, codigo = null, status = null, cause = null }) {
    super(message)
    this.name = 'ApiError'
    this.codigo = codigo
    this.status = status
    this.cause = cause
  }
}

/**
 * Convierte cualquier error de axios (respuesta del backend, timeout, red caída,
 * JSON malformado, etc.) en un ApiError consistente y con un mensaje legible
 * para mostrar directo en la UI.
 */
export function normalizeError(error) {
  if (error?.response) {
    const { status, data } = error.response
    const mensaje =
      (typeof data === 'object' && data?.mensaje) ||
      (typeof data === 'string' && data) ||
      `Error inesperado del servidor (HTTP ${status}).`
    const codigo = (typeof data === 'object' && data?.codigo) || null
    return new ApiError({ message: mensaje, codigo, status, cause: error })
  }

  if (error?.request) {
    return new ApiError({
      message:
        'No se pudo contactar al backend (http://localhost:7070). Verifica que Javalin ' +
        'esté corriendo y que el proxy de /api en vite.config.js siga apuntando ahí.',
      status: null,
      cause: error,
    })
  }

  return new ApiError({ message: error?.message ?? 'Error desconocido.', cause: error })
}

/** Envuelve una llamada a axios y siempre rechaza con un ApiError normalizado. */
export async function request(promise) {
  try {
    const response = await promise
    return response.data
  } catch (error) {
    throw normalizeError(error)
  }
}
