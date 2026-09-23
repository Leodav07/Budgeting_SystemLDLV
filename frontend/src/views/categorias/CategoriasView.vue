<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { categoriaService, CATEGORIA_TIPOS } from '@/services/categoriaService'
import { useCrud } from '@/composables/useCrud'
import { useSession } from '@/services/session'
import AppModal from '@/components/AppModal.vue'
import AppAlert from '@/components/AppAlert.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import EmptyState from '@/components/EmptyState.vue'

const { items: categorias, loading, error, run } = useCrud()
const session = useSession()
const search = ref('')

const filtered = computed(() => {
  const q = search.value.trim().toLowerCase()
  if (!q) return categorias.value
  return categorias.value.filter((c) => c.nombre.toLowerCase().includes(q) || c.tipo.toLowerCase().includes(q))
})

function fetchCategorias() {
  return run(() => categoriaService.listar(), { onSuccess: (data) => (categorias.value = data) }).catch(() => {})
}
onMounted(fetchCategorias)

// ---------- Crear / editar ----------
const emptyForm = () => ({
  id: null,
  p_nombre: '',
  p_descripcion: '',
  p_tipo: 'gasto',
  p_icono_nombre: '',
  p_color_hex: '#4f46e5',
  p_orden: '',
})

const showForm = ref(false)
const formMode = ref('create')
const form = reactive(emptyForm())
const formErrors = reactive({})
const saving = ref(false)

function openCreate() {
  formMode.value = 'create'
  Object.assign(form, emptyForm())
  clearErrors()
  showForm.value = true
}

function openEdit(c) {
  formMode.value = 'edit'
  Object.assign(form, {
    id: c.id_categoria,
    p_nombre: c.nombre,
    p_descripcion: c.descripcion || '',
    p_tipo: c.tipo,
    p_icono_nombre: c.icono_nombre || '',
    p_color_hex: c.color_hex || '#4f46e5',
    p_orden: c.orden ?? '',
  })
  clearErrors()
  showForm.value = true
}

function clearErrors() {
  Object.keys(formErrors).forEach((k) => delete formErrors[k])
}

function validate() {
  clearErrors()
  if (!form.p_nombre.trim()) formErrors.p_nombre = 'El nombre es obligatorio.'
  if (formMode.value === 'create' && !form.p_tipo) formErrors.p_tipo = 'Selecciona un tipo.'
  return Object.keys(formErrors).length === 0
}

async function submitForm() {
  if (!validate()) return
  saving.value = true
  try {
    if (formMode.value === 'create') {
      await run(
        () =>
          categoriaService.crear({
            p_nombre: form.p_nombre.trim(),
            p_descripcion: form.p_descripcion.trim() || null,
            p_tipo: form.p_tipo,
            p_icono_nombre: form.p_icono_nombre.trim() || null,
            p_color_hex: form.p_color_hex || null,
            p_orden: form.p_orden === '' ? null : Number(form.p_orden),
            p_creado_por: session.dni.value,
          }),
        { successMessage: 'Categoria creada exitosamente.' },
      )
    } else {
      await run(
        () =>
          categoriaService.actualizar(form.id, {
            p_nombre: form.p_nombre.trim(),
            p_descripcion: form.p_descripcion.trim() || null,
            p_modificado_por: session.dni.value,
          }),
        { successMessage: 'Categoria actualizada exitosamente.' },
      )
    }
    showForm.value = false
    await fetchCategorias()
  } catch {
    // error mostrado vía toast
  } finally {
    saving.value = false
  }
}

// ---------- Eliminar ----------
const deleteTarget = ref(null)
const deleting = ref(false)

async function confirmDelete() {
  deleting.value = true
  try {
    await run(() => categoriaService.eliminar(deleteTarget.value.id_categoria), {
      successMessage: 'Categoria eliminada correctamente.',
    })
    deleteTarget.value = null
    await fetchCategorias()
  } catch {
    // error mostrado vía toast (puede ser CATEGORIA_NO_EXISTE o SUBCATEGORIA_ACTIVA)
  } finally {
    deleting.value = false
  }
}
</script>

