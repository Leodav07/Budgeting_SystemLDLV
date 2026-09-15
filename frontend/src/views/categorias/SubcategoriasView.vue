<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { subcategoriaService } from '@/services/subcategoriaService'
import { categoriaService } from '@/services/categoriaService'
import { useCrud } from '@/composables/useCrud'
import { useToast } from '@/composables/useToast'
import AppModal from '@/components/AppModal.vue'
import AppAlert from '@/components/AppAlert.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import EmptyState from '@/components/EmptyState.vue'

const props = defineProps({ idCategoria: { type: String, default: null } })
const route = useRoute()
const router = useRouter()
const toast = useToast()

const { items: subcategorias, loading, error, run } = useCrud()
const categorias = ref([])
const selectedCategoriaId = ref(props.idCategoria ? Number(props.idCategoria) : null)
const selectedCategoria = ref(null)

async function loadCategorias() {
  try {
    categorias.value = await categoriaService.listar()
  } catch (e) {
    toast.error(e.message)
  }
}

function fetchSubcategorias() {
  if (!selectedCategoriaId.value) return
  selectedCategoria.value = categorias.value.find((c) => c.id_categoria === selectedCategoriaId.value) || null
  return run(() => subcategoriaService.listarPorCategoria(selectedCategoriaId.value), {
    onSuccess: (data) => (subcategorias.value = data),
  }).catch(() => {})
}

onMounted(async () => {
  await loadCategorias()
  if (selectedCategoriaId.value) fetchSubcategorias()
})

watch(
  () => route.params.idCategoria,
  (val) => {
    if (val) {
      selectedCategoriaId.value = Number(val)
      fetchSubcategorias()
    }
  },
)

function onPickCategoria() {
  router.replace(selectedCategoriaId.value ? `/subcategorias/${selectedCategoriaId.value}` : '/subcategorias')
  fetchSubcategorias()
}

// ---------- Crear ----------
const showCreate = ref(false)
const createForm = reactive({ p_nombre: '', p_descripcion: '', autor: '' })
const createErrors = reactive({})
const saving = ref(false)

function openCreate() {
  Object.assign(createForm, { p_nombre: '', p_descripcion: '', autor: '' })
  Object.keys(createErrors).forEach((k) => delete createErrors[k])
  showCreate.value = true
}

function validateCreate() {
  Object.keys(createErrors).forEach((k) => delete createErrors[k])
  if (!createForm.p_nombre.trim()) createErrors.p_nombre = 'El nombre es obligatorio.'
  if (!createForm.autor.trim()) createErrors.autor = 'Indica quién lo crea.'
  return Object.keys(createErrors).length === 0
}

async function submitCreate() {
  if (!validateCreate()) return
  saving.value = true
  try {
    await run(
      () =>
        subcategoriaService.crear({
          p_id_categoria: selectedCategoriaId.value,
          p_nombre: createForm.p_nombre.trim(),
          p_descripcion: createForm.p_descripcion.trim() || null,
          p_creado_por: createForm.autor.trim(),
        }),
      { successMessage: 'Subcategoria creada exitosamente.' },
    )
    showCreate.value = false
    await fetchSubcategorias()
  } catch {
    // error mostrado vía toast
  } finally {
    saving.value = false
  }
}

// ---------- Gestionar por ID (editar / eliminar) ----------
// El listado por categoría (CategoriaSubcategoria) no incluye id_subcategoria,
// así que no hay forma de editar/eliminar una fila directamente desde la tabla.
// Esta mini-herramienta busca una subcategoría puntual por su ID para poder
// operar sobre ella.
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
    lookupResult.value = await subcategoriaService.consultar(lookupId.value)
  } catch (e) {
    lookupError.value = e.message
  } finally {
    lookupLoading.value = false
  }
}

const showEdit = ref(false)
const editForm = reactive({ p_nombre: '', p_descripcion: '', p_estado: true, autor: '' })
const editErrors = reactive({})

function openEdit() {
  Object.assign(editForm, {
    p_nombre: lookupResult.value.nombre_subcategoria,
    p_descripcion: lookupResult.value.descripcion_subcategoria || '',
    p_estado: !!lookupResult.value.sc_estado,
    autor: '',
  })
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  showEdit.value = true
}

function validateEdit() {
  Object.keys(editErrors).forEach((k) => delete editErrors[k])
  if (!editForm.p_nombre.trim()) editErrors.p_nombre = 'El nombre es obligatorio.'
  if (!editForm.autor.trim()) editErrors.autor = 'Indica quién lo modifica.'
  return Object.keys(editErrors).length === 0
}

