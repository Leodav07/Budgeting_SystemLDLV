<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { obligacionService } from '@/services/obligacionService'
import { useCrud } from '@/composables/useCrud'
import AppModal from '@/components/AppModal.vue'
import AppAlert from '@/components/AppAlert.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import EmptyState from '@/components/EmptyState.vue'

const route = useRoute()
const router = useRouter()

const { items: obligaciones, loading, error, run } = useCrud()
const dniInput = ref(route.query.usuario || '')
const activeDni = ref(route.query.usuario || null)
// El backend necesita un valor concreto (true/false) en `vigente` — ver la nota
// en obligacionService.js sobre por qué todavía no hay una opción "todas".
const vigenciaFiltro = ref(true)

function fetchObligaciones() {
  if (!activeDni.value) return
  return run(() => obligacionService.listarPorUsuario(activeDni.value, vigenciaFiltro.value), {
    onSuccess: (data) => (obligaciones.value = data),
  }).catch(() => {})
}

function cargar() {
  if (!dniInput.value) return
  activeDni.value = dniInput.value.trim()
  router.replace({ path: '/obligaciones', query: { usuario: activeDni.value } })
  fetchObligaciones()
}

onMounted(() => {
  if (activeDni.value) fetchObligaciones()
})

watch(
  () => route.query.usuario,
  (val) => {
    if (val && val !== activeDni.value) {
      dniInput.value = val
      activeDni.value = val
      fetchObligaciones()
    }
  },
)

function fmtFecha(v) {
  return v || '—'
}

// ---------- Crear ----------
const showCreate = ref(false)
const createForm = reactive({
  p_usuario_dni: '',
  p_id_subcategoria: '',
  p_nombre: '',
  p_descripcion: '',
  p_monto_fijo: '',
  p_vence_dia: 1,
  p_fecha_inicio: '',
  p_fecha_final: '',
  autor: '',
})
const createErrors = reactive({})
const saving = ref(false)

function openCreate() {
  Object.assign(createForm, {
    p_usuario_dni: activeDni.value || '',
    p_id_subcategoria: '',
    p_nombre: '',
    p_descripcion: '',
    p_monto_fijo: '',
    p_vence_dia: 1,
    p_fecha_inicio: new Date().toISOString().slice(0, 10),
    p_fecha_final: '',
    autor: '',
  })
  Object.keys(createErrors).forEach((k) => delete createErrors[k])
  showCreate.value = true
}

function validateCreate() {
  Object.keys(createErrors).forEach((k) => delete createErrors[k])
  if (!createForm.p_usuario_dni.trim()) createErrors.p_usuario_dni = 'Obligatorio.'
  if (!createForm.p_id_subcategoria) createErrors.p_id_subcategoria = 'Obligatorio.'
  if (!createForm.p_nombre.trim()) createErrors.p_nombre = 'Obligatorio.'
  if (createForm.p_monto_fijo === '') createErrors.p_monto_fijo = 'Obligatorio.'
  if (!createForm.p_fecha_inicio) createErrors.p_fecha_inicio = 'Obligatorio.'
  if (!createForm.autor.trim()) createErrors.autor = 'Indica quién lo crea.'
  return Object.keys(createErrors).length === 0
}

async function submitCreate() {
  if (!validateCreate()) return
  saving.value = true
  try {
    await run(
      () =>
        obligacionService.crear({
          p_usuario_dni: createForm.p_usuario_dni.trim(),
          p_id_subcategoria: Number(createForm.p_id_subcategoria),
          p_nombre: createForm.p_nombre.trim(),
          p_descripcion: createForm.p_descripcion.trim() || null,
          p_monto_fijo: Number(createForm.p_monto_fijo),
          p_vence_dia: Number(createForm.p_vence_dia),
          p_fecha_inicio: createForm.p_fecha_inicio,
          p_fecha_final: createForm.p_fecha_final || null,
          p_creado_por: createForm.autor.trim(),
        }),
      { successMessage: 'Obligacion creada exitosamente.' },
    )
    showCreate.value = false
    if (createForm.p_usuario_dni.trim() === activeDni.value) await fetchObligaciones()
  } catch {
    // error mostrado vía toast
  } finally {
    saving.value = false
  }
}

// ---------- Gestionar por ID ----------
// ObligacionSubcategoria (lo que devuelven listar/consultar) no incluye
// id_obligacion, así que -mismo patrón que Subcategorías y Detalles de
// presupuesto- editar/eliminar se hace buscando por ID conocido.
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
    lookupResult.value = await obligacionService.consultar(lookupId.value)
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
    p_usuario_dni: lookupResult.value.usuario_dni,
    p_id_subcategoria: lookupResult.value.id_subcategoria,
    p_nombre: lookupResult.value.nombre_obligacion,
    p_descripcion: lookupResult.value.descripcion_obligacion || '',
    p_monto_fijo: lookupResult.value.monto_fijo,
    p_vence_dia: lookupResult.value.vence_dia,
    p_fecha_inicio: lookupResult.value.fecha_incio,
    p_fecha_final: lookupResult.value.fecha_final || '',
    autor: '',
  })
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  showEdit.value = true
}

