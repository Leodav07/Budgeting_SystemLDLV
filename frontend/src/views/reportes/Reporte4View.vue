<script setup>
import { computed, reactive, ref } from 'vue'
import { Doughnut } from 'vue-chartjs'
import '@/utils/chartSetup'
import { reporteService } from '@/services/reporteService'
import { useToast } from '@/composables/useToast'
import AppAlert from '@/components/AppAlert.vue'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { exportReportePdf } from '@/utils/exportPdf'

const toast = useToast()

function mesActualStr() {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

const filtros = reactive({ dni: '', mes: mesActualStr(), estado: 'todos' })
const loading = ref(false)
const error = ref(null)
const filasCrudas = ref([])
const consultado = ref(false)
const chartRef = ref(null)

function money(v) {
  return Number(v ?? 0).toLocaleString('es', { style: 'currency', currency: 'USD' })
}
function fmtFecha(v) {
  if (!v) return '—'
  return new Date(v).toLocaleDateString('es', { day: '2-digit', month: 'short', year: 'numeric' })
}

// El backend solo distingue Pagado/Pendiente/Vencido; para el semáforo de 4 colores
// que pide el reporte, subdividimos "Pendiente" en "Pendiente" vs "Por vencer" (<3 días).
function estadoVisual(f) {
  if (f.estado === 'Pagado') return { label: 'Pagada', tone: 'success' }
  if (f.estado === 'Vencido') return { label: 'Vencida', tone: 'danger' }
  if (f.dias_restantes < 3) return { label: 'Por vencer', tone: 'warning' }
  return { label: 'Pendiente', tone: 'info' }
}

const filas = computed(() => {
  const conVisual = filasCrudas.value.map((f) => ({ ...f, visual: estadoVisual(f) }))
  if (filtros.estado === 'todos') return conVisual
  const map = { pagadas: 'Pagado', pendientes: 'Pendiente', vencidas: 'Vencido' }
  return conVisual.filter((f) => f.estado === map[filtros.estado])
})

async function consultar() {
  if (!filtros.dni.trim()) {
    error.value = 'Ingresa el DNI del usuario.'
    return
  }
  const [anio, mes] = filtros.mes.split('-').map(Number)

  loading.value = true
  error.value = null
  try {
    filasCrudas.value = await reporteService.estadoObligaciones({ dni: filtros.dni.trim(), p_anio: anio, p_mes: mes })
    consultado.value = true
  } catch (e) {
    error.value = e.message
    filasCrudas.value = []
  } finally {
    loading.value = false
  }
}

const resumen = computed(() => {
  const total = filasCrudas.value.length
  const pagadas = filasCrudas.value.filter((f) => f.estado === 'Pagado').length
  const vencidas = filasCrudas.value.filter((f) => f.estado === 'Vencido').length
  const pendientes = total - pagadas - vencidas
  return { total, pagadas, vencidas, pendientes }
})

const chartData = computed(() => ({
  labels: ['Pagadas', 'Pendientes', 'Vencidas'],
  datasets: [
    {
      backgroundColor: ['#059669', '#0284c7', '#dc2626'],
      data: [resumen.value.pagadas, resumen.value.pendientes, resumen.value.vencidas],
    },
  ],
}))
const chartOptions = { responsive: true, plugins: { legend: { position: 'bottom' } } }

function exportar() {
  const canvas = chartRef.value?.chart?.canvas
  exportReportePdf({
    titulo: 'Estado de Obligaciones Fijas',
    subtitulo: `Usuario ${filtros.dni} · ${filtros.mes}`,
    chartCanvas: canvas,
    columnas: ['Obligación', 'Monto', 'Vence (día)', 'Estado', 'Último pago'],
    filas: filas.value.map((f) => [f.nombre_obligacion, money(f.monto_fijo), f.vence_dia, f.visual.label, fmtFecha(f.fecha_ultimo_pago)]),
    nombreArchivo: 'estado-obligaciones.pdf',
  })
  toast.success('PDF generado.')
}
</script>

<template>
  <div>
    <div class="app-topbar">
      <div>
        <h2>Estado de obligaciones fijas</h2>
        <p>Monitorea el cumplimiento de pago de tus obligaciones recurrentes y evita cargos por mora.</p>
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
          <label>Mes</label>
          <input v-model="filtros.mes" type="month" class="input" />
        </div>
        <div class="field">
          <label>Estado</label>
          <select v-model="filtros.estado" class="input">
            <option value="todos">Todas</option>
            <option value="pagadas">Pagadas</option>
            <option value="pendientes">Pendientes</option>
            <option value="vencidas">Vencidas</option>
          </select>
        </div>
        <button class="btn btn-primary" style="align-self: flex-end" :disabled="loading" @click="consultar">
          <span v-if="loading" class="spinner" /> Consultar
        </button>
      </div>
    </div>

    <AppAlert v-if="error" :message="error" />

    <template v-if="consultado && !loading">
      <EmptyState v-if="!filasCrudas.length" icon="📌" message="Este usuario no tiene obligaciones activas ese mes." />
      <template v-else>
        <div class="summary-grid" style="grid-template-columns: 1fr 1.3fr; gap: 18px; align-items: start">
          <div class="card card-pad" style="max-width: 340px; margin: 0 auto">
            <Doughnut ref="chartRef" :data="chartData" :options="chartOptions" />
            <div class="summary-grid" style="grid-template-columns: repeat(3, 1fr); margin-top: 14px; text-align: center">
              <div><strong>{{ resumen.pagadas }}</strong><br /><span class="cell-muted">Pagadas</span></div>
              <div><strong>{{ resumen.pendientes }}</strong><br /><span class="cell-muted">Pendientes</span></div>
              <div><strong>{{ resumen.vencidas }}</strong><br /><span class="cell-muted">Vencidas</span></div>
            </div>
          </div>

          <div class="card card-pad">
            <div class="table-wrap">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Obligación</th>
                    <th>Monto</th>
                    <th>Vence (día)</th>
                    <th>Días</th>
                    <th>Estado</th>
                    <th>Último pago</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="f in filas" :key="f.id_obligacion">
                    <td>{{ f.nombre_obligacion }}</td>
                    <td class="cell-num">{{ money(f.monto_fijo) }}</td>
                    <td class="cell-num">{{ f.vence_dia }}</td>
                    <td class="cell-num">{{ f.dias_restantes }}</td>
                    <td><StatusBadge :label="f.visual.label" :tone="f.visual.tone" /></td>
                    <td class="cell-muted">{{ fmtFecha(f.fecha_ultimo_pago) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </template>
    </template>

    <EmptyState v-else-if="!loading" icon="📅" message="Ingresa un usuario y un mes para generar el reporte." />
  </div>
</template>
