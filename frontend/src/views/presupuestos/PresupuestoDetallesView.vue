<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { presupuestoDetalleService } from '@/services/presupuestoDetalleService'
import { useCrud } from '@/composables/useCrud'
import { useSession } from '@/services/session'
import AppModal from '@/components/AppModal.vue'
import AppAlert from '@/components/AppAlert.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import EmptyState from '@/components/EmptyState.vue'

const props = defineProps({ idPresupuesto: { type: String, default: null } })
const route = useRoute()
const router = useRouter()

const { items: detalles, loading, error, run } = useCrud()
const session = useSession()
const presupuestoIdInput = ref(props.idPresupuesto || '')
const activePresupuestoId = ref(props.idPresupuesto || null)

function fetchDetalles() {
  if (!activePresupuestoId.value) return
  return run(() => presupuestoDetalleService.listarPorPresupuesto(activePresupuestoId.value), {
    onSuccess: (data) => (detalles.value = data),
  }).catch(() => {})
}

function cargar() {
  if (!presupuestoIdInput.value) return
  activePresupuestoId.value = presupuestoIdInput.value
  router.replace(`/presupuestos-detalles/${presupuestoIdInput.value}`)
  fetchDetalles()
}

onMounted(() => {
  if (activePresupuestoId.value) fetchDetalles()
})

watch(
  () => route.params.idPresupuesto,
  (val) => {
    if (val && val !== activePresupuestoId.value) {
      presupuestoIdInput.value = val
      activePresupuestoId.value = val
      fetchDetalles()
    }
  },
)

const cabecera = ref(null)
watch(detalles, (list) => {
  cabecera.value = list?.[0] || null
})

function money(v) {
  return Number(v ?? 0).toLocaleString('es', { style: 'currency', currency: 'USD' })
}

// ---------- Crear ----------
const showCreate = ref(false)
const createForm = reactive({ p_id_subcategoria: '', p_monto_asignado: '', p_justificacion_monto: '' })
const createErrors = reactive({})
const saving = ref(false)

function openCreate() {
  Object.assign(createForm, { p_id_subcategoria: '', p_monto_asignado: '', p_justificacion_monto: '' })
  Object.keys(createErrors).forEach((k) => delete createErrors[k])
  showCreate.value = true
}

function validateCreate() {
  Object.keys(createErrors).forEach((k) => delete createErrors[k])
  if (!createForm.p_id_subcategoria) createErrors.p_id_subcategoria = 'Obligatorio.'
  if (createForm.p_monto_asignado === '') createErrors.p_monto_asignado = 'Obligatorio.'
  return Object.keys(createErrors).length === 0
}

async function submitCreate() {
  if (!validateCreate()) return
  saving.value = true
  try {
    await run(
      () =>
        presupuestoDetalleService.crear({
          p_id_presupuesto: Number(activePresupuestoId.value),
          p_id_subcategoria: Number(createForm.p_id_subcategoria),
          p_monto_asignado: Number(createForm.p_monto_asignado),
          p_justificacion_monto: createForm.p_justificacion_monto.trim() || null,
          p_creado_por: session.dni.value,
        }),
      { successMessage: 'Detalle de presupuesto creado exitosamente.' },
    )
    showCreate.value = false
    await fetchDetalles()
  } catch {
    // error mostrado vía toast
  } finally {
    saving.value = false
  }
}

// ---------- Gestionar por ID (editar / eliminar) ----------
// ListarPresupuestoDetalle / ConsultaPresupuestoDetalle no exponen id_pdetalle,
// así que -igual que en Subcategorías- no hay forma de editar/eliminar una fila
// directamente desde la tabla. Se opera por ID conocido.
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
    lookupResult.value = await presupuestoDetalleService.consultar(lookupId.value)
  } catch (e) {
    lookupError.value = e.message
  } finally {
    lookupLoading.value = false
  }
}

const showEdit = ref(false)
const editForm = reactive({ p_monto_asignado: '', p_justificacion_monto: '' })
const editErrors = reactive({})

