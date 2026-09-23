<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { presupuestoService, PRESUPUESTO_ESTADOS } from '@/services/presupuestoService'
import { useCrud } from '@/composables/useCrud'
import { useSession } from '@/services/session'
import AppModal from '@/components/AppModal.vue'
import AppAlert from '@/components/AppAlert.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import EmptyState from '@/components/EmptyState.vue'

const route = useRoute()
const router = useRouter()

const { items: presupuestos, loading, error, run } = useCrud()
const session = useSession()
const dniInput = ref(route.query.usuario || '')
const activeDni = ref(route.query.usuario || null)
const estadoFiltro = ref('') // '' = todas

function fetchPresupuestos() {
  if (!activeDni.value) return
  return run(() => presupuestoService.listarPorUsuario(activeDni.value, estadoFiltro.value || null), {
    onSuccess: (data) => (presupuestos.value = data),
  }).catch(() => {})
}

function cargar() {
  if (!dniInput.value) return
  activeDni.value = dniInput.value.trim()
  router.replace({ path: '/presupuestos', query: { usuario: activeDni.value } })
  fetchPresupuestos()
}

onMounted(() => {
  if (activeDni.value) fetchPresupuestos()
})

watch(
  () => route.query.usuario,
  (val) => {
    if (val && val !== activeDni.value) {
      dniInput.value = val
      activeDni.value = val
      fetchPresupuestos()
    }
  },
)

function money(v) {
  return Number(v ?? 0).toLocaleString('es', { style: 'currency', currency: 'USD' })
}

