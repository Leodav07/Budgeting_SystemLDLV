<script setup>
import { ref } from 'vue'
import AppModal from './AppModal.vue'

/**
 * Diálogo de confirmación reutilizable. Se usa tanto para deletes "simples"
 * (DELETE HTTP, sin body: Categoria, Subcategoria, Transaccion) como para las
 * bajas lógicas que exigen un `p_modificado_por` en el body (Usuario,
 * Presupuesto, Obligacion, PresupuestoDetalle) activando `require-input`.
 */
const props = defineProps({
  title: { type: String, default: '¿Confirmar acción?' },
  message: { type: String, default: '' },
  confirmLabel: { type: String, default: 'Confirmar' },
  danger: { type: Boolean, default: true },
  requireInput: { type: Boolean, default: false },
  inputLabel: { type: String, default: 'Modificado por' },
  inputPlaceholder: { type: String, default: 'Tu nombre o usuario' },
  loading: { type: Boolean, default: false },
})
const emit = defineEmits(['confirm', 'cancel'])

const storageKey = 'bsp_ultimo_autor'
const inputValue = ref(localStorage.getItem(storageKey) || '')
const touched = ref(false)

const invalid = () => props.requireInput && !inputValue.value.trim()

function onConfirm() {
  touched.value = true
  if (invalid()) return
  if (props.requireInput) {
    localStorage.setItem(storageKey, inputValue.value.trim())
  }
  emit('confirm', props.requireInput ? inputValue.value.trim() : undefined)
}
</script>

<template>
  <AppModal :title="title" narrow @close="emit('cancel')">
    <p style="font-size: 13.5px; color: var(--color-text)">{{ message }}</p>

    <div class="field" style="margin-top: 14px" v-if="requireInput">
      <label>{{ inputLabel }}</label>
      <input
        v-model="inputValue"
        class="input"
        :class="{ invalid: touched && invalid() }"
        :placeholder="inputPlaceholder"
        @keyup.enter="onConfirm"
      />
      <span class="field-error" v-if="touched && invalid()">Este campo es obligatorio.</span>
    </div>

    <template #footer>
      <button type="button" class="btn btn-secondary" @click="emit('cancel')">Cancelar</button>
      <button
        type="button"
        class="btn"
        :class="danger ? 'btn-danger' : 'btn-primary'"
        :disabled="loading"
        @click="onConfirm"
      >
        <span v-if="loading" class="spinner spinner-dark" />
        {{ confirmLabel }}
      </button>
    </template>
  </AppModal>
</template>
