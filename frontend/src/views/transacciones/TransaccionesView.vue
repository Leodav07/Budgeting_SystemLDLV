<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { transaccionService, TRANSACCION_TIPOS, METODOS_PAGO } from '@/services/transaccionService'
import { useCrud } from '@/composables/useCrud'
import { useSession } from '@/services/session'
import AppModal from '@/components/AppModal.vue'
import AppAlert from '@/components/AppAlert.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import EmptyState from '@/components/EmptyState.vue'

const route = useRoute()
const router = useRouter()

const { items: transacciones, loading, error, run } = useCrud()
const session = useSession()
const presupuestoInput = ref(route.query.presupuesto || '')
const activePresupuestoId = ref(route.query.presupuesto || null)

function fetchTransacciones() {
  if (!activePresupuestoId.value) return
  return run(() => transaccionService.listarPorPresupuesto(activePresupuestoId.value), {
    onSuccess: (data) => (transacciones.value = data),
  }).catch(() => {})
}

function cargar() {
  if (!presupuestoInput.value) return
  activePresupuestoId.value = presupuestoInput.value
  router.replace({ path: '/transacciones', query: { presupuesto: activePresupuestoId.value } })
  fetchTransacciones()
}

onMounted(() => {
  if (activePresupuestoId.value) fetchTransacciones()
})

watch(
  () => route.query.presupuesto,
  (val) => {
    if (val && val !== activePresupuestoId.value) {
      presupuestoInput.value = val
      activePresupuestoId.value = val
      fetchTransacciones()
    }
  },
)

function money(v) {
  return Number(v ?? 0).toLocaleString('es', { style: 'currency', currency: 'USD' })
}
function fmtFecha(v) {
  if (!v) return '—'
  return new Date(v).toLocaleString('es', { dateStyle: 'medium', timeStyle: 'short' })
}

// ---------- Crear ----------
const emptyCreate = () => ({
  p_usuario_dni: '',
  p_anio: new Date().getFullYear(),
  p_mes: new Date().getMonth() + 1,
  p_id_subcategoria: '',
  p_tipo: 'gasto',
  p_descripcion: '',
  p_monto: '',
  p_fecha_ocurrido: new Date().toISOString().slice(0, 16),
  p_metodo_pago: 'efectivo',
  p_num_factura: '',
  p_observaciones: '',
})

const showCreate = ref(false)
const createForm = reactive(emptyCreate())
const createErrors = reactive({})
const saving = ref(false)

function openCreate() {
  Object.assign(createForm, emptyCreate())
  Object.keys(createErrors).forEach((k) => delete createErrors[k])
  showCreate.value = true
}

function validateCreate() {
  Object.keys(createErrors).forEach((k) => delete createErrors[k])
  if (!createForm.p_usuario_dni.trim()) createErrors.p_usuario_dni = 'Obligatorio.'
  if (!createForm.p_id_subcategoria) createErrors.p_id_subcategoria = 'Obligatorio.'
  if (createForm.p_monto === '') createErrors.p_monto = 'Obligatorio.'
  if (!createForm.p_fecha_ocurrido) createErrors.p_fecha_ocurrido = 'Obligatorio.'
  return Object.keys(createErrors).length === 0
}

async function submitCreate() {
  if (!validateCreate()) return
  saving.value = true
  try {
    await run(
      () =>
        transaccionService.crear({
          p_usuario_dni: createForm.p_usuario_dni.trim(),
          p_id_presupuesto: Number(activePresupuestoId.value),
          p_anio: Number(createForm.p_anio),
          p_mes: Number(createForm.p_mes),
          p_id_subcategoria: Number(createForm.p_id_subcategoria),
          p_tipo: createForm.p_tipo,
          p_descripcion: createForm.p_descripcion.trim() || null,
          p_monto: Number(createForm.p_monto),
          p_fecha_ocurrido: createForm.p_fecha_ocurrido,
          p_metodo_pago: createForm.p_metodo_pago,
          p_num_factura: createForm.p_num_factura.trim() || null,
          p_observaciones: createForm.p_observaciones.trim() || null,
          p_creado_por: session.dni.value,
        }),
      { successMessage: 'Transaccion creada exitosamente.' },
    )
    showCreate.value = false
    await fetchTransacciones()
  } catch {
    // error mostrado vía toast
  } finally {
    saving.value = false
  }
}

