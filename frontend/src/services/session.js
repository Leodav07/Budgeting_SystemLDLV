import { computed, ref } from 'vue'

// Estado a nivel de módulo (singleton de front, no de backend): todas las
// vistas comparten la misma sesión. Persistimos solo el DNI en localStorage
// para sobrevivir un refresh de página -- el backend no emite ningún token,
// así que esto es apenas "recordar quién entró", no autenticación real por
// petición.
const STORAGE_KEY = 'bsp_sesion_dni'

const dni = ref(localStorage.getItem(STORAGE_KEY) || '')

export function useSession() {
  return {
    dni,
    estaAutenticado: computed(() => !!dni.value),

    iniciarSesion(nuevoDni) {
      dni.value = nuevoDni
      localStorage.setItem(STORAGE_KEY, nuevoDni)
    },

    cerrarSesion() {
      dni.value = ''
      localStorage.removeItem(STORAGE_KEY)
    },
  }
}