<template>
  <div>
    <div class="app-topbar">
      <div>
        <h2>Categorías</h2>
        <p>Clasifica tus ingresos, gastos y ahorros por categoría. El tipo, ícono, color y orden solo se definen al crear.</p>
      </div>
      <button class="btn btn-primary" @click="openCreate">+ Nueva categoría</button>
    </div>

    <AppAlert v-if="error" :message="error.message" />

    <div class="card card-pad">
      <div class="toolbar">
        <input v-model="search" class="input grow" placeholder="Buscar por nombre o tipo..." />
        <button class="btn btn-secondary btn-sm" :disabled="loading" @click="fetchCategorias">
          <span v-if="loading" class="spinner spinner-dark" /> Recargar
        </button>
      </div>

      <div v-if="loading && !categorias.length" class="state-box">
        <span class="spinner spinner-dark" style="width: 22px; height: 22px" />
        <span>Cargando categorías…</span>
      </div>

      <EmptyState
        v-else-if="!filtered.length"
        icon="🗂️"
        :message="search ? 'No hay resultados para tu búsqueda.' : 'Crea la primera categoría.'"
      />

      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Tipo</th>
              <th>Descripción</th>
              <th>Orden</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="c in filtered" :key="c.id_categoria">
              <td class="cell-num">{{ c.id_categoria }}</td>
              <td>
                <span
                  style="display: inline-block; width: 9px; height: 9px; border-radius: 50%; margin-right: 6px"
                  :style="{ background: c.color_hex || '#94a3b8' }"
                />{{ c.nombre }}
              </td>
              <td><StatusBadge :label="c.tipo" /></td>
              <td class="cell-muted">{{ c.descripcion || '—' }}</td>
              <td class="cell-num">{{ c.orden ?? '—' }}</td>
              <td>
                <div class="cell-actions">
                  <RouterLink class="btn btn-secondary btn-sm" :to="`/subcategorias/${c.id_categoria}`">Subcategorías</RouterLink>
                  <button class="btn btn-secondary btn-sm" @click="openEdit(c)">Editar</button>
                  <button class="btn btn-danger btn-sm" @click="deleteTarget = c">Eliminar</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <AppModal
      v-if="showForm"
      :title="formMode === 'create' ? 'Nueva categoría' : `Editar categoría #${form.id}`"
      @close="showForm = false"
    >
      <form class="form-grid" @submit.prevent="submitForm">
        <div class="field span-2">
          <label>Nombre</label>
          <input v-model="form.p_nombre" class="input" :class="{ invalid: formErrors.p_nombre }" maxlength="50" />
          <span class="field-error" v-if="formErrors.p_nombre">{{ formErrors.p_nombre }}</span>
        </div>
        <div class="field span-2">
          <label>Descripción <span class="optional">(opcional)</span></label>
          <textarea v-model="form.p_descripcion" class="input" maxlength="250" />
        </div>

        <div class="field">
          <label>Tipo</label>
          <select v-model="form.p_tipo" class="input" :disabled="formMode === 'edit'">
            <option v-for="t in CATEGORIA_TIPOS" :key="t" :value="t">{{ t }}</option>
          </select>
          <span class="hint" v-if="formMode === 'edit'">El tipo no se puede cambiar una vez creada.</span>
        </div>
        <div class="field">
          <label>Orden <span class="optional">(opcional)</span></label>
          <input v-model="form.p_orden" type="number" class="input" :disabled="formMode === 'edit'" />
        </div>

        <div class="field">
          <label>Ícono <span class="optional">(opcional)</span></label>
          <input v-model="form.p_icono_nombre" class="input" :disabled="formMode === 'edit'" placeholder="p. ej. wallet" />
        </div>
        <div class="field">
          <label>Color <span class="optional">(opcional)</span></label>
          <input v-model="form.p_color_hex" type="color" class="input" style="height: 34px; padding: 3px" :disabled="formMode === 'edit'" />
        </div>
      </form>

      <template #footer>
        <button type="button" class="btn btn-secondary" @click="showForm = false">Cancelar</button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submitForm">
          <span v-if="saving" class="spinner" /> Guardar
        </button>
      </template>
    </AppModal>

    <ConfirmDialog
      v-if="deleteTarget"
      title="Eliminar categoría"
      :message="`Se eliminará la categoría '${deleteTarget.nombre}'. Esta acción falla si tiene subcategorías activas.`"
      confirm-label="Eliminar"
      :loading="deleting"
      @confirm="confirmDelete"
      @cancel="deleteTarget = null"
    />
  </div>
</template>
