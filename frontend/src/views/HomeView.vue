<script setup>
import { reactive, ref } from 'vue'

const vista = ref('crear')
const cargando = ref(false)
const resultado = ref(null)
const consultaDni = ref('')
const usuarioConsultado = ref(null)
const usuarios = ref([])

const crear = reactive({ dni: '', p_nombre: '', s_nombre: '', p_apellido: '', s_apellido: '', correo_elec: '', psalario: '', pcreado_por: 'usuario-demo' })
const actualizar = reactive({ dni: '', p_nombre: '', s_nombre: '', p_apellido: '', s_apellido: '', correo_elec: '', psalario: '', p_modificado_por: 'usuario-demo' })
const eliminar = reactive({ dni: '', p_modificado_por: 'usuario-demo' })

const titulos = {
  crear: ['Registrar usuario', 'Crea un usuario y prueba el procedimiento de inserción.', 'POST /api/usuarios'],
  actualizar: ['Actualizar usuario', 'Modifica los datos de un usuario existente usando su DNI.', 'PUT /api/usuarios/{dni}'],
  consultar: ['Consultar por DNI', 'Busca un usuario específico y revisa los datos devueltos.', 'GET /api/usuarios/{dni}'],
  listar: ['Listar usuarios', 'Obtén todos los usuarios registrados en la base de datos.', 'GET /api/usuarios'],
  eliminar: ['Desactivar usuario', 'Prueba la eliminación lógica; el usuario se marca como inactivo.', 'PATCH /api/usuarios/{dni}'],
}

function normalizar(formulario, actor) {
  return {
    p_nombre: formulario.p_nombre.trim(),
    s_nombre: formulario.s_nombre.trim() || null,
    p_apellido: formulario.p_apellido.trim(),
    s_apellido: formulario.s_apellido.trim() || null,
    correo_elec: formulario.correo_elec.trim(),
    psalario: Number(formulario.psalario),
    [actor]: formulario[actor].trim(),
  }
}

async function pedir(url, options = {}) {
  const respuesta = await fetch(url, options)
  const texto = await respuesta.text()
  let datos = {}
  try { datos = texto ? JSON.parse(texto) : {} } catch { datos = { mensaje: texto } }
  if (!respuesta.ok) throw new Error(datos.mensaje || `La API respondió con estado ${respuesta.status}.`)
  return datos
}

