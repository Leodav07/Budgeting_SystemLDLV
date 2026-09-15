<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { usuarioService } from '@/services/usuarioService'
import { useCrud } from '@/composables/useCrud'
import AppModal from '@/components/AppModal.vue'
import AppAlert from '@/components/AppAlert.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import EmptyState from '@/components/EmptyState.vue'

const { items: usuarios, loading, error, run } = useCrud()
const search = ref('')

const filtered = computed(() => {
  const q = search.value.trim().toLowerCase()
  if (!q) return usuarios.value
  return usuarios.value.filter((u) =>
    [u.usuario_dni, u.primer_nombre, u.primer_apellido, u.email]
      .filter(Boolean)
      .some((v) => v.toLowerCase().includes(q)),
  )
})

function fetchUsuarios() {
  // .catch(() => {}) porque esto se llama "fire and forget" desde onMounted:
  // el error ya queda visible vía toast + `error` (useCrud), no hace falta propagarlo.
  return run(() => usuarioService.listar(), { onSuccess: (data) => (usuarios.value = data) }).catch(() => {})
}
onMounted(fetchUsuarios)

// ---------- Crear / editar ----------
const emptyForm = () => ({
  dni: '',
  p_nombre: '',
  s_nombre: '',
  p_apellido: '',
  s_apellido: '',
  correo_elec: '',
  psalario: '',
  autor: '',
})

const showForm = ref(false)
const formMode = ref('create') // 'create' | 'edit'
const form = reactive(emptyForm())
const formErrors = reactive({})
const saving = ref(false)

function openCreate() {
  formMode.value = 'create'
  Object.assign(form, emptyForm())
  clearErrors()
  showForm.value = true
}

function openEdit(u) {
  formMode.value = 'edit'
  Object.assign(form, {
    dni: u.usuario_dni,
    p_nombre: u.primer_nombre || '',
    s_nombre: u.segundo_nombre || '',
    p_apellido: u.primer_apellido || '',
    s_apellido: u.segundo_apellido || '',
    correo_elec: u.email || '',
    psalario: u.salario ?? '',
    autor: '',
  })
  clearErrors()
  showForm.value = true
}

function clearErrors() {
  Object.keys(formErrors).forEach((k) => delete formErrors[k])
}

function validate() {
  clearErrors()
  if (formMode.value === 'create' && !form.dni.trim()) formErrors.dni = 'El DNI es obligatorio.'
  if (!form.p_nombre.trim()) formErrors.p_nombre = 'El primer nombre es obligatorio.'
  if (!form.p_apellido.trim()) formErrors.p_apellido = 'El primer apellido es obligatorio.'
  if (!form.correo_elec.trim()) formErrors.correo_elec = 'El correo es obligatorio.'
  if (form.psalario === '' || Number(form.psalario) < 0) formErrors.psalario = 'Ingresa un salario válido.'
  if (!form.autor.trim()) formErrors.autor = formMode.value === 'create' ? 'Indica quién lo crea.' : 'Indica quién lo modifica.'
  return Object.keys(formErrors).length === 0
}

async function submitForm() {
  if (!validate()) return
  saving.value = true
  try {
    if (formMode.value === 'create') {
      await run(
        () =>
          usuarioService.crear({
            dni: form.dni.trim(),
            p_nombre: form.p_nombre.trim(),
            s_nombre: form.s_nombre.trim() || null,
            p_apellido: form.p_apellido.trim(),
            s_apellido: form.s_apellido.trim() || null,
            correo_elec: form.correo_elec.trim(),
            psalario: Number(form.psalario),
            pcreado_por: form.autor.trim(),
          }),
        { successMessage: 'Usuario creado exitosamente.' },
      )
    } else {
      await run(
        () =>
          usuarioService.actualizar(form.dni, {
            p_nombre: form.p_nombre.trim(),
            s_nombre: form.s_nombre.trim() || null,
            p_apellido: form.p_apellido.trim(),
            s_apellido: form.s_apellido.trim() || null,
            correo_elec: form.correo_elec.trim(),
            psalario: Number(form.psalario),
            p_modificado_por: form.autor.trim(),
          }),
        { successMessage: 'Usuario actualizado exitosamente.' },
      )
    }
    showForm.value = false
    await fetchUsuarios()
  } catch {
    // el error ya se muestra vía toast + AppAlert (useCrud lo deja en `error`)
  } finally {
    saving.value = false
  }
}

// ---------- Baja lógica ----------
const deleteTarget = ref(null)
const deleting = ref(false)

function askDelete(u) {
  deleteTarget.value = u
}

async function confirmDelete(autor) {
  deleting.value = true
  try {
    await run(() => usuarioService.eliminar(deleteTarget.value.usuario_dni, { p_modificado_por: autor }), {
      successMessage: 'Usuario dado de baja.',
    })
    deleteTarget.value = null
    await fetchUsuarios()
  } catch {
    // error ya mostrado por toast
  } finally {
    deleting.value = false
  }
}

function formatFecha(v) {
  if (!v) return '—'
  return new Date(v).toLocaleString('es', { dateStyle: 'medium', timeStyle: 'short' })
}
</script>

