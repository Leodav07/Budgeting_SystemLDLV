<script setup>
import { useSession } from '@/services/session'

const session = useSession()

const accesos = [
  { to: '/presupuestos', icon: '📅', title: 'Presupuestos', desc: 'Crea y gestiona tus presupuestos mensuales por período.' },
  { to: '/transacciones', icon: '💸', title: 'Transacciones', desc: 'Registra tus ingresos, gastos y ahorros.' },
  { to: '/obligaciones', icon: '📌', title: 'Obligaciones fijas', desc: 'Controla tus pagos recurrentes y sus vencimientos.' },
  { to: '/reportes/ingresos-gastos', icon: '📊', title: 'Reportes', desc: 'Analiza tu situación financiera con gráficos claros.' },
]

const pilares = [
  { icon: '🎯', title: 'Planifica', desc: 'Define cuánto quieres destinar a cada categoría de gasto o ahorro, mes a mes.' },
  { icon: '🔍', title: 'Controla', desc: 'Registra cada movimiento y compáralo en tiempo real contra lo presupuestado.' },
  { icon: '📈', title: 'Analiza', desc: 'Visualiza tendencias y exporta reportes para tomar mejores decisiones.' },
]
</script>

<template>
  <div>
    <div class="dashboard-hero">
      <div>
        <h2>Hola{{ session.nombre.value ? `, ${session.nombre.value}` : '' }} 👋</h2>
        <p>
          Bienvenido a tu Sistema de Presupuesto Personal: la herramienta para planificar tus ingresos, controlar
          tus gastos y alcanzar tus metas de ahorro, todo en un solo lugar.
        </p>
      </div>
    </div>

    <div class="summary-grid" style="margin-bottom: 28px">
      <div v-for="p in pilares" :key="p.title" class="card card-pad">
        <div class="summary-card-icon">{{ p.icon }}</div>
        <h3>{{ p.title }}</h3>
        <p>{{ p.desc }}</p>
      </div>
    </div>

    <h3 style="margin-bottom: 12px">Accesos rápidos</h3>
    <div class="summary-grid">
      <RouterLink v-for="m in accesos" :key="m.to" :to="m.to" class="card summary-card">
        <div class="summary-card-icon">{{ m.icon }}</div>
        <h3>{{ m.title }}</h3>
        <p>{{ m.desc }}</p>
      </RouterLink>
    </div>
  </div>
</template>

<style scoped>
.dashboard-hero {
  background: linear-gradient(135deg, var(--color-primary-soft) 0%, var(--color-success-soft) 100%);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 28px 30px;
  margin-bottom: 26px;
}

.dashboard-hero h2 {
  font-size: 24px;
  margin-bottom: 8px;
}

.dashboard-hero p {
  color: var(--color-text);
  max-width: 620px;
  font-size: 14.5px;
}
</style>