async function ejecutar(url, method, body, mensaje) {
  resultado.value = null
  cargando.value = true
  try {
    const datos = await pedir(url, { method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
    resultado.value = { tipo: 'exito', mensaje: datos.mensaje || mensaje }
  } catch (error) {
    resultado.value = { tipo: 'error', mensaje: error.message || 'No fue posible conectar con el backend.' }
  } finally { cargando.value = false }
}

function registrar() { ejecutar('/api/usuarios', 'POST', { dni: crear.dni.trim(), ...normalizar(crear, 'pcreado_por') }, 'Usuario creado correctamente.') }
function modificar() { ejecutar(`/api/usuarios/${encodeURIComponent(actualizar.dni.trim())}`, 'PUT', normalizar(actualizar, 'p_modificado_por'), 'Usuario actualizado correctamente.') }
function desactivar() { ejecutar(`/api/usuarios/${encodeURIComponent(eliminar.dni.trim())}`, 'PATCH', { p_modificado_por: eliminar.p_modificado_por.trim() }, 'Usuario desactivado correctamente.') }

async function consultar() {
  usuarioConsultado.value = null; resultado.value = null; cargando.value = true
  try { usuarioConsultado.value = await pedir(`/api/usuarios/${encodeURIComponent(consultaDni.value.trim())}`) }
  catch (error) { resultado.value = { tipo: 'error', mensaje: error.message || 'No fue posible consultar el usuario.' } }
  finally { cargando.value = false }
}

async function listar() {
  usuarios.value = []; resultado.value = null; cargando.value = true
  try { usuarios.value = await pedir('/api/usuarios') }
  catch (error) { resultado.value = { tipo: 'error', mensaje: error.message || 'No fue posible listar usuarios.' } }
  finally { cargando.value = false }
}

function cambiarVista(nuevaVista) {
  vista.value = nuevaVista; resultado.value = null; usuarioConsultado.value = null
  if (nuevaVista === 'listar') listar()
}

function nombreCompleto(usuario) { return [usuario.primer_nombre, usuario.segundo_nombre, usuario.primer_apellido, usuario.segundo_apellido].filter(Boolean).join(' ') || usuario.nombre_completo || '—' }
function dinero(valor) { return valor == null ? '—' : new Intl.NumberFormat('es-HN', { style: 'currency', currency: 'HNL' }).format(valor) }
</script>

<template>
  <main class="app-shell">
    <aside class="sidebar">
      <div class="brand"><b>$</b><div><strong>Budget Lab</strong><small>Pruebas de API</small></div></div>
      <nav aria-label="CRUD de usuarios">
        <p>CRUD DE USUARIOS</p>
        <button :class="{ activo: vista === 'crear' }" @click="cambiarVista('crear')">＋ <span>Registrar usuario</span></button>
        <button :class="{ activo: vista === 'actualizar' }" @click="cambiarVista('actualizar')">✎ <span>Actualizar usuario</span></button>
        <button :class="{ activo: vista === 'consultar' }" @click="cambiarVista('consultar')">⌕ <span>Consultar por DNI</span></button>
        <button :class="{ activo: vista === 'listar' }" @click="cambiarVista('listar')">☷ <span>Listar usuarios</span></button>
        <button :class="{ activo: vista === 'eliminar' }" @click="cambiarVista('eliminar')">⊘ <span>Desactivar usuario</span></button>
      </nav>
      <div class="api-status"><i></i> API local · puerto 7070</div>
    </aside>

    <section class="contenido">
      <header>
        <div><p class="sobrelinea">Módulo de usuarios</p><h1>{{ titulos[vista][0] }}</h1><p class="subtitulo">{{ titulos[vista][1] }}</p></div>
        <code class="endpoint">{{ titulos[vista][2] }}</code>
      </header>

      <section class="panel">
        <form v-if="vista === 'crear'" @submit.prevent="registrar">
          <h2>Datos de identificación</h2><p class="ayuda">Los campos con asterisco son obligatorios.</p>
          <div class="campos">
            <label>DNI <em>*</em><input v-model.trim="crear.dni" required maxlength="18" /></label>
            <label>Correo electrónico <em>*</em><input v-model.trim="crear.correo_elec" required type="email" maxlength="50" /></label>
            <label>Primer nombre <em>*</em><input v-model.trim="crear.p_nombre" required maxlength="20" /></label>
            <label>Segundo nombre<input v-model="crear.s_nombre" maxlength="20" /></label>
            <label>Primer apellido <em>*</em><input v-model.trim="crear.p_apellido" required maxlength="20" /></label>
            <label>Segundo apellido<input v-model="crear.s_apellido" maxlength="20" /></label>
            <label>Salario <em>*</em><input v-model="crear.psalario" required type="number" min="0" max="999999.99" step="0.01" /><small>Máximo: 999,999.99</small></label>
            <label>Creado por <em>*</em><input v-model.trim="crear.pcreado_por" required maxlength="100" /></label>
          </div>
          <button class="accion crear" :disabled="cargando">{{ cargando ? 'Enviando…' : 'Registrar usuario' }} <b>→</b></button>
        </form>

        <form v-else-if="vista === 'actualizar'" @submit.prevent="modificar">
          <div class="aviso"><b>i</b> El DNI identifica el usuario y se envía en la URL.</div>
          <h2>Datos actualizados</h2><p class="ayuda">Todos los campos se enviarán al procedimiento de actualización.</p>
          <div class="campos">
            <label>DNI del usuario <em>*</em><input v-model.trim="actualizar.dni" required maxlength="18" /></label>
            <label>Correo electrónico <em>*</em><input v-model.trim="actualizar.correo_elec" required type="email" maxlength="50" /></label>
            <label>Primer nombre <em>*</em><input v-model.trim="actualizar.p_nombre" required maxlength="20" /></label>
            <label>Segundo nombre<input v-model="actualizar.s_nombre" maxlength="20" /></label>
            <label>Primer apellido <em>*</em><input v-model.trim="actualizar.p_apellido" required maxlength="20" /></label>
            <label>Segundo apellido<input v-model="actualizar.s_apellido" maxlength="20" /></label>
            <label>Salario <em>*</em><input v-model="actualizar.psalario" required type="number" min="0" max="999999.99" step="0.01" /></label>
            <label>Modificado por <em>*</em><input v-model.trim="actualizar.p_modificado_por" required maxlength="100" /></label>
          </div>
          <button class="accion actualizar" :disabled="cargando">{{ cargando ? 'Actualizando…' : 'Actualizar usuario' }} <b>→</b></button>
        </form>

        <form v-else-if="vista === 'consultar'" class="buscador" @submit.prevent="consultar">
          <h2>Buscar usuario</h2><p class="ayuda">Ingresa el DNI exacto del usuario que deseas consultar.</p>
          <div class="linea-busqueda"><input v-model.trim="consultaDni" required maxlength="18" placeholder="DNI del usuario" /><button class="accion consulta" :disabled="cargando">{{ cargando ? 'Buscando…' : 'Consultar' }}</button></div>
          <article v-if="usuarioConsultado" class="ficha-usuario">
            <div class="avatar">{{ (usuarioConsultado.primer_nombre || usuarioConsultado.nombre_completo || 'U').charAt(0).toUpperCase() }}</div>
            <div><p class="dni">{{ usuarioConsultado.usuario_dni }}</p><h3>{{ nombreCompleto(usuarioConsultado) }}</h3><p>{{ usuarioConsultado.email || 'Sin correo disponible' }}</p></div>
            <dl><div><dt>Salario</dt><dd>{{ dinero(usuarioConsultado.salario) }}</dd></div><div><dt>Registro</dt><dd>{{ usuarioConsultado.fecha_registro || '—' }}</dd></div><div><dt>Estado</dt><dd><span class="estado" :class="usuarioConsultado.estado ? 'activo' : 'inactivo'">{{ usuarioConsultado.estado ? 'Activo' : 'Inactivo' }}</span></dd></div></dl>
          </article>
        </form>

        <section v-else-if="vista === 'listar'">
          <div class="lista-head"><div><h2>Usuarios registrados</h2><p class="ayuda">{{ cargando ? 'Consultando la API…' : `${usuarios.length} usuario(s) encontrado(s)` }}</p></div><button class="boton-secundario" :disabled="cargando" @click="listar">↻ Actualizar lista</button></div>
          <div class="tabla-wrap"><table><thead><tr><th>DNI</th><th>Nombre</th><th>Correo</th><th>Salario</th><th>Estado</th></tr></thead><tbody><tr v-if="!cargando && !usuarios.length"><td colspan="5" class="vacio">No hay usuarios para mostrar.</td></tr><tr v-for="usuario in usuarios" :key="usuario.usuario_dni"><td>{{ usuario.usuario_dni }}</td><td>{{ nombreCompleto(usuario) }}</td><td>{{ usuario.email || '—' }}</td><td>{{ dinero(usuario.salario) }}</td><td><span class="estado" :class="usuario.estado ? 'activo' : 'inactivo'">{{ usuario.estado ? 'Activo' : 'Inactivo' }}</span></td></tr></tbody></table></div>
        </section>

        <form v-else class="eliminar" @submit.prevent="desactivar">
          <div class="advertencia"><b>!</b><div><h2>Desactivar usuario</h2><p>Esta acción usa eliminación lógica: el registro permanece en la base, pero su estado pasa a inactivo.</p></div></div>
          <div class="campos dos"><label>DNI del usuario <em>*</em><input v-model.trim="eliminar.dni" required maxlength="18" /></label><label>Modificado por <em>*</em><input v-model.trim="eliminar.p_modificado_por" required maxlength="100" /></label></div>
          <button class="accion peligro" :disabled="cargando">{{ cargando ? 'Desactivando…' : 'Desactivar usuario' }} <b>→</b></button>
        </form>

        <div v-if="resultado" class="resultado" :class="resultado.tipo"><b>{{ resultado.tipo === 'exito' ? '✓' : '!' }}</b><p>{{ resultado.mensaje }}</p></div>
      </section>
    </section>
  </main>
</template>

<style scoped>
.app-shell{min-height:100vh;display:grid;grid-template-columns:250px 1fr;background:#f4f7fb;color:#233044}.sidebar{display:flex;flex-direction:column;min-height:100vh;padding:28px 16px;background:#16293b;color:#dce8f1}.brand{display:flex;gap:11px;align-items:center;padding:0 10px 34px}.brand>b{display:grid;place-items:center;width:36px;height:36px;border-radius:10px;background:#31bd8a;color:#093c2d;font-size:20px}.brand strong,.brand small{display:block}.brand strong{font-size:16px}.brand small{color:#9eafbe;font-size:12px}.sidebar nav p{margin:0 10px 9px;color:#8ea0b1;font-size:11px;font-weight:800;letter-spacing:.08em}.sidebar button{display:flex;gap:10px;align-items:center;width:100%;margin:4px 0;padding:11px 10px;border:0;border-radius:8px;background:transparent;color:#c4d2dd;font:inherit;text-align:left;cursor:pointer}.sidebar button:first-letter{font-size:18px}.sidebar button:hover{background:#203a50}.sidebar button.activo{background:#245d46;color:#fff;font-weight:700}.api-status{display:flex;gap:8px;align-items:center;margin:auto 10px 0;color:#9eafbe;font-size:12px}.api-status i{width:8px;height:8px;border-radius:50%;background:#35d49a}.contenido{width:min(1100px,100%);margin:auto;padding:50px clamp(20px,5vw,65px)}header{display:flex;justify-content:space-between;gap:24px;align-items:flex-start;margin-bottom:30px}.sobrelinea{margin:0 0 8px;color:#168760;font-size:12px;font-weight:800;letter-spacing:.08em;text-transform:uppercase}h1{margin:0;color:#17263a;font-size:clamp(29px,4vw,38px);letter-spacing:-.04em}.subtitulo{margin:10px 0 0;color:#627188}.endpoint{padding:8px 11px;border:1px solid #d8e1ea;border-radius:7px;background:#fff;color:#247355;font:12px ui-monospace,monospace;white-space:nowrap}.panel{padding:clamp(24px,4vw,38px);border:1px solid #e0e6ec;border-radius:15px;background:#fff;box-shadow:0 10px 25px rgb(31 53 78 / 6%)}h2{margin:0 0 5px;font-size:18px}.ayuda{margin:0 0 24px;color:#77869a;font-size:13px}.campos{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:17px 16px}.campos.dos{margin-top:24px}label{display:grid;gap:6px;font-size:13px;font-weight:700}em{color:#d44a57;font-style:normal}input{width:100%;min-width:0;padding:10px 11px;border:1px solid #ced9e5;border-radius:7px;color:#1d2b3c;font:inherit;font-weight:400}input:focus{outline:0;border-color:#1d9c72;box-shadow:0 0 0 3px rgb(29 156 114 / 14%)}small{color:#8491a2;font-size:11px;font-weight:400}.accion{display:flex;justify-content:center;gap:12px;width:100%;margin-top:30px;padding:13px;border:0;border-radius:8px;color:#fff;font:inherit;font-weight:800;cursor:pointer}.accion.crear{background:#168760}.accion.actualizar{background:#2864ae}.accion.consulta{width:auto;margin:0;background:#2864ae}.accion.peligro{background:#c2414d}.accion:hover:not(:disabled){filter:brightness(.92)}.accion:disabled,.boton-secundario:disabled{opacity:.65;cursor:wait}.aviso{margin-bottom:24px;padding:12px;border-radius:8px;background:#f1f7ff;color:#3d638d;font-size:13px}.buscador{max-width:800px}.linea-busqueda{display:flex;gap:10px}.ficha-usuario{display:grid;grid-template-columns:auto 1fr auto;gap:15px;align-items:center;margin-top:28px;padding:21px;border:1px solid #dce6ef;border-radius:10px;background:#fbfdff}.avatar{display:grid;place-items:center;width:45px;height:45px;border-radius:50%;background:#d8f3e8;color:#126d4b;font-weight:800;font-size:19px}.dni{margin:0;color:#718096;font:12px ui-monospace,monospace}.ficha-usuario h3{margin:3px 0;font-size:17px}.ficha-usuario p{margin:0;color:#66758a;font-size:13px}dl{display:flex;gap:24px;margin:0}dt{color:#8290a1;font-size:11px}dd{margin:3px 0 0;font-size:13px;font-weight:700}.estado{display:inline-block;padding:3px 8px;border-radius:99px;font-size:11px;font-weight:800}.estado.activo{background:#dcf6e9;color:#16784f}.estado.inactivo{background:#f2e5e7;color:#a6424c}.lista-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:22px}.lista-head .ayuda{margin:0}.boton-secundario{padding:9px 11px;border:1px solid #cdd8e4;border-radius:7px;background:#fff;color:#3b556f;font:inherit;font-size:13px;font-weight:700;cursor:pointer}.tabla-wrap{overflow-x:auto;border:1px solid #e1e7ed;border-radius:9px}table{width:100%;border-collapse:collapse;font-size:13px}th,td{padding:13px 15px;border-bottom:1px solid #e9edf1;text-align:left;white-space:nowrap}th{background:#f8fafc;color:#617188;font-size:11px;text-transform:uppercase;letter-spacing:.04em}tr:last-child td{border-bottom:0}.vacio{text-align:center;color:#7a899b}.advertencia{display:flex;gap:13px;padding:18px;border:1px solid #f2c5ca;border-radius:9px;background:#fff7f7}.advertencia>b{display:grid;place-items:center;flex:none;width:24px;height:24px;border-radius:50%;background:#d14b56;color:#fff}.advertencia p{margin:5px 0 0;color:#7f5660;font-size:13px}.resultado{display:flex;gap:10px;align-items:center;margin-top:22px;padding:13px;border-radius:8px;font-size:13px}.resultado>b{display:grid;place-items:center;width:20px;height:20px;border-radius:50%;color:#fff}.resultado p{margin:0}.resultado.exito{background:#e9f8f0;color:#116842}.resultado.exito>b{background:#24a36f}.resultado.error{background:#fff0f1;color:#af3341}.resultado.error>b{background:#d94a58}@media(max-width:760px){.app-shell{display:block}.sidebar{min-height:auto;padding:18px}.brand{padding-bottom:17px}.sidebar nav{display:flex;flex-wrap:wrap;gap:5px}.sidebar nav p,.api-status{display:none}.sidebar button{width:auto;margin:0}.sidebar button span{display:none}.contenido{padding:30px 18px}header{display:block}.endpoint{display:inline-block;margin-top:16px}.campos{grid-template-columns:1fr}.linea-busqueda{display:block}.accion.consulta{width:100%;margin-top:12px}.ficha-usuario{grid-template-columns:auto 1fr}.ficha-usuario dl{grid-column:1/-1;gap:14px}.lista-head{align-items:flex-start;gap:12px}.lista-head .boton-secundario{white-space:nowrap}}
</style>
