<script setup>
import { ref } from 'vue'
import { RouterLink, RouterView, useRouter } from 'vue-router'
import { useSession } from '@/services/session'

const sidebarOpen = ref(false)
const router = useRouter()
const session = useSession()

function logout() {
  session.cerrarSesion()
  router.push('/login')
}

const dashboard = { to: '/', label: 'Inicio', icon: '🏠' }

const crudNav = [
  { to: '/usuarios', label: 'Usuarios', icon: '👤' },
  { to: '/categorias', label: 'Categorías', icon: '🗂️' },
  { to: '/subcategorias', label: 'Subcategorías', icon: '🏷️' },
  { to: '/presupuestos', label: 'Presupuestos', icon: '📅' },
  { to: '/presupuestos-detalles', label: 'Detalles de presupuesto', icon: '🧾' },
  { to: '/obligaciones', label: 'Obligaciones fijas', icon: '📌' },
  { to: '/transacciones', label: 'Transacciones', icon: '💸' },
]

const procedimientosNav = [
  { to: '/procedimientos/registrar-transaccion', label: 'Registrar transacción completa', icon: '✅' },
  { to: '/procedimientos/crear-presupuesto', label: 'Crear presupuesto completo', icon: '🧮' },
]

const reportesNav = [
  { to: '/reportes/ingresos-gastos', label: 'Ingresos vs. gastos', icon: '📊' },
  { to: '/reportes/distribucion-gastos', label: 'Distribución de gastos', icon: '🥧' },
  { to: '/reportes/cumplimiento-presupuesto', label: 'Cumplimiento de presupuesto', icon: '📈' },
  { to: '/reportes/estado-obligaciones', label: 'Estado de obligaciones', icon: '🔔' },
]
</script>

<template>
  <div class="app-shell">
    <aside class="app-sidebar" :class="{ open: sidebarOpen }">
      <div class="app-brand">
        <div class="app-brand-mark">PS</div>
        <div class="app-brand-text">
          <h1>Presupuesto Personal</h1>
          <span>Panel de administración</span>
        </div>
      </div>

      <nav class="app-nav">
        <RouterLink :to="dashboard.to" @click="sidebarOpen = false">
          <span class="nav-icon">{{ dashboard.icon }}</span>{{ dashboard.label }}
        </RouterLink>

        <span class="app-nav-label">CRUDs</span>
        <RouterLink v-for="item in crudNav" :key="item.to" :to="item.to" @click="sidebarOpen = false">
          <span class="nav-icon">{{ item.icon }}</span>{{ item.label }}
        </RouterLink>

        <span class="app-nav-label">Procedimientos</span>
        <RouterLink v-for="item in procedimientosNav" :key="item.to" :to="item.to" @click="sidebarOpen = false">
          <span class="nav-icon">{{ item.icon }}</span>{{ item.label }}
        </RouterLink>

        <span class="app-nav-label">Reportes</span>
        <RouterLink v-for="item in reportesNav" :key="item.to" :to="item.to" @click="sidebarOpen = false">
          <span class="nav-icon">{{ item.icon }}</span>{{ item.label }}
        </RouterLink>
      </nav>

      <div class="app-session">
        <div class="app-session-user">
          <div class="app-session-avatar">{{ (session.nombre.value || session.dni.value).charAt(0).toUpperCase() }}</div>
          <div class="app-session-info">
            <strong>{{ session.nombre.value || session.dni.value }}</strong>
            <span class="cell-muted">DNI {{ session.dni.value }}</span>
          </div>
        </div>
        <button type="button" class="btn btn-secondary btn-sm" @click="logout">Cerrar sesión</button>
      </div>
    </aside>

    <button
      type="button"
      class="mobile-toggle"
      aria-label="Abrir menú"
      @click="sidebarOpen = !sidebarOpen"
    >
      ☰
    </button>

    <main class="app-main">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.app-nav {
  flex: 1;
  overflow-y: auto;
  padding-right: 2px;
}

.app-session {
  margin-top: 12px;
  padding-top: 14px;
  border-top: 1px solid var(--color-border);
  display: flex;
  flex-direction: column;
  gap: 10px;
  font-size: 13px;
}

.app-session-user {
  display: flex;
  align-items: center;
  gap: 10px;
}

.app-session-avatar {
  width: 34px;
  height: 34px;
  flex-shrink: 0;
  border-radius: 50%;
  background: var(--color-primary);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 14px;
}

.app-session-info {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.app-session-info strong {
  font-size: 13.5px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.mobile-toggle {
  display: none;
  position: fixed;
  top: 14px;
  left: 14px;
  z-index: 960;
  width: 38px;
  height: 38px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  background: var(--color-surface);
  box-shadow: var(--shadow-sm);
  cursor: pointer;
}

@media (max-width: 900px) {
  .mobile-toggle {
    display: block;
  }
}
</style>
