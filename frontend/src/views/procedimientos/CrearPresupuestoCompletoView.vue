<script setup>
import { reactive, ref } from 'vue'
import { presupuestoService } from '@/services/presupuestoService'
import { useSession } from '@/services/session'
import { useToast } from '@/composables/useToast'
import AppAlert from '@/components/AppAlert.vue'

const session = useSession()
const toast = useToast()

const emptyForm = () => ({
  p_usuario_dni: '',
  p_nombre: '',
  p_descripcion: '',
  p_periodo_inicio: new Date().toISOString().slice(0, 10),
  p_periodo_fin: new Date().toISOString().slice(0, 10),
})

const form = reactive(emptyForm())
const detalles = ref([{ id_subcategoria: '', monto_mensual: '' }])
const errors = reactive({})
const saving = ref(false)
const resultado = ref(null)
const error = ref(null)

function agregarDetalle() {
  detalles.value.push({ id_subcategoria: '', monto_mensual: '' })
}
function quitarDetalle(i) {
  detalles.value.splice(i, 1)
}

function validate() {
  Object.keys(errors).forEach((k) => delete errors[k])
  if (!form.p_usuario_dni.trim()) errors.p_usuario_dni = 'Obligatorio.'
  if (!form.p_nombre.trim()) errors.p_nombre = 'Obligatorio.'
  if (!form.p_periodo_inicio) errors.p_periodo_inicio = 'Obligatorio.'
  if (!form.p_periodo_fin) errors.p_periodo_fin = 'Obligatorio.'
  if (!detalles.value.length || detalles.value.some((d) => !d.id_subcategoria || d.monto_mensual === '')) {
    errors.detalles = 'Completa la subcategoría y el monto de cada detalle, o elimina las filas vacías.'
  }
  return Object.keys(errors).length === 0
}

async function submit() {
  resultado.value = null
  error.value = null
  if (!validate()) return
  saving.value = true
  try {
    await presupuestoService.crearCompleto({
      p_usuario_dni: form.p_usuario_dni.trim(),
      p_nombre: form.p_nombre.trim(),
      p_descripcion: form.p_descripcion.trim() || null,
      p_periodo_inicio: form.p_periodo_inicio,
      p_periodo_fin: form.p_periodo_fin,
      p_lista_subcategorias_json: detalles.value.map((d) => ({
        id_subcategoria: Number(d.id_subcategoria),
        monto_mensual: Number(d.monto_mensual),
      })),
      p_creado_por: session.dni.value,
    })
    resultado.value = 'Presupuesto creado con todos sus detalles en una sola operación atómica.'
    toast.success('Presupuesto creado exitosamente.')
    Object.assign(form, emptyForm())
    detalles.value = [{ id_subcategoria: '', monto_mensual: '' }]
  } catch (e) {
    error.value = e.message
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div>
    <div class="app-topbar">
      <div>
        <h2>Crear presupuesto completo</h2>
        <p>
          Usa <code>sp_crear_presupuesto_completo</code>: crea el presupuesto y todos sus detalles por subcategoría
          en una sola transacción — si algo falla, no queda nada a medias.
        </p>
      </div>
    </div>

    <AppAlert v-if="error" :message="error" />
    <AppAlert v-if="resultado" type="info" :message="resultado" />

    <div class="card card-pad" style="margin-bottom: 18px">
      <form class="form-grid" @submit.prevent="submit">
        <div class="field">
          <label>DNI del usuario</label>
          <input v-model="form.p_usuario_dni" class="input" :class="{ invalid: errors.p_usuario_dni }" maxlength="18" />
          <span class="field-error" v-if="errors.p_usuario_dni">{{ errors.p_usuario_dni }}</span>
        </div>
        <div class="field">
          <label>Nombre del presupuesto</label>
          <input v-model="form.p_nombre" class="input" :class="{ invalid: errors.p_nombre }" maxlength="40" />
          <span class="field-error" v-if="errors.p_nombre">{{ errors.p_nombre }}</span>
        </div>

        <div class="field span-2">
          <label>Descripción <span class="optional">(opcional)</span></label>
          <textarea v-model="form.p_descripcion" class="input" maxlength="200" />
        </div>

        <div class="field">
          <label>Periodo inicio</label>
          <input v-model="form.p_periodo_inicio" type="date" class="input" :class="{ invalid: errors.p_periodo_inicio }" />
          <span class="field-error" v-if="errors.p_periodo_inicio">{{ errors.p_periodo_inicio }}</span>
        </div>
        <div class="field">
          <label>Periodo fin</label>
          <input v-model="form.p_periodo_fin" type="date" class="input" :class="{ invalid: errors.p_periodo_fin }" />
          <span class="field-error" v-if="errors.p_periodo_fin">{{ errors.p_periodo_fin }}</span>
        </div>
      </form>
    </div>

    <div class="card card-pad">
      <div class="section-title">Detalles por subcategoría</div>
      <div class="section-hint">Monto mensual asignado a cada subcategoría durante toda la vigencia del presupuesto.</div>

      <div v-for="(d, i) in detalles" :key="i" class="toolbar" style="margin-top: 10px">
        <div class="field" style="max-width: 180px">
          <label>ID subcategoría</label>
          <input v-model="d.id_subcategoria" type="number" class="input" />
        </div>
        <div class="field" style="max-width: 200px">
          <label>Monto mensual</label>
          <input v-model="d.monto_mensual" type="number" step="0.01" class="input" />
        </div>
        <button
          type="button"
          class="btn btn-danger btn-sm"
          style="align-self: flex-end"
          :disabled="detalles.length === 1"
          @click="quitarDetalle(i)"
        >
          Quitar
        </button>
      </div>
      <span class="field-error" v-if="errors.detalles" style="display: block; margin-top: 8px">{{ errors.detalles }}</span>

      <button type="button" class="btn btn-secondary btn-sm" style="margin-top: 12px" @click="agregarDetalle">
        + Agregar subcategoría
      </button>

      <div style="display: flex; justify-content: flex-end; margin-top: 18px">
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submit">
          <span v-if="saving" class="spinner" /> Crear presupuesto completo
        </button>
      </div>
    </div>
  </div>
</template>