function openEdit() {
  Object.assign(editForm, {
    p_monto_asignado: lookupResult.value.monto_asignado,
    p_justificacion_monto: lookupResult.value.justificacion_monto || '',
  })
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  showEdit.value = true
}

function validateEdit() {
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  if (editForm.p_monto_asignado === '') editErrors.p_monto_asignado = 'Obligatorio.'
  return Object.keys(editErrors).length === 0
}

async function submitEdit() {
  if (!validateEdit()) return
  saving.value = true
  try {
    await run(
      () =>
        presupuestoDetalleService.actualizar(lookupId.value, {
          p_id_presupuesto_detalle: Number(lookupId.value),
          p_monto_asignado: Number(editForm.p_monto_asignado),
          p_justificacion_monto: editForm.p_justificacion_monto.trim() || null,
          p_modificado_por: session.dni.value,
        }),
      { successMessage: 'Detalle actualizado exitosamente.' },
    )
    showEdit.value = false
    await lookup()
    await fetchDetalles()
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
    await run(() => presupuestoDetalleService.eliminar(lookupId.value), { successMessage: 'Detalle eliminado correctamente.' })
    confirmingDelete.value = false
    lookupResult.value = null
    lookupId.value = ''
    await fetchDetalles()
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
        <h2>Detalles de presupuesto</h2>
        <p>Montos asignados por subcategoría dentro de un presupuesto.</p>
      </div>
      <button class="btn btn-primary" :disabled="!activePresupuestoId" @click="openCreate">+ Nuevo detalle</button>
    </div>

    <AppAlert v-if="error" :message="error.message" />

    <div class="card card-pad" style="margin-bottom: 18px">
      <div class="toolbar">
        <input v-model="presupuestoIdInput" type="number" class="input" style="max-width: 200px" placeholder="ID de presupuesto" @keyup.enter="cargar" />
        <button class="btn btn-secondary btn-sm" :disabled="!presupuestoIdInput || loading" @click="cargar">
          <span v-if="loading" class="spinner spinner-dark" /> Cargar
        </button>
        <RouterLink
          v-if="cabecera"
          class="btn btn-secondary btn-sm"
          :to="{ path: '/presupuestos', query: { usuario: cabecera.usuario_dni } }"
        >Ver presupuesto</RouterLink>
      </div>

      <div v-if="!activePresupuestoId" class="state-box">
        <div class="state-icon">🧾</div>
        <span>Ingresa un ID de presupuesto para ver sus detalles.</span>
      </div>

      <div v-else-if="loading && !detalles.length" class="state-box">
        <span class="spinner spinner-dark" style="width: 22px; height: 22px" />
        <span>Cargando detalles…</span>
      </div>

      <EmptyState v-else-if="!detalles.length" icon="🧾" message="Este presupuesto todavía no tiene detalles asignados." />

      <template v-else>
        <div class="card card-pad" style="background: var(--color-background-soft); margin-bottom: 14px" v-if="cabecera">
          <strong>{{ cabecera.nombre_presupuesto }}</strong> — usuario {{ cabecera.usuario_dni }}
          <StatusBadge :label="cabecera.estado_presupuesto" style="margin-left: 8px" />
          <div class="summary-grid" style="grid-template-columns: repeat(3, minmax(0, 1fr)); margin-top: 10px">
            <div><span class="cell-muted">Ingresos</span><br /><strong>{{ money(cabecera.total_ingresos) }}</strong></div>
            <div><span class="cell-muted">Gastos</span><br /><strong>{{ money(cabecera.total_gastos) }}</strong></div>
            <div><span class="cell-muted">Ahorro</span><br /><strong>{{ money(cabecera.total_ahorro) }}</strong></div>
          </div>
        </div>

        <div class="table-wrap">
          <table class="data-table">
            <thead>
              <tr>
                <th>Subcategoría</th>
                <th>Categoría</th>
                <th>Monto asignado</th>
                <th>Justificación</th>
                <th>Estado subcategoría</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(d, i) in detalles" :key="i">
                <td>{{ d.nombre_subcategoria }}</td>
                <td class="cell-muted">#{{ d.id_categoria }}</td>
                <td class="cell-num">{{ money(d.monto_asignado) }}</td>
                <td class="cell-muted">{{ d.justificacion_monto || '—' }}</td>
                <td><StatusBadge :label="d.estado_subcategoria ? 'Activo' : 'Inactivo'" /></td>
              </tr>
            </tbody>
          </table>
        </div>

        <p class="hint" style="margin-top: 10px">
          Este listado no trae <code>id_pdetalle</code> (revisa <code>ListarPresupuestoDetalle.java</code>), así que edición/baja
          se hacen por ID en la herramienta de abajo.
        </p>
      </template>
    </div>

    <div class="card card-pad">
      <div class="section-title">Gestionar por ID</div>
      <div class="section-hint">Busca un detalle por su <code>id_pdetalle</code> para editarlo o eliminarlo.</div>

      <div class="toolbar">
        <input v-model="lookupId" type="number" class="input" style="max-width: 160px" placeholder="ID detalle" @keyup.enter="lookup" />
        <button class="btn btn-secondary btn-sm" :disabled="!lookupId || lookupLoading" @click="lookup">
          <span v-if="lookupLoading" class="spinner spinner-dark" /> Buscar
        </button>
      </div>

      <AppAlert v-if="lookupError" :message="lookupError" />

      <div v-if="lookupResult" class="card card-pad" style="background: var(--color-background-soft)">
        <div class="toolbar" style="margin-bottom: 0">
          <div class="grow">
            <strong>{{ lookupResult.nombre_subcategoria }}</strong>
            <span class="cell-muted"> — {{ lookupResult.nombre_categoria }}</span>
            <div class="cell-muted" style="margin-top: 2px">{{ money(lookupResult.monto_asignado) }}</div>
          </div>
          <button class="btn btn-secondary btn-sm" @click="openEdit">Editar</button>
          <button class="btn btn-danger btn-sm" @click="confirmingDelete = true">Eliminar</button>
        </div>
      </div>
    </div>

    <!-- Crear -->
    <AppModal v-if="showCreate" title="Nuevo detalle de presupuesto" :subtitle="`Presupuesto #${activePresupuestoId}`" @close="showCreate = false">
      <form class="form-grid single" @submit.prevent="submitCreate">
        <div class="field">
          <label>ID subcategoría</label>
          <input v-model="createForm.p_id_subcategoria" type="number" class="input" :class="{ invalid: createErrors.p_id_subcategoria }" />
          <span class="hint">No hay un listado global de subcategorías; consíguelo en la pantalla de Subcategorías.</span>
          <span class="field-error" v-if="createErrors.p_id_subcategoria">{{ createErrors.p_id_subcategoria }}</span>
        </div>
        <div class="field">
          <label>Monto asignado</label>
          <input v-model="createForm.p_monto_asignado" type="number" step="0.01" class="input" :class="{ invalid: createErrors.p_monto_asignado }" />
          <span class="field-error" v-if="createErrors.p_monto_asignado">{{ createErrors.p_monto_asignado }}</span>
        </div>
        <div class="field">
          <label>Justificación <span class="optional">(opcional)</span></label>
          <textarea v-model="createForm.p_justificacion_monto" class="input" maxlength="255" />
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
    <AppModal v-if="showEdit" :title="`Editar detalle #${lookupId}`" @close="showEdit = false">
      <form class="form-grid single" @submit.prevent="submitEdit">
        <div class="field">
          <label>Monto asignado</label>
          <input v-model="editForm.p_monto_asignado" type="number" step="0.01" class="input" :class="{ invalid: editErrors.p_monto_asignado }" />
          <span class="field-error" v-if="editErrors.p_monto_asignado">{{ editErrors.p_monto_asignado }}</span>
        </div>
        <div class="field">
          <label>Justificación <span class="optional">(opcional)</span></label>
          <textarea v-model="editForm.p_justificacion_monto" class="input" maxlength="255" />
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
      title="Eliminar detalle"
      message="Se eliminará este detalle de presupuesto."
      confirm-label="Eliminar"
      :loading="deleting"
      @confirm="confirmDelete"
      @cancel="confirmingDelete = false"
    />
  </div>
</template>
