<script setup>
// Badge de propósito general para valores de ENUM/estado (tipo, estado, vigente, etc).
// `tone` se puede forzar manualmente o inferir automáticamente del texto.
const props = defineProps({
  label: { type: [String, Boolean], required: true },
  tone: { type: String, default: null }, // 'success' | 'danger' | 'warning' | 'info' | 'neutral'
})

const AUTO_TONES = {
  activo: 'success',
  true: 'success',
  vigente: 'success',
  ingreso: 'success',
  cerrado: 'neutral',
  borrador: 'warning',
  inactivo: 'danger',
  false: 'danger',
  gasto: 'danger',
  ahorro: 'info',
}

function resolveTone() {
  if (props.tone) return props.tone
  const key = String(props.label).toLowerCase()
  return AUTO_TONES[key] || 'neutral'
}

function resolveLabel() {
  if (typeof props.label === 'boolean') return props.label ? 'Sí' : 'No'
  return props.label
}
</script>

<template>
  <span class="badge" :class="`badge-${resolveTone()}`">{{ resolveLabel() }}</span>
</template>
