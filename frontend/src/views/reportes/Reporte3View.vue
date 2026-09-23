<script setup>
import { computed, reactive, ref } from 'vue'
import { Bar } from 'vue-chartjs'
import '@/utils/chartSetup'
import { reporteService } from '@/services/reporteService'
import { CATEGORIA_TIPOS } from '@/services/categoriaService'
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

const filtros = reactive({ dni: '', mes: mesActualStr(), tipo: 'gasto', idPresupuesto: '' })
const loading = ref(false)
const error = ref(null)
const filas = ref([])
const consultado = ref(false)
const chartRef = ref(null)

function money(v) {
  return Number(v ?? 0).toLocaleString('es', { style: 'currency', currency: 'USD' })
}

function estadoTone(pct) {
  if (pct > 100) return 'danger'
  if (pct >= 80) return 'warning'
  return 'success'
}
function estadoLabel(pct) {
  if (pct > 100) return 'Excedido'
  if (pct >= 80) return 'Por agotarse'
  return 'Dentro del presupuesto'
}

async function consultar() {
  if (!filtros.dni.trim() || !filtros.idPresupuesto) {
    error.value = 'Ingresa el DNI del usuario y el ID del presupuesto.'
    return
  }
  const [anio, mes] = filtros.mes.split('-').map(Number)

  loading.value = true
  error.value = null
  try {
    const datos = await reporteService.analisisCumplimiento({
      dni: filtros.dni.trim(),
      p_anio: anio,
      p_mes: mes,
      p_tipo: filtros.tipo,
      p_id_presupuesto: Number(filtros.idPresupuesto),
    })
    // El backend no expone el total por categoría en este reporte; lo calculamos
    // aquí mismo sumando el monto presupuestado de las subcategorías ya traídas.
    const totalesPorCategoria = {}
    for (const f of datos) {
      totalesPorCategoria[f.id_categoria] = (totalesPorCategoria[f.id_categoria] || 0) + Number(f.monto_presupuestado ?? 0)
    }
    filas.value = datos.map((f) => ({
      ...f,
      porcentaje: Number(f.monto_presupuestado) > 0 ? (Number(f.monto_gastado) / Number(f.monto_presupuestado)) * 100 : 0,
      total_categoria: totalesPorCategoria[f.id_categoria],
    }))
    consultado.value = true
  } catch (e) {
    error.value = e.message
    filas.value = []
  } finally {
    loading.value = false
  }
}

const chartData = computed(() => ({
  labels: filas.value.map((f) => f.nombre_subcategoria),
  datasets: [
    { label: 'Presupuestado', backgroundColor: '#4f46e5', data: filas.value.map((f) => Number(f.monto_presupuestado ?? 0)) },
    { label: 'Gastado', backgroundColor: '#dc2626', data: filas.value.map((f) => Number(f.monto_gastado ?? 0)) },
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
    titulo: 'Análisis de Cumplimiento de Presupuesto',
    subtitulo: `Usuario ${filtros.dni} · Presupuesto #${filtros.idPresupuesto} · ${filtros.mes}`,
    chartCanvas: canvas,
    columnas: ['Categoría', 'Subcategoría', 'Presupuestado', 'Gastado', 'Diferencia', '% ejecución'],
    filas: filas.value.map((f) => [
      f.nombre_categoria,
      f.nombre_subcategoria,
      money(f.monto_presupuestado),
      money(f.monto_gastado),
      money(Number(f.monto_presupuestado) - Number(f.monto_gastado)),
      `${f.porcentaje.toFixed(1)}%`,
    ]),
    nombreArchivo: 'cumplimiento-presupuesto.pdf',
  })
  toast.success('PDF generado.')
}
</script>

<template>
  <div>
    <div class="app-topbar">
      <div>
        <h2>Cumplimiento de presupuesto</h2>
        <p>Compara lo presupuestado contra lo realmente gastado, por categoría y subcategoría.</p>
      </div>
      <button class="btn btn-secondary" :disabled="!filas.length" @click="exportar">📄 Exportar PDF</button>
    </div>

    <div class="card card-pad" style="margin-bottom: 18px">
      <div class="toolbar">
        <div class="field" style="min-width: 160px">
          <label>DNI del usuario</label>
          <input v-model="filtros.dni" class="input" placeholder="DNI" @keyup.enter="consultar" />
        </div>
        <div class="field" style="max-width: 140px">
          <label>ID presupuesto</label>
          <input v-model="filtros.idPresupuesto" type="number" class="input" placeholder="#" @keyup.enter="consultar" />
        </div>
        <div class="field">
          <label>Mes</label>
          <input v-model="filtros.mes" type="month" class="input" />
        </div>
        <div class="field">
          <label>Tipo de categoría</label>
          <select v-model="filtros.tipo" class="input">
            <option v-for="t in CATEGORIA_TIPOS" :key="t" :value="t">{{ t }}</option>
          </select>
        </div>
        <button class="btn btn-primary" style="align-self: flex-end" :disabled="loading" @click="consultar">
          <span v-if="loading" class="spinner" /> Consultar
        </button>
      </div>
    </div>

    <AppAlert v-if="error" :message="error" />

    <template v-if="consultado && !loading">
      <EmptyState v-if="!filas.length" icon="📈" message="No hay subcategorías presupuestadas para este filtro." />
      <template v-else>
        <div class="card card-pad" style="margin-bottom: 18px">
          <Bar ref="chartRef" :data="chartData" :options="chartOptions" />
        </div>

        <div class="card card-pad">
          <div class="table-wrap">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Categoría</th>
                  <th>Subcategoría</th>
                  <th>Presupuestado</th>
                  <th>Gastado</th>
                  <th>Diferencia</th>
                  <th>% ejecución</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(f, i) in filas" :key="i">
                  <td class="cell-muted">{{ f.nombre_categoria }} <span class="hint">(total: {{ money(f.total_categoria) }})</span></td>
                  <td>{{ f.nombre_subcategoria }}</td>
                  <td class="cell-num">{{ money(f.monto_presupuestado) }}</td>
                  <td class="cell-num">{{ money(f.monto_gastado) }}</td>
                  <td class="cell-num">{{ money(Number(f.monto_presupuestado) - Number(f.monto_gastado)) }}</td>
                  <td class="cell-num">{{ f.porcentaje.toFixed(1) }}%</td>
                  <td>
                    <StatusBadge :label="estadoLabel(f.porcentaje)" :tone="estadoTone(f.porcentaje)" />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>
    </template>

    <EmptyState v-else-if="!loading" icon="📅" message="Ingresa usuario, presupuesto y mes para generar el reporte." />
  </div>
</template>
