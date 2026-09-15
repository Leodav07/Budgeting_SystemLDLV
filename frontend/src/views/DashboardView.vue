<script setup>
const modules = [
  {
    to: '/usuarios',
    icon: '👤',
    title: 'Usuarios',
    desc: 'Alta, edición y baja lógica de usuarios del sistema.',
  },
  {
    to: '/categorias',
    icon: '🗂️',
    title: 'Categorías',
    desc: 'Categorías de ingreso, gasto y ahorro.',
  },
  {
    to: '/subcategorias',
    icon: '🏷️',
    title: 'Subcategorías',
    desc: 'Subcategorías agrupadas por categoría.',
  },
  {
    to: '/presupuestos',
    icon: '📅',
    title: 'Presupuestos',
    desc: 'Presupuestos mensuales por usuario.',
  },
  {
    to: '/presupuestos-detalles',
    icon: '🧾',
    title: 'Detalles de presupuesto',
    desc: 'Montos asignados por subcategoría dentro de un presupuesto.',
  },
  {
    to: '/obligaciones',
    icon: '📌',
    title: 'Obligaciones fijas',
    desc: 'Pagos recurrentes asociados a un usuario.',
  },
  {
    to: '/transacciones',
    icon: '💸',
    title: 'Transacciones',
    desc: 'Movimientos de ingreso, gasto y ahorro dentro de un presupuesto.',
  },
]
</script>

<template>
  <div>
    <div class="app-topbar">
      <div>
        <h2>Sistema de Presupuesto Personal</h2>
        <p>Frontend Vue 3 conectado al backend Javalin en <code>http://localhost:7070</code> vía el proxy de Vite.</p>
      </div>
    </div>

    <div class="summary-grid">
      <RouterLink v-for="m in modules" :key="m.to" :to="m.to" class="card summary-card">
        <div class="summary-card-icon">{{ m.icon }}</div>
        <h3>{{ m.title }}</h3>
        <p>{{ m.desc }}</p>
      </RouterLink>
    </div>
  </div>
</template>