// ---------- Gestionar por ID ----------
// TransaccionEspecial (lo que devuelven listar/consultar) sigue sin incluir
// id_transaccion, así que -mismo patrón que los demás módulos con vistas
// "join"- editar/eliminar se hace por ID conocido.
const lookupId = ref('')
const lookupResult = ref(null)
const lookupLoading = ref(false)
const lookupError = ref(null)

async function lookup() {
  if (!lookupId.value) return
  lookupLoading.value = true
  lookupError.value = null
  lookupResult.value = null
  try {
    lookupResult.value = await transaccionService.consultar(lookupId.value)
  } catch (e) {
    lookupError.value = e.message
  } finally {
    lookupLoading.value = false
  }
}

const showEdit = ref(false)
const editForm = reactive({})
const editErrors = reactive({})

function openEdit() {
  Object.assign(editForm, {
    p_id_presupuesto: lookupResult.value.id_presupuesto,
    p_anio: lookupResult.value.anio,
    p_mes: lookupResult.value.mes,
    p_id_subcategoria: lookupResult.value.id_subcategoria,
    p_tipo: lookupResult.value.tipo,
    p_descripcion: lookupResult.value.descripcion || '',
    p_monto: lookupResult.value.monto,
    p_fecha_ocurrido: lookupResult.value.fecha_ocurrido?.slice(0, 16) || '',
    p_metodo_pago: lookupResult.value.metodo_pago,
    p_num_factura: lookupResult.value.num_factura || '',
    p_observaciones: lookupResult.value.observaciones || '',
  })
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  showEdit.value = true
}

function validateEdit() {
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  if (editForm.p_monto === '') editErrors.p_monto = 'Obligatorio.'
  return Object.keys(editErrors).length === 0
}

async function submitEdit() {
  if (!validateEdit()) return
  saving.value = true
  try {
    await run(
      () =>
        transaccionService.actualizar(lookupId.value, {
          p_id_presupuesto: Number(editForm.p_id_presupuesto),
          p_anio: Number(editForm.p_anio),
          p_mes: Number(editForm.p_mes),
          p_id_subcategoria: Number(editForm.p_id_subcategoria),
          p_tipo: editForm.p_tipo,
          p_descripcion: editForm.p_descripcion?.trim() || null,
          p_monto: Number(editForm.p_monto),
          p_fecha_ocurrido: editForm.p_fecha_ocurrido,
          p_metodo_pago: editForm.p_metodo_pago,
          p_num_factura: editForm.p_num_factura?.trim() || null,
          p_observaciones: editForm.p_observaciones?.trim() || null,
          // ActualizarTransaccionRequest usa "p_creado_por" también para el update.
          p_creado_por: session.dni.value,
        }),
      { successMessage: 'Transaccion actualizada exitosamente.' },
    )
    showEdit.value = false
    await lookup()
    await fetchTransacciones()
  } catch {
    // error mostrado vía toast
  } finally {
    saving.value = false
  }
}

const confirmingDelete = ref(false)
const deleting = ref(false)

async function confirmDelete() {
  deleting.value = true
  try {
    await run(() => transaccionService.eliminar(lookupId.value), { successMessage: 'Transaccion eliminada correctamente.' })
    confirmingDelete.value = false
    lookupResult.value = null
    lookupId.value = ''
    await fetchTransacciones()
  } catch {
    // error mostrado vía toast
  } finally {
    deleting.value = false
  }
}
</script>