<template>
  <div>
    <div class="app-topbar">
      <div>
        <h2>Usuarios</h2>
        <p>CRUD sobre <code>UsuarioController</code> — identificados por DNI. La baja es lógica (PATCH).</p>
      </div>
      <button class="btn btn-primary" @click="openCreate">+ Nuevo usuario</button>
    </div>

    <AppAlert v-if="error" :message="error.message" />

    <div class="card card-pad">
      <div class="toolbar">
        <input
          v-model="search"
          class="input grow"
          placeholder="Buscar por DNI, nombre, apellido o correo..."
        />
        <button class="btn btn-secondary btn-sm" :disabled="loading" @click="fetchUsuarios">
          <span v-if="loading" class="spinner spinner-dark" /> Recargar
        </button>
      </div>

      <div v-if="loading && !usuarios.length" class="state-box">
        <span class="spinner spinner-dark" style="width: 22px; height: 22px" />
        <span>Cargando usuarios…</span>
      </div>

      <EmptyState
        v-else-if="!filtered.length"
        icon="👤"
        title="No hay usuarios"
        :message="search ? 'No hay resultados para tu búsqueda.' : 'Crea el primer usuario con el botón de arriba.'"
      />

      <div v-else class="table-wrap">
        <table class="data-table">
          <thead>
            <tr>
              <th>DNI</th>
              <th>Nombre completo</th>
              <th>Correo</th>
              <th>Salario</th>
              <th>Registrado</th>
              <th>Estado</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="u in filtered" :key="u.usuario_dni">
              <td class="cell-num">{{ u.usuario_dni }}</td>
              <td>{{ [u.primer_nombre, u.segundo_nombre, u.primer_apellido, u.segundo_apellido].filter(Boolean).join(' ') }}</td>
              <td class="cell-muted">{{ u.email }}</td>
              <td class="cell-num">{{ Number(u.salario).toLocaleString('es', { style: 'currency', currency: 'USD' }) }}</td>
              <td class="cell-muted">{{ formatFecha(u.fecha_registro) }}</td>
              <td><StatusBadge :label="u.estado ? 'Activo' : 'Inactivo'" /></td>
              <td>
                <div class="cell-actions">
                  <RouterLink class="btn btn-secondary btn-sm" :to="{ path: '/presupuestos', query: { usuario: u.usuario_dni } }">Presupuestos</RouterLink>
                  <RouterLink class="btn btn-secondary btn-sm" :to="{ path: '/obligaciones', query: { usuario: u.usuario_dni } }">Obligaciones</RouterLink>
                  <button class="btn btn-secondary btn-sm" @click="openEdit(u)">Editar</button>
                  <button class="btn btn-danger btn-sm" :disabled="!u.estado" @click="askDelete(u)">Dar de baja</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Crear / editar -->
    <AppModal
      v-if="showForm"
      :title="formMode === 'create' ? 'Nuevo usuario' : `Editar usuario ${form.dni}`"
      subtitle="Los campos marcados son obligatorios según CrearUsuarioRequest / ActualizarUsuarioRequest."
      @close="showForm = false"
    >
      <form class="form-grid" @submit.prevent="submitForm">
        <div class="field">
          <label>DNI</label>
          <input v-model="form.dni" class="input" :class="{ invalid: formErrors.dni }" maxlength="18" :disabled="formMode === 'edit'" />
          <span class="field-error" v-if="formErrors.dni">{{ formErrors.dni }}</span>
        </div>
        <div class="field">
          <label>Correo electrónico</label>
          <input v-model="form.correo_elec" type="email" class="input" :class="{ invalid: formErrors.correo_elec }" maxlength="50" />
          <span class="field-error" v-if="formErrors.correo_elec">{{ formErrors.correo_elec }}</span>
        </div>

        <div class="field">
          <label>Primer nombre</label>
          <input v-model="form.p_nombre" class="input" :class="{ invalid: formErrors.p_nombre }" maxlength="20" />
          <span class="field-error" v-if="formErrors.p_nombre">{{ formErrors.p_nombre }}</span>
        </div>
        <div class="field">
          <label>Segundo nombre <span class="optional">(opcional)</span></label>
          <input v-model="form.s_nombre" class="input" maxlength="20" />
        </div>

        <div class="field">
          <label>Primer apellido</label>
          <input v-model="form.p_apellido" class="input" :class="{ invalid: formErrors.p_apellido }" maxlength="20" />
          <span class="field-error" v-if="formErrors.p_apellido">{{ formErrors.p_apellido }}</span>
        </div>
        <div class="field">
          <label>Segundo apellido <span class="optional">(opcional)</span></label>
          <input v-model="form.s_apellido" class="input" maxlength="20" />
        </div>

        <div class="field">
          <label>Salario</label>
          <input v-model="form.psalario" type="number" step="0.01" min="0" class="input" :class="{ invalid: formErrors.psalario }" />
          <span class="field-error" v-if="formErrors.psalario">{{ formErrors.psalario }}</span>
        </div>
        <div class="field">
          <label>{{ formMode === 'create' ? 'Creado por' : 'Modificado por' }}</label>
          <input v-model="form.autor" class="input" :class="{ invalid: formErrors.autor }" maxlength="100" />
          <span class="field-error" v-if="formErrors.autor">{{ formErrors.autor }}</span>
        </div>
      </form>

      <template #footer>
        <button type="button" class="btn btn-secondary" @click="showForm = false">Cancelar</button>
        <button type="button" class="btn btn-primary" :disabled="saving" @click="submitForm">
          <span v-if="saving" class="spinner" /> Guardar
        </button>
      </template>
    </AppModal>

    <!-- Baja lógica -->
    <ConfirmDialog
      v-if="deleteTarget"
      title="Dar de baja usuario"
      :message="`Se marcará como inactivo al usuario ${deleteTarget.usuario_dni} (${deleteTarget.primer_nombre} ${deleteTarget.primer_apellido}).`"
      confirm-label="Dar de baja"
      require-input
      input-label="Modificado por"
      :loading="deleting"
      @confirm="confirmDelete"
      @cancel="deleteTarget = null"
    />
  </div>
</template>