// ---------- Crear ----------
const emptyCreate = () => ({
  p_usuario_dni: activeDni.value || '',
  p_nombre: '',
  p_descripcion: '',
  p_anio_inicio: new Date().getFullYear(),
  p_mes_inicio: new Date().getMonth() + 1,
  p_anio_final: new Date().getFullYear(),
  p_mes_final: new Date().getMonth() + 1,
  p_total_ingresos: 0,
  p_total_gastos: 0,
  p_total_ahorro: 0,
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
  if (!createForm.p_usuario_dni.trim()) createErrors.p_usuario_dni = 'El DNI del usuario es obligatorio.'
  if (!createForm.p_nombre.trim()) createErrors.p_nombre = 'El nombre es obligatorio.'
  return Object.keys(createErrors).length === 0
}

async function submitCreate() {
  if (!validateCreate()) return
  saving.value = true
  try {
    await run(
      () =>
        presupuestoService.crear({
          p_usuario_dni: createForm.p_usuario_dni.trim(),
          p_nombre: createForm.p_nombre.trim(),
          p_descripcion: createForm.p_descripcion.trim() || null,
          p_anio_inicio: Number(createForm.p_anio_inicio),
          p_mes_inicio: Number(createForm.p_mes_inicio),
          p_anio_final: Number(createForm.p_anio_final),
          p_mes_final: Number(createForm.p_mes_final),
          p_total_ingresos: Number(createForm.p_total_ingresos),
          p_total_gastos: Number(createForm.p_total_gastos),
          p_total_ahorro: Number(createForm.p_total_ahorro),
          p_creado_por: session.dni.value,
        }),
      { successMessage: 'Presupuesto creado exitosamente.' },
    )
    showCreate.value = false
    if (createForm.p_usuario_dni.trim() === activeDni.value) await fetchPresupuestos()
  } catch {
    // error mostrado vía toast
  } finally {
    saving.value = false
  }
}

// ---------- Editar (directo desde la fila, el modelo sí trae id_presupuesto) ----------
const showEdit = ref(false)
const editingId = ref(null)
const editForm = reactive({})
const editErrors = reactive({})

function openEdit(p) {
  editingId.value = p.id_presupuesto
  Object.assign(editForm, {
    p_usuario_dni: p.usuario_dni,
    p_nombre: p.nombre,
    p_descripcion: p.descripcion || '',
    p_anio_inicio: p.anio_inicio,
    p_mes_inicio: p.mes_inicio,
    p_anio_final: p.anio_fin,
    p_mes_final: p.mes_fin,
    p_total_ingresos: p.total_ingresos,
    p_total_gastos: p.total_gastos,
    p_total_ahorro: p.total_ahorro,
    p_estado: p.estado,
  })
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  showEdit.value = true
}

function validateEdit() {
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  if (!editForm.p_usuario_dni?.trim()) editErrors.p_usuario_dni = 'Obligatorio.'
  if (!editForm.p_nombre?.trim()) editErrors.p_nombre = 'Obligatorio.'
  return Object.keys(editErrors).length === 0
}

async function submitEdit() {
  if (!validateEdit()) return
  saving.value = true
  try {
    await run(
      () =>
        presupuestoService.actualizar(editingId.value, {
          p_usuario_dni: editForm.p_usuario_dni.trim(),
          p_nombre: editForm.p_nombre.trim(),
          p_descripcion: editForm.p_descripcion?.trim() || null,
          p_anio_inicio: Number(editForm.p_anio_inicio),
          p_mes_inicio: Number(editForm.p_mes_inicio),
          p_anio_final: Number(editForm.p_anio_final),
          p_mes_final: Number(editForm.p_mes_final),
          p_total_ingresos: Number(editForm.p_total_ingresos),
          p_total_gastos: Number(editForm.p_total_gastos),
          p_total_ahorro: Number(editForm.p_total_ahorro),
          p_estado: editForm.p_estado,
          p_modificado_por: session.dni.value,
        }),
      { successMessage: 'Presupuesto actualizado exitosamente.' },
    )
    showEdit.value = false
    await fetchPresupuestos()
  } catch {
    // error mostrado vía toast
  } finally {
    saving.value = false
  }
}

// ---------- Eliminar (baja lógica, sin body) ----------
const deleteTarget = ref(null)
const deleting = ref(false)

async function confirmDelete() {
  deleting.value = true
  try {
    await run(() => presupuestoService.eliminar(deleteTarget.value.id_presupuesto), {
      successMessage: 'Presupuesto eliminado correctamente.',
    })
    deleteTarget.value = null
    await fetchPresupuestos()
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
        <h2>Presupuestos</h2>
        <p>Define y administra los presupuestos mensuales de cada usuario.</p>
      </div>
      <button class="btn btn-primary" @click="openCreate">+ Nuevo presupuesto</button>
    </div>

    <AppAlert v-if="error" :message="error.message" />

    <div class="card card-pad">
      <div class="toolbar">
        <input v-model="dniInput" class="input" style="max-width: 220px" placeholder="DNI del usuario" @keyup.enter="cargar" />
        <button class="btn btn-secondary btn-sm" :disabled="!dniInput || loading" @click="cargar">
          <span v-if="loading" class="spinner spinner-dark" /> Cargar
        </button>
        <div class="pill-select" v-if="activeDni">
          <label>Estado</label>
          <select v-model="estadoFiltro" class="input" style="max-width: 150px" @change="fetchPresupuestos">
            <option value="">Todos</option>
            <option v-for="e in PRESUPUESTO_ESTADOS" :key="e" :value="e">{{ e }}</option>
          </select>
        </div>
      </div>

      <div v-if="!activeDni" class="state-box">
        <div class="state-icon">📅</div>
        <span>Ingresa el DNI de un usuario para ver sus presupuestos.</span>
      </div>

      <div v-else-if="loading && !presupuestos.length" class="state-box">
        <span class="spinner spinner-dark" style="width: 22px; height: 22px" />
        <span>Cargando presupuestos…</span>
      </div>

      <EmptyState v-else-if="!presupuestos.length" icon="📅" message="Este usuario todavía no tiene presupuestos." />

      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Periodo</th>
              <th>Ingresos</th>
              <th>Gastos</th>
              <th>Ahorro</th>
              <th>Estado</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in presupuestos" :key="p.id_presupuesto">
              <td>{{ p.nombre }}</td>
              <td class="cell-muted">{{ p.anio_inicio }}/{{ p.mes_inicio }} → {{ p.anio_fin }}/{{ p.mes_fin }}</td>
              <td class="cell-num">{{ money(p.total_ingresos) }}</td>
              <td class="cell-num">{{ money(p.total_gastos) }}</td>
              <td class="cell-num">{{ money(p.total_ahorro) }}</td>
              <td><StatusBadge :label="p.estado" /></td>
              <td>
                <div class="cell-actions">
                  <RouterLink class="btn btn-secondary btn-sm" :to="`/presupuestos-detalles/${p.id_presupuesto}`">Detalles</RouterLink>
                  <RouterLink class="btn btn-secondary btn-sm" :to="{ path: '/transacciones', query: { presupuesto: p.id_presupuesto } }">Transacciones</RouterLink>
                  <button class="btn btn-secondary btn-sm" @click="openEdit(p)">Editar</button>
                  <button class="btn btn-danger btn-sm" @click="deleteTarget = p">Dar de baja</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Crear -->
    <AppModal v-if="showCreate" title="Nuevo presupuesto" @close="showCreate = false">
      <form class="form-grid" @submit.prevent="submitCreate">
        <div class="field">
          <label>DNI del usuario</label>
          <input v-model="createForm.p_usuario_dni" class="input" :class="{ invalid: createErrors.p_usuario_dni }" maxlength="18" />
          <span class="field-error" v-if="createErrors.p_usuario_dni">{{ createErrors.p_usuario_dni }}</span>
        </div>
        <div class="field">
          <label>Nombre</label>
          <input v-model="createForm.p_nombre" class="input" :class="{ invalid: createErrors.p_nombre }" maxlength="40" />
          <span class="field-error" v-if="createErrors.p_nombre">{{ createErrors.p_nombre }}</span>
        </div>

        <div class="field span-2">
          <label>Descripción <span class="optional">(opcional)</span></label>
          <textarea v-model="createForm.p_descripcion" class="input" maxlength="200" />
        </div>

        <div class="field">
          <label>Año inicio</label>
          <input v-model="createForm.p_anio_inicio" type="number" class="input" />
        </div>
        <div class="field">
          <label>Mes inicio</label>
          <input v-model="createForm.p_mes_inicio" type="number" min="1" max="12" class="input" />
        </div>
        <div class="field">
          <label>Año final</label>
          <input v-model="createForm.p_anio_final" type="number" class="input" />
        </div>
        <div class="field">
          <label>Mes final</label>
          <input v-model="createForm.p_mes_final" type="number" min="1" max="12" class="input" />
        </div>

        <div class="field">
          <label>Total ingresos</label>
          <input v-model="createForm.p_total_ingresos" type="number" step="0.01" class="input" />
          <span class="hint">Monto máximo: 999,999.99</span>
        </div>
        <div class="field">
          <label>Total gastos</label>
          <input v-model="createForm.p_total_gastos" type="number" step="0.01" class="input" />
        </div>
        <div class="field">
          <label>Total ahorro</label>
          <input v-model="createForm.p_total_ahorro" type="number" step="0.01" class="input" />
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
    <AppModal v-if="showEdit" :title="`Editar presupuesto #${editingId}`" @close="showEdit = false">
      <form class="form-grid" @submit.prevent="submitEdit">
        <div class="field">
          <label>DNI del usuario</label>
          <input v-model="editForm.p_usuario_dni" class="input" :class="{ invalid: editErrors.p_usuario_dni }" maxlength="18" />
        </div>
        <div class="field">
          <label>Nombre</label>
          <input v-model="editForm.p_nombre" class="input" :class="{ invalid: editErrors.p_nombre }" maxlength="40" />
        </div>
        <div class="field span-2">
          <label>Descripción</label>
          <textarea v-model="editForm.p_descripcion" class="input" maxlength="200" />
        </div>
        <div class="field">
          <label>Año inicio</label>
          <input v-model="editForm.p_anio_inicio" type="number" class="input" />
        </div>
        <div class="field">
          <label>Mes inicio</label>
          <input v-model="editForm.p_mes_inicio" type="number" min="1" max="12" class="input" />
        </div>
        <div class="field">
          <label>Año final</label>
          <input v-model="editForm.p_anio_final" type="number" class="input" />
        </div>
        <div class="field">
          <label>Mes final</label>
          <input v-model="editForm.p_mes_final" type="number" min="1" max="12" class="input" />
        </div>
        <div class="field">
          <label>Total ingresos</label>
          <input v-model="editForm.p_total_ingresos" type="number" step="0.01" class="input" />
        </div>
        <div class="field">
          <label>Total gastos</label>
          <input v-model="editForm.p_total_gastos" type="number" step="0.01" class="input" />
        </div>
        <div class="field">
          <label>Total ahorro</label>
          <input v-model="editForm.p_total_ahorro" type="number" step="0.01" class="input" />
        </div>
        <div class="field">
          <label>Estado</label>
          <select v-model="editForm.p_estado" class="input">
            <option v-for="e in PRESUPUESTO_ESTADOS" :key="e" :value="e">{{ e }}</option>
          </select>
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
      v-if="deleteTarget"
      title="Dar de baja presupuesto"
      :message="`Se dará de baja el presupuesto '${deleteTarget.nombre}'. Falla si tiene transacciones asociadas.`"
      confirm-label="Dar de baja"
      :loading="deleting"
      @confirm="confirmDelete"
      @cancel="deleteTarget = null"
    />
  </div>
</template>
