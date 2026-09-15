<script setup>
defineProps({
  icon: { type: String, default: '📭' },
  title: { type: String, default: 'Sin resultados' },
  message: { type: String, default: '' },
})
</script>

<template>
  <div class="state-box">
    <div class="state-icon">{{ icon }}</div>
    <strong>{{ title }}</strong>
    <span v-if="message">{{ message }}</span>
  </div>
</template>