<template>
  <div>
    <div class="app-topbar">
      <div>
        <h2>Transacciones</h2>
        <p>Registra y consulta los movimientos de ingreso, gasto y ahorro dentro de un presupuesto.</p>
      </div>
      <button class="btn btn-primary" :disabled="!activePresupuestoId" @click="openCreate">+ Nueva transacción</button>
    </div>

    <AppAlert v-if="error" :message="error.message" />

    <div class="card card-pad" style="margin-bottom: 18px">
      <div class="toolbar">
        <input v-model="presupuestoInput" type="number" class="input" style="max-width: 200px" placeholder="ID de presupuesto" @keyup.enter="cargar" />
        <button class="btn btn-secondary btn-sm" :disabled="!presupuestoInput || loading" @click="cargar">
          <span v-if="loading" class="spinner spinner-dark" /> Cargar
        </button>
      </div>

      <div v-if="!activePresupuestoId" class="state-box">
        <div class="state-icon">💸</div>
        <span>Ingresa un ID de presupuesto para ver sus transacciones.</span>
      </div>

      <div v-else-if="loading && !transacciones.length" class="state-box">
        <span class="spinner spinner-dark" style="width: 22px; height: 22px" />
        <span>Cargando transacciones…</span>
      </div>

      <EmptyState v-else-if="!transacciones.length" icon="💸" message="Este presupuesto todavía no tiene transacciones." />

      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Tipo</th>
              <th>Descripción</th>
              <th>Monto</th>
              <th>Método de pago</th>
              <th>N° factura</th>
              <th>Usuario</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(t, i) in transacciones" :key="i">
              <td class="cell-muted">{{ fmtFecha(t.fecha_ocurrido) }}</td>
              <td><StatusBadge :label="t.tipo" /></td>
              <td>{{ t.descripcion || '—' }}</td>
              <td class="cell-num">{{ money(t.monto) }}</td>
              <td class="cell-muted">{{ t.metodo_pago }}</td>
              <td class="cell-muted">{{ t.num_factura || '—' }}</td>
              <td class="cell-muted">{{ t.usuario_dni }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <p class="hint" style="margin-top: 10px" v-if="activePresupuestoId">
        Para editar o eliminar una transacción, búscala por su ID en la herramienta de abajo.
      </p>
    </div>

    <div class="card card-pad">
      <div class="section-title">Gestionar por ID</div>
      <div class="section-hint">Busca una transacción por su <code>id_transaccion</code> para editarla o eliminarla.</div>

      <div class="toolbar">
        <input v-model="lookupId" type="number" class="input" style="max-width: 160px" placeholder="ID transacción" @keyup.enter="lookup" />
        <button class="btn btn-secondary btn-sm" :disabled="!lookupId || lookupLoading" @click="lookup">
          <span v-if="lookupLoading" class="spinner spinner-dark" /> Buscar
        </button>
      </div>

      <AppAlert v-if="lookupError" :message="lookupError" />

      <div v-if="lookupResult" class="card card-pad" style="background: var(--color-background-soft)">
        <div class="toolbar" style="margin-bottom: 0">
          <div class="grow">
            <strong>{{ money(lookupResult.monto) }}</strong>
            <span class="cell-muted"> — {{ lookupResult.descripcion || 'sin descripción' }}</span>
          </div>
          <StatusBadge :label="lookupResult.tipo" />
          <button class="btn btn-secondary btn-sm" @click="openEdit">Editar</button>
          <button class="btn btn-danger btn-sm" @click="confirmingDelete = true">Eliminar</button>
        </div>
      </div>
    </div>

    <!-- Crear -->
    <AppModal v-if="showCreate" title="Nueva transacción" :subtitle="`Presupuesto #${activePresupuestoId}`" @close="showCreate = false">
      <form class="form-grid" @submit.prevent="submitCreate">
        <div class="field">
          <label>DNI del usuario</label>
          <input v-model="createForm.p_usuario_dni" class="input" :class="{ invalid: createErrors.p_usuario_dni }" maxlength="18" />
          <span class="field-error" v-if="createErrors.p_usuario_dni">{{ createErrors.p_usuario_dni }}</span>
        </div>
        <div class="field">
          <label>ID subcategoría</label>
          <input v-model="createForm.p_id_subcategoria" type="number" class="input" :class="{ invalid: createErrors.p_id_subcategoria }" />
          <span class="field-error" v-if="createErrors.p_id_subcategoria">{{ createErrors.p_id_subcategoria }}</span>
        </div>

        <div class="field">
          <label>Año</label>
          <input v-model="createForm.p_anio" type="number" class="input" />
        </div>
        <div class="field">
          <label>Mes</label>
          <input v-model="createForm.p_mes" type="number" min="1" max="12" class="input" />
        </div>

        <div class="field">
          <label>Tipo</label>
          <select v-model="createForm.p_tipo" class="input">
            <option v-for="t in TRANSACCION_TIPOS" :key="t" :value="t">{{ t }}</option>
          </select>
        </div>
        <div class="field">
          <label>Método de pago</label>
          <select v-model="createForm.p_metodo_pago" class="input">
            <option v-for="m in METODOS_PAGO" :key="m" :value="m">{{ m }}</option>
          </select>
        </div>

        <div class="field">
          <label>Monto</label>
          <input v-model="createForm.p_monto" type="number" step="0.01" class="input" :class="{ invalid: createErrors.p_monto }" />
          <span class="field-error" v-if="createErrors.p_monto">{{ createErrors.p_monto }}</span>
        </div>
        <div class="field">
          <label>Fecha y hora ocurrido</label>
          <input v-model="createForm.p_fecha_ocurrido" type="datetime-local" class="input" :class="{ invalid: createErrors.p_fecha_ocurrido }" />
          <span class="field-error" v-if="createErrors.p_fecha_ocurrido">{{ createErrors.p_fecha_ocurrido }}</span>
        </div>

        <div class="field span-2">
          <label>Descripción <span class="optional">(opcional)</span></label>
          <textarea v-model="createForm.p_descripcion" class="input" maxlength="255" />
        </div>
        <div class="field">
          <label>N° factura <span class="optional">(opcional)</span></label>
          <input v-model="createForm.p_num_factura" class="input" maxlength="20" />
        </div>
        <div class="field">
          <label>Observaciones <span class="optional">(opcional)</span></label>
          <input v-model="createForm.p_observaciones" class="input" maxlength="255" />
        </div>

      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" @click="showCreate = false">Cancelar</button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submitCreate">
          <span v-if="saving" class="spinner" /> Guardar
        </button>
      </template>
    </AppModal>

    <!-- Editar -->
    <AppModal v-if="showEdit" :title="`Editar transacción #${lookupId}`" @close="showEdit = false">
      <form class="form-grid" @submit.prevent="submitEdit">
        <div class="field">
          <label>ID subcategoría</label>
          <input v-model="editForm.p_id_subcategoria" type="number" class="input" />
        </div>
        <div class="field">
          <label>ID presupuesto</label>
          <input v-model="editForm.p_id_presupuesto" type="number" class="input" />
        </div>
        <div class="field">
          <label>Año</label>
          <input v-model="editForm.p_anio" type="number" class="input" />
        </div>
        <div class="field">
          <label>Mes</label>
          <input v-model="editForm.p_mes" type="number" min="1" max="12" class="input" />
        </div>
        <div class="field">
          <label>Tipo</label>
          <select v-model="editForm.p_tipo" class="input">
            <option v-for="t in TRANSACCION_TIPOS" :key="t" :value="t">{{ t }}</option>
          </select>
        </div>
        <div class="field">
          <label>Método de pago</label>
          <select v-model="editForm.p_metodo_pago" class="input">
            <option v-for="m in METODOS_PAGO" :key="m" :value="m">{{ m }}</option>
          </select>
        </div>
        <div class="field">
          <label>Monto</label>
          <input v-model="editForm.p_monto" type="number" step="0.01" class="input" :class="{ invalid: editErrors.p_monto }" />
          <span class="field-error" v-if="editErrors.p_monto">{{ editErrors.p_monto }}</span>
        </div>
        <div class="field">
          <label>Fecha y hora ocurrido</label>
          <input v-model="editForm.p_fecha_ocurrido" type="datetime-local" class="input" />
        </div>
        <div class="field span-2">
          <label>Descripción</label>
          <textarea v-model="editForm.p_descripcion" class="input" maxlength="255" />
        </div>
        <div class="field">
          <label>N° factura <span class="optional">(opcional)</span></label>
          <input v-model="editForm.p_num_factura" class="input" maxlength="20" />
        </div>
        <div class="field">
          <label>Observaciones <span class="optional">(opcional)</span></label>
          <input v-model="editForm.p_observaciones" class="input" maxlength="255" />
        </div>
      </form>
      <template #footer>
        <button type="button" class="btn btn-secondary" @click="showEdit = false">Cancelar</button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submitEdit">
          <span v-if="saving" class="spinner" /> Guardar
        </button>
      </template>
    </AppModal>

    <ConfirmDialog
      v-if="confirmingDelete"
      title="Eliminar transacción"
      :message="`Se eliminará la transacción #${lookupId}. Falla si es de tipo AHORRO.`"
      confirm-label="Eliminar"
      :loading="deleting"
      @confirm="confirmDelete"
      @cancel="confirmingDelete = false"
    />
  </div>
</template>
