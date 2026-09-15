<script setup>
defineProps({
  type: { type: String, default: 'error' }, // 'error' | 'info'
  message: { type: String, required: true },
})
</script>

<template>
  <div class="alert" :class="type === 'error' ? 'alert-error' : 'alert-info'">
    <strong>{{ type === 'error' ? '⚠' : 'ℹ' }}</strong>
    <span>{{ message }}</span>
  </div>
</template>
