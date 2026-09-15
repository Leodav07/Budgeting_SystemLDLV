import { ref } from 'vue'
import { useToast } from './useToast'

/**
 * Composable genérico para pantallas de listado + CRUD.
 *
 * Centraliza lo que se repetiría en cada una de las 7 vistas: el arreglo de
 * items, un flag de "cargando", el último error (para pintar el <AppAlert>) y
 * un helper `run` que envuelve cualquier llamada al service correspondiente
 * mostrando toasts de éxito/error automáticamente vía useToast().
 *
 * No intenta adivinar los nombres de los métodos de cada service (list/create/
 * update/delete cambian de firma entidad por entidad, como viste en los
 * archivos de src/services/) — cada vista decide qué función de su service
 * llamar dentro de `run(...)`.
 */
export function useCrud() {
  const items = ref([])
  const loading = ref(false)
  const error = ref(null)
  const toast = useToast()

  async function run(action, { onSuccess, successMessage, silent = false } = {}) {
    loading.value = true
    if (!silent) error.value = null
    try {
      const result = await action()
      if (onSuccess) onSuccess(result)
      if (successMessage) toast.success(successMessage)
      return result
    } catch (err) {
      error.value = err
      toast.error(err.message)
      throw err
    } finally {
      loading.value = false
    }
  }

  return { items, loading, error, run }
}