async function submitEdit() {
  if (!validateEdit()) return
  saving.value = true
  try {
    await run(
      () =>
        subcategoriaService.actualizar(lookupId.value, {
          p_nombre: editForm.p_nombre.trim(),
          p_descripcion: editForm.p_descripcion.trim() || null,
          p_estado: editForm.p_estado,
          p_modificado_por: editForm.autor.trim(),
        }),
      { successMessage: 'Subcategoria actualizada exitosamente.' },
    )
    showEdit.value = false
    await lookup()
    await fetchSubcategorias()
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
    await run(() => subcategoriaService.eliminar(lookupId.value), {
      successMessage: 'Subcategoria eliminada correctamente.',
    })
    confirmingDelete.value = false
    lookupResult.value = null
    lookupId.value = ''
    await fetchSubcategorias()
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
        <h2>Subcategorías</h2>
        <p>El listado (<code>GET /api/categorias/{id}/subcategorias</code>) siempre requiere una categoría de contexto.</p>
      </div>
      <button class="btn btn-primary" :disabled="!selectedCategoriaId" @click="openCreate">+ Nueva subcategoría</button>
    </div>

    <AppAlert v-if="error" :message="error.message" />

    <div class="card card-pad" style="margin-bottom: 18px">
      <div class="toolbar">
        <div class="pill-select grow">
          <label>Categoría</label>
          <select v-model="selectedCategoriaId" class="input" @change="onPickCategoria">
            <option :value="null" disabled>Selecciona una categoría…</option>
            <option v-for="c in categorias" :key="c.id_categoria" :value="c.id_categoria">
              {{ c.nombre }} ({{ c.tipo }})
            </option>
          </select>
        </div>
        <button class="btn btn-secondary btn-sm" :disabled="!selectedCategoriaId || loading" @click="fetchSubcategorias">
          <span v-if="loading" class="spinner spinner-dark" /> Recargar
        </button>
      </div>

      <div v-if="!selectedCategoriaId" class="state-box">
        <div class="state-icon">🗂️</div>
        <span>Elige una categoría para ver sus subcategorías.</span>
      </div>

      <div v-else-if="loading && !subcategorias.length" class="state-box">
        <span class="spinner spinner-dark" style="width: 22px; height: 22px" />
        <span>Cargando subcategorías…</span>
      </div>

      <EmptyState v-else-if="!subcategorias.length" icon="🏷️" message="Esta categoría todavía no tiene subcategorías." />

      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Descripción</th>
              <th>Estado</th>
              <th>Por defecto</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(s, i) in subcategorias" :key="i">
              <td>{{ s.nombre_subcategoria }}</td>
              <td class="cell-muted">{{ s.descripcion_subcategoria || '—' }}</td>
              <td><StatusBadge :label="s.sc_estado ? 'Activo' : 'Inactivo'" /></td>
              <td><StatusBadge :label="s.sc_por_defecto" /></td>
            </tr>
          </tbody>
        </table>
      </div>

      <p class="hint" style="margin-top: 10px">
        Este listado no trae <code>id_subcategoria</code> (revisa <code>CategoriaSubcategoria.java</code> y su mapper en
        <code>SubcategoriaRepository</code>), por eso no hay acciones de editar/eliminar directamente en la fila. Usa la
        herramienta de abajo si ya conoces el ID.
      </p>
    </div>

    <div class="card card-pad">
      <div class="section-title">Gestionar por ID</div>
      <div class="section-hint">Busca una subcategoría por su <code>id_subcategoria</code> para editarla o eliminarla.</div>

      <div class="toolbar">
        <input v-model="lookupId" type="number" class="input" style="max-width: 160px" placeholder="ID subcategoría" @keyup.enter="lookup" />
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
            <div class="cell-muted" style="margin-top: 2px">{{ lookupResult.descripcion_subcategoria || 'Sin descripción' }}</div>
          </div>
          <StatusBadge :label="lookupResult.sc_estado ? 'Activo' : 'Inactivo'" />
          <button class="btn btn-secondary btn-sm" @click="openEdit">Editar</button>
          <button class="btn btn-danger btn-sm" @click="confirmingDelete = true">Eliminar</button>
        </div>
      </div>
    </div>

    <!-- Crear -->
    <AppModal v-if="showCreate" title="Nueva subcategoría" :subtitle="`Categoría: ${selectedCategoria?.nombre ?? ''}`" @close="showCreate = false">
      <form class="form-grid single" @submit.prevent="submitCreate">
        <div class="field">
          <label>Nombre</label>
          <input v-model="createForm.p_nombre" class="input" :class="{ invalid: createErrors.p_nombre }" maxlength="50" />
          <span class="field-error" v-if="createErrors.p_nombre">{{ createErrors.p_nombre }}</span>
        </div>
        <div class="field">
          <label>Descripción <span class="optional">(opcional)</span></label>
          <textarea v-model="createForm.p_descripcion" class="input" maxlength="255" />
        </div>
        <div class="field">
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
    <AppModal v-if="showEdit" :title="`Editar subcategoría #${lookupId}`" @close="showEdit = false">
      <form class="form-grid single" @submit.prevent="submitEdit">
        <div class="field">
          <label>Nombre</label>
          <input v-model="editForm.p_nombre" class="input" :class="{ invalid: editErrors.p_nombre }" maxlength="50" />
          <span class="field-error" v-if="editErrors.p_nombre">{{ editErrors.p_nombre }}</span>
        </div>
        <div class="field">
          <label>Descripción <span class="optional">(opcional)</span></label>
          <textarea v-model="editForm.p_descripcion" class="input" maxlength="255" />
        </div>
        <div class="checkbox-row">
          <input id="sc_estado" type="checkbox" v-model="editForm.p_estado" />
          <label for="sc_estado">Activo</label>
        </div>
        <div class="field">
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
      title="Eliminar subcategoría"
      :message="`Se eliminará '${lookupResult?.nombre_subcategoria}'. Falla si está en uso en presupuestos/transacciones.`"
      confirm-label="Eliminar"
      :loading="deleting"
      @confirm="confirmDelete"
      @cancel="confirmingDelete = false"
    />
  </div>
</template>
