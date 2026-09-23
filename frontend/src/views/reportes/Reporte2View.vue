<script setup>
import { computed, reactive, ref } from 'vue'
import { Doughnut } from 'vue-chartjs'
import '@/utils/chartSetup'
import { CHART_COLORS } from '@/utils/chartSetup'
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

const filtros = reactive({ dni: '', mes: mesActualStr() })
const loading = ref(false)
const error = ref(null)
const filas = ref([])
const consultado = ref(false)
const chartRef = ref(null)

function money(v) {
  return Number(v ?? 0).toLocaleString('es', { style: 'currency', currency: 'USD' })
}

async function consultar() {
  if (!filtros.dni.trim()) {
    error.value = 'Ingresa el DNI del usuario.'
    return
  }
  const [anio, mes] = filtros.mes.split('-').map(Number)

  loading.value = true
  error.value = null
  try {
    filas.value = await reporteService.distribucionGastos({ dni: filtros.dni.trim(), p_anio: anio, p_mes: mes })
    consultado.value = true
  } catch (e) {
    error.value = e.message
    filas.value = []
  } finally {
    loading.value = false
  }
}

const chartData = computed(() => ({
  labels: filas.value.map((f) => f.nombre_categoria),
  datasets: [
    {
      backgroundColor: filas.value.map((_, i) => CHART_COLORS[i % CHART_COLORS.length]),
      data: filas.value.map((f) => Number(f.monto_total ?? 0)),
    },
  ],
}))

const chartOptions = { responsive: true, plugins: { legend: { position: 'bottom' } } }

function exportar() {
  const canvas = chartRef.value?.chart?.canvas
  exportReportePdf({
    titulo: 'Distribución de Gastos por Categoría',
    subtitulo: `Usuario ${filtros.dni} · ${filtros.mes}`,
    chartCanvas: canvas,
    columnas: ['Categoría', 'Monto gastado', '% del total', 'N° transacciones'],
    filas: filas.value.map((f) => [
      f.nombre_categoria,
      money(f.monto_total),
      `${Number(f.porcentaje ?? 0).toFixed(1)}%`,
      f.conteo_transacciones,
    ]),
    nombreArchivo: 'distribucion-gastos.pdf',
  })
  toast.success('PDF generado.')
}
</script>

<template>
  <div>
    <div class="app-topbar">
      <div>
        <h2>Distribución de gastos por categoría</h2>
        <p>Identifica en qué categorías generales se concentra tu gasto en un mes específico.</p>
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
        <button class="btn btn-primary" style="align-self: flex-end" :disabled="loading" @click="consultar">
          <span v-if="loading" class="spinner" /> Consultar
        </button>
      </div>
    </div>

    <AppAlert v-if="error" :message="error" />

    <template v-if="consultado && !loading">
      <EmptyState v-if="!filas.length" icon="🥧" message="No hay gastos registrados en el mes seleccionado." />
      <template v-else>
        <div class="summary-grid" style="grid-template-columns: 1fr 1.3fr; gap: 18px; align-items: start">
          <div class="card card-pad" style="max-width: 380px; margin: 0 auto">
            <Doughnut ref="chartRef" :data="chartData" :options="chartOptions" />
          </div>

          <div class="card card-pad">
            <div class="table-wrap">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Categoría</th>
                    <th>Monto</th>
                    <th>%</th>
                    <th>Transacciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(f, i) in filas" :key="i">
                    <td>
                      <span
                        style="display: inline-block; width: 9px; height: 9px; border-radius: 50%; margin-right: 6px"
                        :style="{ background: CHART_COLORS[i % CHART_COLORS.length] }"
                      />{{ f.nombre_categoria }}
                    </td>
                    <td class="cell-num">{{ money(f.monto_total) }}</td>
                    <td class="cell-num">{{ Number(f.porcentaje ?? 0).toFixed(1) }}%</td>
                    <td class="cell-num">{{ f.conteo_transacciones }}</td>
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
