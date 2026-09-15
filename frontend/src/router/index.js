import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: () => import('../views/DashboardView.vue'),
    },
    {
      path: '/usuarios',
      name: 'usuarios',
      component: () => import('../views/usuarios/UsuariosView.vue'),
    },
    {
      path: '/categorias',
      name: 'categorias',
      component: () => import('../views/categorias/CategoriasView.vue'),
    },
    {
      path: '/subcategorias/:idCategoria?',
      name: 'subcategorias',
      component: () => import('../views/categorias/SubcategoriasView.vue'),
      props: true,
    },
    {
      path: '/presupuestos',
      name: 'presupuestos',
      component: () => import('../views/presupuestos/PresupuestosView.vue'),
    },
    {
      path: '/presupuestos-detalles/:idPresupuesto?',
      name: 'presupuestos-detalles',
      component: () => import('../views/presupuestos/PresupuestoDetallesView.vue'),
      props: true,
    },
    {
      path: '/obligaciones',
      name: 'obligaciones',
      component: () => import('../views/obligaciones/ObligacionesView.vue'),
    },
    {
      path: '/transacciones',
      name: 'transacciones',
      component: () => import('../views/transacciones/TransaccionesView.vue'),
    },
  ],
})

export default router
