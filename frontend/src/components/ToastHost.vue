<script setup>
// Host único para las notificaciones flotantes. Se monta una sola vez en
// App.vue; cualquier vista dispara toasts llamando useToast().success(...)
// / .error(...) / .info(...) — no hace falta importar este componente en
// ningún otro lado.
import { useToast } from '@/composables/useToast'

const { toasts, dismiss } = useToast()

const icons = {
  success: '✓',
  error: '!',
  info: 'i',
}
</script>

<template>
  <Teleport to="body">
    <div class="toast-host">
      <TransitionGroup name="toast-fade">
        <div
          v-for="t in toasts"
          :key="t.id"
          class="toast"
          :class="`toast-${t.type}`"
          @click="dismiss(t.id)"
        >
          <strong>{{ icons[t.type] }}</strong>
          <span>{{ t.message }}</span>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<style scoped>
.toast {
  cursor: pointer;
}
.toast-fade-enter-active,
.toast-fade-leave-active {
  transition: all 0.2s ease;
}
.toast-fade-enter-from,
.toast-fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