function validateEdit() {
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  if (!editForm.p_nombre?.trim()) editErrors.p_nombre = 'Obligatorio.'
  if (!editForm.autor?.trim()) editErrors.autor = 'Indica quién lo modifica.'
  return Object.keys(editErrors).length === 0
}

async function submitEdit() {
  if (!validateEdit()) return
  saving.value = true
  try {
    await run(
      () =>
        obligacionService.actualizar(lookupId.value, {
          p_usuario_dni: editForm.p_usuario_dni,
          p_id_subcategoria: Number(editForm.p_id_subcategoria),
          p_nombre: editForm.p_nombre.trim(),
          p_descripcion: editForm.p_descripcion?.trim() || null,
          p_monto_fijo: Number(editForm.p_monto_fijo),
          p_vence_dia: Number(editForm.p_vence_dia),
          p_fecha_inicio: editForm.p_fecha_inicio,
          p_fecha_final: editForm.p_fecha_final || null,
          p_modificado_por: editForm.autor.trim(),
        }),
      { successMessage: 'Obligacion actualizada exitosamente.' },
    )
    showEdit.value = false
    await lookup()
    await fetchObligaciones()
  } catch {
    // error mostrado vía toast
  } finally {
    saving.value = false
  }
}

const confirmingDelete = ref(false)
const deleting = ref(false)

