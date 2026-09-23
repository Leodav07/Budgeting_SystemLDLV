import { createRouter, createWebHistory } from 'vue-router'
import { useSession } from '../services/session'
import AppShell from '../layouts/AppShell.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/LoginView.vue'),
      meta: { public: true },
    },
    {
      path: '/',
      component: AppShell,
      children: [
        {
          path: '',
          name: 'dashboard',
          component: () => import('../views/DashboardView.vue'),
        },
        {
          path: 'usuarios',
          name: 'usuarios',
          component: () => import('../views/usuarios/UsuariosView.vue'),
        },
        {
          path: 'categorias',
          name: 'categorias',
          component: () => import('../views/categorias/CategoriasView.vue'),
        },
        {
          path: 'subcategorias/:idCategoria?',
          name: 'subcategorias',
          component: () => import('../views/categorias/SubcategoriasView.vue'),
          props: true,
        },
        {
          path: 'presupuestos',
          name: 'presupuestos',
          component: () => import('../views/presupuestos/PresupuestosView.vue'),
        },
        {
          path: 'presupuestos-detalles/:idPresupuesto?',
          name: 'presupuestos-detalles',
          component: () => import('../views/presupuestos/PresupuestoDetallesView.vue'),
          props: true,
        },
        {
          path: 'obligaciones',
          name: 'obligaciones',
          component: () => import('../views/obligaciones/ObligacionesView.vue'),
        },
        {
          path: 'transacciones',
          name: 'transacciones',
          component: () => import('../views/transacciones/TransaccionesView.vue'),
        },
        {
          path: 'procedimientos/registrar-transaccion',
          name: 'procedimiento-transaccion-completa',
          component: () => import('../views/procedimientos/RegistrarTransaccionCompletaView.vue'),
        },
        {
          path: 'procedimientos/crear-presupuesto',
          name: 'procedimiento-presupuesto-completo',
          component: () => import('../views/procedimientos/CrearPresupuestoCompletoView.vue'),
        },
        {
          path: 'reportes/ingresos-gastos',
          name: 'reporte-ingresos-gastos',
          component: () => import('../views/reportes/Reporte1View.vue'),
        },
        {
          path: 'reportes/distribucion-gastos',
          name: 'reporte-distribucion-gastos',
          component: () => import('../views/reportes/Reporte2View.vue'),
        },
        {
          path: 'reportes/cumplimiento-presupuesto',
          name: 'reporte-cumplimiento-presupuesto',
          component: () => import('../views/reportes/Reporte3View.vue'),
        },
        {
          path: 'reportes/estado-obligaciones',
          name: 'reporte-estado-obligaciones',
          component: () => import('../views/reportes/Reporte4View.vue'),
        },
      ],
    },
  ],
})

router.beforeEach((to) => {
  const { estaAutenticado } = useSession()
  if (!to.meta.public && !estaAutenticado.value) {
    return { path: '/login', query: { redirect: to.fullPath } }
  }
  if (to.meta.public && estaAutenticado.value) {
    return { path: '/' }
  }
  return true
})

export default router
