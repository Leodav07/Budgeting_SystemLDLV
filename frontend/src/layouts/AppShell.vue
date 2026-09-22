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

const nav = [
  { to: '/', label: 'Resumen', icon: '🏠' },
  { to: '/usuarios', label: 'Usuarios', icon: '👤' },
  { to: '/categorias', label: 'Categorías', icon: '🗂️' },
  { to: '/subcategorias', label: 'Subcategorías', icon: '🏷️' },
  { to: '/presupuestos', label: 'Presupuestos', icon: '📅' },
  { to: '/presupuestos-detalles', label: 'Detalles de presupuesto', icon: '🧾' },
  { to: '/obligaciones', label: 'Obligaciones fijas', icon: '📌' },
  { to: '/transacciones', label: 'Transacciones', icon: '💸' },
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
        <span class="app-nav-label">Gestión</span>
        <RouterLink
          v-for="item in nav"
          :key="item.to"
          :to="item.to"
          @click="sidebarOpen = false"
        >
          <span class="nav-icon">{{ item.icon }}</span>
          {{ item.label }}
        </RouterLink>
      </nav>

      <div class="app-session">
        <span class="cell-muted">Sesión: <strong>{{ session.dni.value }}</strong></span>
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
.app-session {
  margin-top: auto;
  padding-top: 14px;
  border-top: 1px solid var(--color-border);
  display: flex;
  flex-direction: column;
  gap: 8px;
  font-size: 13px;
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
