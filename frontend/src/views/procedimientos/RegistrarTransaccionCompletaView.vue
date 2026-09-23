<script setup>
import { reactive, ref } from 'vue'
import { transaccionService, TRANSACCION_TIPOS, METODOS_PAGO } from '@/services/transaccionService'
import { useSession } from '@/services/session'
import { useToast } from '@/composables/useToast'
import AppAlert from '@/components/AppAlert.vue'

const session = useSession()
const toast = useToast()

const emptyForm = () => ({
  p_usuario_dni: '',
  p_id_presupuesto: '',
  p_anio: new Date().getFullYear(),
  p_mes: new Date().getMonth() + 1,
  p_id_subcategoria: '',
  p_tipo: 'gasto',
  p_descripcion: '',
  p_monto: '',
  p_fecha: new Date().toISOString().slice(0, 10),
  p_metodo_pago: 'efectivo',
  p_num_factura: '',
  p_observaciones: '',
  p_id_obligacion: '',
})

const form = reactive(emptyForm())
const errors = reactive({})
const saving = ref(false)
const resultado = ref(null)
const error = ref(null)

function validate() {
  Object.keys(errors).forEach((k) => delete errors[k])
  if (!form.p_usuario_dni.trim()) errors.p_usuario_dni = 'Obligatorio.'
  if (!form.p_id_presupuesto) errors.p_id_presupuesto = 'Obligatorio.'
  if (!form.p_id_subcategoria) errors.p_id_subcategoria = 'Obligatorio.'
  if (form.p_monto === '') errors.p_monto = 'Obligatorio.'
  if (!form.p_fecha) errors.p_fecha = 'Obligatorio.'
  return Object.keys(errors).length === 0
}

async function submit() {
  resultado.value = null
  error.value = null
  if (!validate()) return
  saving.value = true
  try {
    await transaccionService.registrarCompleta({
      p_usuario_dni: form.p_usuario_dni.trim(),
      p_id_presupuesto: Number(form.p_id_presupuesto),
      p_anio: Number(form.p_anio),
      p_mes: Number(form.p_mes),
      p_id_subcategoria: Number(form.p_id_subcategoria),
      p_tipo: form.p_tipo,
      p_descripcion: form.p_descripcion.trim() || null,
      p_monto: Number(form.p_monto),
      p_fecha: form.p_fecha,
      p_metodo_pago: form.p_metodo_pago,
      p_num_factura: form.p_num_factura.trim() || null,
      p_observaciones: form.p_observaciones.trim() || null,
      p_creado_por: session.dni.value,
      p_id_obligacion: form.p_id_obligacion === '' ? null : Number(form.p_id_obligacion),
    })
    resultado.value = 'Transacción registrada correctamente, validada contra la vigencia del presupuesto y el tipo de categoría.'
    toast.success('Transacción registrada exitosamente.')
    Object.assign(form, emptyForm())
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
        <h2>Registrar transacción completa</h2>
        <p>
          Usa <code>sp_registrar_transaccion_completa</code>: valida que el año/mes estén dentro de la vigencia del
          presupuesto y que el tipo coincida con la categoría de la subcategoría, y opcionalmente vincula el pago a
          una obligación fija.
        </p>
      </div>
    </div>

    <AppAlert v-if="error" :message="error" />
    <AppAlert v-if="resultado" type="info" :message="resultado" />

    <div class="card card-pad">
      <form class="form-grid" @submit.prevent="submit">
        <div class="field">
          <label>DNI del usuario</label>
          <input v-model="form.p_usuario_dni" class="input" :class="{ invalid: errors.p_usuario_dni }" maxlength="18" />
          <span class="field-error" v-if="errors.p_usuario_dni">{{ errors.p_usuario_dni }}</span>
        </div>
        <div class="field">
          <label>ID presupuesto</label>
          <input v-model="form.p_id_presupuesto" type="number" class="input" :class="{ invalid: errors.p_id_presupuesto }" />
          <span class="field-error" v-if="errors.p_id_presupuesto">{{ errors.p_id_presupuesto }}</span>
        </div>

        <div class="field">
          <label>Año</label>
          <input v-model="form.p_anio" type="number" class="input" />
        </div>
        <div class="field">
          <label>Mes</label>
          <input v-model="form.p_mes" type="number" min="1" max="12" class="input" />
        </div>

        <div class="field">
          <label>ID subcategoría</label>
          <input v-model="form.p_id_subcategoria" type="number" class="input" :class="{ invalid: errors.p_id_subcategoria }" />
          <span class="field-error" v-if="errors.p_id_subcategoria">{{ errors.p_id_subcategoria }}</span>
        </div>
        <div class="field">
          <label>Tipo</label>
          <select v-model="form.p_tipo" class="input">
            <option v-for="t in TRANSACCION_TIPOS" :key="t" :value="t">{{ t }}</option>
          </select>
          <span class="hint">Debe coincidir con el tipo de la categoría padre.</span>
        </div>

        <div class="field">
          <label>Monto</label>
          <input v-model="form.p_monto" type="number" step="0.01" class="input" :class="{ invalid: errors.p_monto }" />
          <span class="field-error" v-if="errors.p_monto">{{ errors.p_monto }}</span>
        </div>
        <div class="field">
          <label>Fecha</label>
          <input v-model="form.p_fecha" type="date" class="input" :class="{ invalid: errors.p_fecha }" />
          <span class="field-error" v-if="errors.p_fecha">{{ errors.p_fecha }}</span>
        </div>

        <div class="field">
          <label>Método de pago</label>
          <select v-model="form.p_metodo_pago" class="input">
            <option v-for="m in METODOS_PAGO" :key="m" :value="m">{{ m }}</option>
          </select>
        </div>
        <div class="field">
          <label>N° factura <span class="optional">(opcional)</span></label>
          <input v-model="form.p_num_factura" class="input" maxlength="20" />
        </div>

        <div class="field span-2">
          <label>Descripción <span class="optional">(opcional)</span></label>
          <textarea v-model="form.p_descripcion" class="input" maxlength="255" />
        </div>
        <div class="field span-2">
          <label>Observaciones <span class="optional">(opcional)</span></label>
          <input v-model="form.p_observaciones" class="input" maxlength="255" />
        </div>

        <div class="field span-2" style="background: var(--color-primary-soft); border-radius: var(--radius-md); padding: 12px">
          <label>Vincular a obligación fija <span class="optional">(opcional)</span></label>
          <input v-model="form.p_id_obligacion" type="number" class="input" placeholder="ID de la obligación (déjalo vacío si no aplica)" />
          <span class="hint">Si la mandas, la obligación debe existir y usar la misma subcategoría que esta transacción.</span>
        </div>

        <div class="span-2" style="display: flex; justify-content: flex-end">
          <button type="submit" class="btn btn-primary" :disabled="saving">
            <span v-if="saving" class="spinner" /> Registrar transacción
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