async function confirmDelete(autor) {
  deleting.value = true
  try {
    await run(() => obligacionService.eliminar(lookupId.value, { p_modificado_por: autor }), {
      successMessage: 'Obligacion eliminada correctamente.',
    })
    confirmingDelete.value = false
    lookupResult.value = null
    lookupId.value = ''
    await fetchObligaciones()
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
        <h2>Obligaciones fijas</h2>
        <p>Pagos recurrentes por usuario. La baja es lógica (PATCH, con <code>p_modificado_por</code>).</p>
      </div>
      <button class="btn btn-primary" @click="openCreate">+ Nueva obligación</button>
    </div>

    <AppAlert v-if="error" :message="error.message" />

    <div class="card card-pad" style="margin-bottom: 18px">
      <div class="toolbar">
        <input v-model="dniInput" class="input" style="max-width: 220px" placeholder="DNI del usuario" @keyup.enter="cargar" />
        <button class="btn btn-secondary btn-sm" :disabled="!dniInput || loading" @click="cargar">
          <span v-if="loading" class="spinner spinner-dark" /> Cargar
        </button>
        <div class="pill-select" v-if="activeDni">
          <label>Vigencia</label>
          <select v-model="vigenciaFiltro" class="input" style="max-width: 150px" @change="fetchObligaciones">
            <option :value="true">Vigentes</option>
            <option :value="false">No vigentes</option>
          </select>
        </div>
      </div>
      <p class="hint" style="margin-top: -6px; margin-bottom: 12px" v-if="activeDni">
        El filtro de vigencia ahora viaja como <code>?vigente=...</code> y lo resuelve el backend. Por ahora no hay una
        opción "todas": <code>ObligacionRepository.Listar</code> usa <code>setBoolean</code>, que no admite <code>null</code>.
      </p>

      <div v-if="!activeDni" class="state-box">
        <div class="state-icon">📌</div>
        <span>Ingresa el DNI de un usuario para ver sus obligaciones.</span>
      </div>

      <div v-else-if="loading && !obligaciones.length" class="state-box">
        <span class="spinner spinner-dark" style="width: 22px; height: 22px" />
        <span>Cargando obligaciones…</span>
      </div>

      <EmptyState v-else-if="!obligaciones.length" icon="📌" message="No hay obligaciones para este filtro." />

      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Subcategoría</th>
              <th>Monto fijo</th>
              <th>Vence (día)</th>
              <th>Vigencia</th>
              <th>Vigente</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(o, i) in obligaciones" :key="i">
              <td>{{ o.nombre_obligacion }}</td>
              <td class="cell-muted">{{ o.nombre_subcategoria }}</td>
              <td class="cell-num">{{ Number(o.monto_fijo).toLocaleString('es', { style: 'currency', currency: 'USD' }) }}</td>
              <td class="cell-num">{{ o.vence_dia }}</td>
              <td class="cell-muted">{{ fmtFecha(o.fecha_incio) }} → {{ fmtFecha(o.fecha_final) }}</td>
              <td><StatusBadge :label="o.vigente" /></td>
            </tr>
          </tbody>
        </table>
      </div>

      <p class="hint" style="margin-top: 10px" v-if="activeDni">
        Este listado no trae <code>id_obligacion</code> (revisa <code>ObligacionSubcategoria.java</code>), así que edición/baja
        se hacen por ID en la herramienta de abajo.
      </p>
    </div>

    <div class="card card-pad">
      <div class="section-title">Gestionar por ID</div>
      <div class="section-hint">Busca una obligación por su <code>id_obligacion</code> para editarla o darla de baja.</div>

      <div class="toolbar">
        <input v-model="lookupId" type="number" class="input" style="max-width: 160px" placeholder="ID obligación" @keyup.enter="lookup" />
        <button class="btn btn-secondary btn-sm" :disabled="!lookupId || lookupLoading" @click="lookup">
          <span v-if="lookupLoading" class="spinner spinner-dark" /> Buscar
        </button>
      </div>

      <AppAlert v-if="lookupError" :message="lookupError" />

      <div v-if="lookupResult" class="card card-pad" style="background: var(--color-background-soft)">
        <div class="toolbar" style="margin-bottom: 0">
          <div class="grow">
            <strong>{{ lookupResult.nombre_obligacion }}</strong>
            <span class="cell-muted"> — usuario {{ lookupResult.usuario_dni }}</span>
          </div>
          <StatusBadge :label="lookupResult.vigente" />
          <button class="btn btn-secondary btn-sm" @click="openEdit">Editar</button>
          <button class="btn btn-danger btn-sm" :disabled="!lookupResult.vigente" @click="confirmingDelete = true">Dar de baja</button>
        </div>
      </div>
    </div>

    <!-- Crear -->
    <AppModal v-if="showCreate" title="Nueva obligación fija" @close="showCreate = false">
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

        <div class="field span-2">
          <label>Nombre</label>
          <input v-model="createForm.p_nombre" class="input" :class="{ invalid: createErrors.p_nombre }" maxlength="50" />
          <span class="field-error" v-if="createErrors.p_nombre">{{ createErrors.p_nombre }}</span>
        </div>
        <div class="field span-2">
          <label>Descripción <span class="optional">(opcional)</span></label>
          <textarea v-model="createForm.p_descripcion" class="input" maxlength="255" />
        </div>

        <div class="field">
          <label>Monto fijo</label>
          <input v-model="createForm.p_monto_fijo" type="number" step="0.01" class="input" :class="{ invalid: createErrors.p_monto_fijo }" />
          <span class="field-error" v-if="createErrors.p_monto_fijo">{{ createErrors.p_monto_fijo }}</span>
        </div>
        <div class="field">
          <label>Día de vencimiento</label>
          <input v-model="createForm.p_vence_dia" type="number" min="1" max="31" class="input" />
        </div>

        <div class="field">
          <label>Fecha inicio</label>
          <input v-model="createForm.p_fecha_inicio" type="date" class="input" :class="{ invalid: createErrors.p_fecha_inicio }" />
          <span class="field-error" v-if="createErrors.p_fecha_inicio">{{ createErrors.p_fecha_inicio }}</span>
        </div>
        <div class="field">
          <label>Fecha final <span class="optional">(opcional)</span></label>
          <input v-model="createForm.p_fecha_final" type="date" class="input" />
        </div>

        <div class="field span-2">
          <label>Creado por</label>
          <input v-model="createForm.autor" class="input" :class="{ invalid: createErrors.autor }" maxlength="100" />
          <span class="field-error" v-if="createErrors.autor">{{ createErrors.autor }}</span>
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
    <AppModal v-if="showEdit" :title="`Editar obligación #${lookupId}`" @close="showEdit = false">
      <form class="form-grid" @submit.prevent="submitEdit">
        <div class="field">
          <label>DNI del usuario</label>
          <input v-model="editForm.p_usuario_dni" class="input" maxlength="18" />
        </div>
        <div class="field">
          <label>ID subcategoría</label>
          <input v-model="editForm.p_id_subcategoria" type="number" class="input" />
        </div>
        <div class="field span-2">
          <label>Nombre</label>
          <input v-model="editForm.p_nombre" class="input" :class="{ invalid: editErrors.p_nombre }" maxlength="50" />
          <span class="field-error" v-if="editErrors.p_nombre">{{ editErrors.p_nombre }}</span>
        </div>
        <div class="field span-2">
          <label>Descripción</label>
          <textarea v-model="editForm.p_descripcion" class="input" maxlength="255" />
        </div>
        <div class="field">
          <label>Monto fijo</label>
          <input v-model="editForm.p_monto_fijo" type="number" step="0.01" class="input" />
        </div>
        <div class="field">
          <label>Día de vencimiento</label>
          <input v-model="editForm.p_vence_dia" type="number" min="1" max="31" class="input" />
        </div>
        <div class="field">
          <label>Fecha inicio</label>
          <input v-model="editForm.p_fecha_inicio" type="date" class="input" />
        </div>
        <div class="field">
          <label>Fecha final <span class="optional">(opcional)</span></label>
          <input v-model="editForm.p_fecha_final" type="date" class="input" />
        </div>
        <div class="field span-2">
          <label>Modificado por</label>
          <input v-model="editForm.autor" class="input" :class="{ invalid: editErrors.autor }" maxlength="100" />
          <span class="field-error" v-if="editErrors.autor">{{ editErrors.autor }}</span>
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
      title="Dar de baja obligación"
      :message="`Se dará de baja la obligación #${lookupId}.`"
      confirm-label="Dar de baja"
      require-input
      input-label="Modificado por"
      :loading="deleting"
      @confirm="confirmDelete"
      @cancel="confirmingDelete = false"
    />
  </div>
</template>
