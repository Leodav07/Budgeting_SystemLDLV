<script setup>
import { computed, reactive, ref } from 'vue'
import { Bar } from 'vue-chartjs'
import '@/utils/chartSetup'
import { reporteService } from '@/services/reporteService'
import { useToast } from '@/composables/useToast'
import AppAlert from '@/components/AppAlert.vue'
import EmptyState from '@/components/EmptyState.vue'
import { exportReportePdf } from '@/utils/exportPdf'

const toast = useToast()

function mesActualStr() {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}
function hace6MesesStr() {
  const d = new Date()
  d.setMonth(d.getMonth() - 5)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

const filtros = reactive({
  dni: '',
  desde: hace6MesesStr(),
  hasta: mesActualStr(),
})

const loading = ref(false)
const error = ref(null)
const filas = ref([])
const consultado = ref(false)
const chartRef = ref(null)

function money(v) {
  return Number(v ?? 0).toLocaleString('es', { style: 'currency', currency: 'USD' })
}

const nombreMes = (m) => ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'][m]

async function consultar() {
  if (!filtros.dni.trim()) {
    error.value = 'Ingresa el DNI del usuario.'
    return
  }
  const [anioD, mesD] = filtros.desde.split('-').map(Number)
  const [anioH, mesH] = filtros.hasta.split('-').map(Number)

  loading.value = true
  error.value = null
  try {
    filas.value = await reporteService.ingresosGastos({
      dni: filtros.dni.trim(),
      p_anio_d: anioD,
      p_mes_d: mesD,
      p_anio_h: anioH,
      p_mes_h: mesH,
    })
    consultado.value = true
  } catch (e) {
    error.value = e.message
    filas.value = []
  } finally {
    loading.value = false
  }
}

const chartData = computed(() => ({
  labels: filas.value.map((f) => `${nombreMes(f.mes)} ${f.anio}`),
  datasets: [
    { label: 'Ingresos', backgroundColor: '#059669', data: filas.value.map((f) => Number(f.ingresos ?? 0)) },
    { label: 'Gastos', backgroundColor: '#dc2626', data: filas.value.map((f) => Number(f.gastos ?? 0)) },
  ],
}))

const chartOptions = {
  responsive: true,
  plugins: { legend: { position: 'bottom' } },
  scales: { y: { beginAtZero: true } },
}

function exportar() {
  const canvas = chartRef.value?.chart?.canvas
  exportReportePdf({
    titulo: 'Resumen Mensual de Ingresos vs Gastos',
    subtitulo: `Usuario ${filtros.dni} · ${filtros.desde} a ${filtros.hasta}`,
    chartCanvas: canvas,
    columnas: ['Mes', 'Ingresos', 'Gastos', 'Balance'],
    filas: filas.value.map((f) => [`${nombreMes(f.mes)} ${f.anio}`, money(f.ingresos), money(f.gastos), money(f.balance)]),
    nombreArchivo: 'resumen-ingresos-gastos.pdf',
  })
  toast.success('PDF generado.')
}
</script>

<template>
  <div>
    <div class="app-topbar">
      <div>
        <h2>Resumen mensual de ingresos vs. gastos</h2>
        <p>Compara cómo evolucionan tus ingresos y gastos mes a mes para identificar tendencias de ahorro o déficit.</p>
      </div>
      <button class="btn btn-secondary" :disabled="!filas.length" @click="exportar">📄 Exportar PDF</button>
    </div>

    <div class="card card-pad" style="margin-bottom: 18px">
      <div class="toolbar">
        <div class="field" style="min-width: 180px">
          <label>DNI del usuario</label>
          <input v-model="filtros.dni" class="input" placeholder="DNI" @keyup.enter="consultar" />
        </div>
        <div class="field">
          <label>Desde</label>
          <input v-model="filtros.desde" type="month" class="input" />
        </div>
        <div class="field">
          <label>Hasta</label>
          <input v-model="filtros.hasta" type="month" class="input" />
        </div>
        <button class="btn btn-primary" style="align-self: flex-end" :disabled="loading" @click="consultar">
          <span v-if="loading" class="spinner" /> Consultar
        </button>
      </div>
    </div>

    <AppAlert v-if="error" :message="error" />

    <template v-if="consultado && !loading">
      <EmptyState
        v-if="!filas.length"
        icon="📊"
        message="No hay transacciones registradas en el rango seleccionado."
      />
      <template v-else>
        <div class="card card-pad" style="margin-bottom: 18px">
          <Bar ref="chartRef" :data="chartData" :options="chartOptions" />
        </div>

        <div class="card card-pad">
          <div class="table-wrap">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Mes</th>
                  <th>Ingresos</th>
                  <th>Gastos</th>
                  <th>Balance</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(f, i) in filas" :key="i">
                  <td>{{ nombreMes(f.mes) }} {{ f.anio }}</td>
                  <td class="cell-num">{{ money(f.ingresos) }}</td>
                  <td class="cell-num">{{ money(f.gastos) }}</td>
                  <td class="cell-num" :style="{ color: f.balance >= 0 ? 'var(--color-success)' : 'var(--color-danger)' }">
                    <strong>{{ money(f.balance) }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>
    </template>

    <EmptyState v-else-if="!loading" icon="📅" message="Ingresa un usuario y un rango de meses para generar el reporte." />
  </div>
</template>
