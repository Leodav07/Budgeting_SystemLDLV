import { computed, ref } from 'vue'

// Estado a nivel de módulo (singleton de front, no de backend): todas las
// vistas comparten la misma sesión. Persistimos DNI y nombre en localStorage
// para sobrevivir un refresh de página -- el backend no emite ningún token,
// así que esto es apenas "recordar quién entró", no autenticación real por
// petición.
const STORAGE_KEY = 'bsp_sesion_dni'
const STORAGE_NOMBRE_KEY = 'bsp_sesion_nombre'

const dni = ref(localStorage.getItem(STORAGE_KEY) || '')
const nombre = ref(localStorage.getItem(STORAGE_NOMBRE_KEY) || '')

export function useSession() {
  return {
    dni,
    nombre,
    estaAutenticado: computed(() => !!dni.value),

    iniciarSesion(nuevoDni, nuevoNombre = '') {
      dni.value = nuevoDni
      nombre.value = nuevoNombre
      localStorage.setItem(STORAGE_KEY, nuevoDni)
      localStorage.setItem(STORAGE_NOMBRE_KEY, nuevoNombre)
    },

    cerrarSesion() {
      dni.value = ''
      nombre.value = ''
      localStorage.removeItem(STORAGE_KEY)
      localStorage.removeItem(STORAGE_NOMBRE_KEY)
    },
  }
}
