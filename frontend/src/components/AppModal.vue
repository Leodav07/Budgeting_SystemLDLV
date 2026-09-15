<script setup>
import { onMounted, onUnmounted } from 'vue'

const props = defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
  narrow: { type: Boolean, default: false },
})
const emit = defineEmits(['close'])

function onKeydown(e) {
  if (e.key === 'Escape') emit('close')
}
onMounted(() => document.addEventListener('keydown', onKeydown))
onUnmounted(() => document.removeEventListener('keydown', onKeydown))
</script>

<template>
  <Teleport to="body">
    <div class="modal-backdrop" @click.self="emit('close')">
      <div class="modal-box" :class="{ narrow: props.narrow }">
        <div class="modal-header">
          <div>
            <h3>{{ title }}</h3>
            <p v-if="subtitle">{{ subtitle }}</p>
          </div>
          <button type="button" class="btn btn-ghost" aria-label="Cerrar" @click="emit('close')">✕</button>
        </div>

        <div>
          <slot />
        </div>

        <div class="modal-footer" v-if="$slots.footer">
          <slot name="footer" />
        </div>
      </div>
    </div>
  </Teleport>
</template>
