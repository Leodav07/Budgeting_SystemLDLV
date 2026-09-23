# Frontend

Interfaz web hecha en Vue 3 (Composition API) + Vite. Consume la API del backend (`http://localhost:7070`) y no contiene lógica de negocio propia: solo muestra los datos y llama a los endpoints correspondientes.

## Cómo correr

```sh
npm install
npm run dev
```

Esto levanta el servidor de desarrollo. El backend debe estar corriendo en paralelo para que la app funcione.

## Estructura (`src/`)

- **`views/`** — una pantalla por ruta, organizadas en 3 módulos (visibles en el menú lateral):
  - **CRUDs**: `usuarios/`, `categorias/` (categorías y subcategorías), `presupuestos/` (presupuestos y sus detalles), `obligaciones/`, `transacciones/`. Cada una permite crear, ver, editar y eliminar/dar de baja registros.
  - **Procedimientos**: `procedimientos/RegistrarTransaccionCompletaView.vue` y `CrearPresupuestoCompletoView.vue`, pantallas dedicadas a los dos procedimientos de negocio más complejos (registrar una transacción completa, crear un presupuesto con todos sus detalles de una vez).
  - **Reportes**: `reportes/Reporte1View.vue` a `Reporte4View.vue` — ingresos vs. gastos, distribución de gastos por categoría, cumplimiento de presupuesto por categoría/subcategoría, y estado de las obligaciones fijas. Todos con gráficos (Chart.js) y exportación a PDF.
  - `LoginView.vue` y `DashboardView.vue`.
- **`layouts/AppShell.vue`** — estructura general de la app ya autenticada: menú lateral, cabecera y espacio para la sesión del usuario.
- **`router/index.js`** — define todas las rutas y protege las que requieren sesión iniciada (redirige a `/login` si no hay sesión).
- **`services/`** — funciones que llaman a la API del backend (una por entidad, más `session.js` para manejar el usuario logueado y `reporteService.js` para los reportes).
- **`composables/useCrud.js`** — lógica común reutilizada por todas las pantallas de CRUD (cargar datos, manejar errores, mostrar mensajes de éxito).
- **`utils/`** — `exportPdf.js` (genera el PDF de un reporte, incluyendo el gráfico) y `chartSetup.js` (configuración compartida de Chart.js).
- **`components/`** — piezas reutilizables de UI: modal, alertas, confirmación de eliminar, badge de estado, estado vacío, etc.
- **`stores/`** — estado global de la app (Pinia).

## Autenticación

El login se hace con DNI y contraseña contra el endpoint del backend. Mientras la sesión está activa, se muestra el nombre del usuario en la esquina inferior izquierda del menú.
