import { ref } from 'vue'

// Estado a nivel de módulo (singleton): todas las vistas comparten la misma
// cola de notificaciones, montada una sola vez en <ToastHost /> dentro de App.vue.
const toasts = ref([])
let nextId = 1

function push(type, message, timeout = 4200) {
  const id = nextId++
  toasts.value.push({ id, type, message })
  if (timeout) {
    setTimeout(() => dismiss(id), timeout)
  }
  return id
}

function dismiss(id) {
  const idx = toasts.value.findIndex((t) => t.id === id)
  if (idx !== -1) toasts.value.splice(idx, 1)
}

export function useToast() {
  return {
    toasts,
    dismiss,
    success: (message) => push('success', message),
    error: (message) => push('error', message, 6000),
    info: (message) => push('info', message),
  }
}
