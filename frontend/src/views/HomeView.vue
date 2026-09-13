<script setup>
import { reactive, ref } from 'vue'

const seccionActiva = ref('crear')
const enviando = ref(false)
const resultado = ref(null)

const formularioCrear = reactive({
  dni: '', p_nombre: '', s_nombre: '', p_apellido: '', s_apellido: '',
  correo_elec: '', psalario: '', pcreado_por: 'usuario-demo',
})

const formularioActualizar = reactive({
  dni: '', p_nombre: '', s_nombre: '', p_apellido: '', s_apellido: '',
  correo_elec: '', psalario: '', p_modificado_por: 'usuario-demo',
})

function datosUsuario(formulario, campoActor) {
  return {
    p_nombre: formulario.p_nombre.trim(),
    s_nombre: formulario.s_nombre.trim() || null,
    p_apellido: formulario.p_apellido.trim(),
    s_apellido: formulario.s_apellido.trim() || null,
    correo_elec: formulario.correo_elec.trim(),
    psalario: Number(formulario.psalario),
    [campoActor]: formulario[campoActor].trim(),
  }
}

async function enviar(url, method, body, mensajeExito) {
  resultado.value = null
  enviando.value = true
  try {
    const respuesta = await fetch(url, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    })
    const texto = await respuesta.text()
    let contenido = {}
    try { contenido = texto ? JSON.parse(texto) : {} } catch { contenido = { mensaje: texto } }

    if (!respuesta.ok) {
      throw new Error(contenido.mensaje || `La API respondió con estado ${respuesta.status}.`)
    }
    resultado.value = { tipo: 'exito', titulo: 'Operación completada', mensaje: contenido.mensaje || mensajeExito }
  } catch (error) {
    resultado.value = {
      tipo: 'error', titulo: 'No se pudo completar la operación',
      mensaje: error.message || 'Verifica que el backend esté ejecutándose.',
    }
  } finally {
    enviando.value = false
  }
}

function crearUsuario() {
  enviar('/api/usuarios', 'POST', {
    dni: formularioCrear.dni.trim(),
    ...datosUsuario(formularioCrear, 'pcreado_por'),
  }, 'Usuario creado correctamente.')
}

function actualizarUsuario() {
  enviar(
    `/api/usuarios/${encodeURIComponent(formularioActualizar.dni.trim())}`,
    'PUT',
    datosUsuario(formularioActualizar, 'p_modificado_por'),
    'Usuario actualizado correctamente.',
  )
}

function cambiarSeccion(seccion) {
  seccionActiva.value = seccion
  resultado.value = null
}
</script>

<template>
  <main class="app-shell">
    <aside class="barra-lateral">
      <div class="marca"><div class="marca-icono">$</div><div><strong>Budget Lab</strong><span>Pruebas de API</span></div></div>
      <nav aria-label="Operaciones de usuarios">
        <p class="nav-titulo">Usuarios</p>
        <button class="nav-item" :class="{ activo: seccionActiva === 'crear' }" type="button" @click="cambiarSeccion('crear')"><b>＋</b> Registrar usuario</button>
        <button class="nav-item" :class="{ activo: seccionActiva === 'actualizar' }" type="button" @click="cambiarSeccion('actualizar')"><b>✎</b> Actualizar usuario</button>
      </nav>
      <div class="api-info"><i></i> API local · puerto 7070</div>
    </aside>

    <section class="contenido">
      <header class="encabezado">
        <div>
          <p class="sobrelinea">Módulo de usuarios</p>
          <h1>{{ seccionActiva === 'crear' ? 'Registrar usuario' : 'Actualizar usuario' }}</h1>
          <p class="subtitulo">{{ seccionActiva === 'crear' ? 'Crea un usuario y comprueba la respuesta del procedimiento almacenado.' : 'Modifica los datos de un usuario existente usando su DNI.' }}</p>
        </div>
        <div class="metodo" :class="seccionActiva"><b>{{ seccionActiva === 'crear' ? 'POST' : 'PUT' }}</b><code>{{ seccionActiva === 'crear' ? '/api/usuarios' : '/api/usuarios/{dni}' }}</code></div>
      </header>

      <section class="panel-formulario">
        <form v-if="seccionActiva === 'crear'" @submit.prevent="crearUsuario">
          <div class="seccion-formulario">
            <div><h2>Datos de identificación</h2><p>Los campos con asterisco son obligatorios.</p></div>
            <div class="campos">
              <label>DNI <span>*</span><input v-model.trim="formularioCrear.dni" required maxlength="18" placeholder="Ej. 0801..." /></label>
              <label>Correo electrónico <span>*</span><input v-model.trim="formularioCrear.correo_elec" required type="email" maxlength="50" placeholder="nombre@correo.com" /></label>
              <label>Primer nombre <span>*</span><input v-model.trim="formularioCrear.p_nombre" required maxlength="20" /></label>
              <label>Segundo nombre<input v-model="formularioCrear.s_nombre" maxlength="20" /></label>
              <label>Primer apellido <span>*</span><input v-model.trim="formularioCrear.p_apellido" required maxlength="20" /></label>
              <label>Segundo apellido<input v-model="formularioCrear.s_apellido" maxlength="20" /></label>
            </div>
          </div>
          <div class="seccion-formulario separada">
            <div><h2>Información de registro</h2><p>Datos requeridos por el procedimiento.</p></div>
            <div class="campos dos-columnas">
              <label>Salario <span>*</span><input v-model="formularioCrear.psalario" required type="number" min="0" max="999999.99" step="0.01" placeholder="0.00" /><small>Máximo permitido: 999,999.99</small></label>
              <label>Creado por <span>*</span><input v-model.trim="formularioCrear.pcreado_por" required maxlength="100" /></label>
            </div>
          </div>
          <button class="accion-principal" :disabled="enviando" type="submit"><span>{{ enviando ? 'Enviando…' : 'Registrar usuario' }}</span><span>→</span></button>
        </form>

        <form v-else @submit.prevent="actualizarUsuario">
          <div class="aviso"><b>i</b><p>El DNI identifica al usuario que deseas modificar. Viaja en la URL y no dentro del JSON.</p></div>
          <div class="seccion-formulario">
            <div><h2>Usuario a actualizar</h2><p>Indica el DNI del usuario existente.</p></div>
            <div class="campos una-columna"><label>DNI del usuario <span>*</span><input v-model.trim="formularioActualizar.dni" required maxlength="18" placeholder="DNI existente" /></label></div>
          </div>
          <div class="seccion-formulario separada">
            <div><h2>Nuevos datos</h2><p>Estos valores reemplazarán los datos actuales.</p></div>
            <div class="campos">
              <label>Primer nombre <span>*</span><input v-model.trim="formularioActualizar.p_nombre" required maxlength="20" /></label>
              <label>Segundo nombre<input v-model="formularioActualizar.s_nombre" maxlength="20" /></label>
              <label>Primer apellido <span>*</span><input v-model.trim="formularioActualizar.p_apellido" required maxlength="20" /></label>
              <label>Segundo apellido<input v-model="formularioActualizar.s_apellido" maxlength="20" /></label>
              <label>Correo electrónico <span>*</span><input v-model.trim="formularioActualizar.correo_elec" required type="email" maxlength="50" /></label>
              <label>Salario <span>*</span><input v-model="formularioActualizar.psalario" required type="number" min="0" max="999999.99" step="0.01" /><small>Máximo permitido: 999,999.99</small></label>
              <label>Modificado por <span>*</span><input v-model.trim="formularioActualizar.p_modificado_por" required maxlength="100" /></label>
            </div>
          </div>
          <button class="accion-principal actualizar" :disabled="enviando" type="submit"><span>{{ enviando ? 'Actualizando…' : 'Actualizar usuario' }}</span><span>→</span></button>
        </form>

        <div v-if="resultado" class="resultado" :class="resultado.tipo" role="status"><b>{{ resultado.tipo === 'exito' ? '✓' : '!' }}</b><div><strong>{{ resultado.titulo }}</strong><p>{{ resultado.mensaje }}</p></div></div>
      </section>
    </section>
  </main>
</template>

<style scoped>
.app-shell{min-height:100vh;display:grid;grid-template-columns:250px minmax(0,1fr);background:#f5f7fb;color:#202b3d}.barra-lateral{display:flex;flex-direction:column;min-height:100vh;padding:28px 16px;background:#172738;color:#e8f0f7}.marca{display:flex;align-items:center;gap:11px;padding:0 10px 34px}.marca-icono{display:grid;width:35px;height:35px;place-items:center;border-radius:10px;background:#29b985;color:#073a2b;font-weight:800;font-size:20px}.marca strong,.marca span{display:block}.marca strong{font-size:16px}.marca span{margin-top:1px;color:#9eafbf;font-size:12px}.nav-titulo{margin:0 10px 9px;color:#8ca0b2;font-size:11px;font-weight:700;letter-spacing:.09em;text-transform:uppercase}.nav-item{display:flex;align-items:center;width:100%;gap:10px;margin-bottom:5px;padding:11px 10px;border:0;border-radius:8px;background:transparent;color:#c6d3de;font:inherit;text-align:left;cursor:pointer}.nav-item:hover{background:#22384e}.nav-item.activo{background:#245942;color:#fff;font-weight:700}.nav-item b{font-size:20px;line-height:1}.api-info{display:flex;align-items:center;gap:8px;margin:auto 10px 0;color:#9eafbf;font-size:12px}.api-info i{width:8px;height:8px;border-radius:50%;background:#35d49a;box-shadow:0 0 0 4px rgb(53 212 154 / 12%)}.contenido{width:min(100%,1120px);margin:0 auto;padding:54px clamp(22px,5vw,68px)}.encabezado{display:flex;justify-content:space-between;align-items:flex-start;gap:24px;margin-bottom:32px}.sobrelinea{margin:0 0 8px;color:#168760;font-size:12px;font-weight:800;letter-spacing:.08em;text-transform:uppercase}.encabezado h1{margin:0;color:#152438;font-size:clamp(29px,4vw,38px);letter-spacing:-.04em}.subtitulo{max-width:620px;margin:10px 0 0;color:#627085}.metodo{display:flex;overflow:hidden;flex:none;border:1px solid #d7e0e9;border-radius:7px;background:#fff;color:#057b54;font-size:12px}.metodo b{padding:8px 10px}.metodo code{padding:8px 10px;border-left:1px solid #d7e0e9;color:#637287;font:12px ui-monospace,monospace}.metodo.actualizar{color:#2563b8}.panel-formulario{padding:clamp(23px,4vw,40px);border:1px solid #e0e6ed;border-radius:15px;background:#fff;box-shadow:0 10px 25px rgb(31 53 78 / 6%)}.seccion-formulario{display:grid;grid-template-columns:190px minmax(0,1fr);gap:28px}.seccion-formulario h2{margin:0 0 6px;font-size:16px}.seccion-formulario p{margin:0;color:#7a8798;font-size:13px;line-height:1.45}.separada{margin-top:31px;padding-top:29px;border-top:1px solid #e7ebf0}.campos{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px 16px}.campos.una-columna{grid-template-columns:minmax(0,1fr);max-width:360px}label{display:grid;gap:6px;color:#334258;font-size:13px;font-weight:700}label span{color:#d94a58}input{width:100%;min-width:0;padding:10px 11px;border:1px solid #cfd9e5;border-radius:7px;background:#fff;color:#1d2b3c;font:inherit;font-weight:400}input:focus{outline:0;border-color:#1d9c72;box-shadow:0 0 0 3px rgb(29 156 114 / 14%)}small{color:#8a97a7;font-size:11px;font-weight:400}.accion-principal{display:flex;justify-content:center;align-items:center;gap:12px;width:100%;margin-top:32px;padding:13px 18px;border:0;border-radius:8px;background:#168760;color:#fff;font:inherit;font-weight:800;cursor:pointer}.accion-principal:hover:not(:disabled){background:#0e6b4b}.accion-principal.actualizar{background:#2864ae}.accion-principal.actualizar:hover:not(:disabled){background:#1e508e}.accion-principal:disabled{cursor:wait;opacity:.7}.aviso{display:flex;gap:10px;margin-bottom:26px;padding:12px 14px;border:1px solid #cae0fc;border-radius:8px;background:#f2f8ff;color:#3b5f8c;font-size:13px}.aviso b,.resultado>b{display:grid;flex:none;width:21px;height:21px;place-items:center;border-radius:50%;font-size:13px}.aviso b{background:#5793db;color:#fff;font-family:Georgia,serif}.aviso p{margin:0}.resultado{display:flex;align-items:flex-start;gap:11px;margin-top:22px;padding:14px;border-radius:8px}.resultado strong{display:block;font-size:13px}.resultado p{margin:2px 0 0;font-size:13px}.resultado.exito{background:#eaf8f1;color:#116842}.resultado.exito>b{background:#24a36f;color:#fff}.resultado.error{background:#fff0f1;color:#af3341}.resultado.error>b{background:#d94a58;color:#fff}@media(max-width:760px){.app-shell{display:block}.barra-lateral{min-height:auto;padding:18px}.marca{padding-bottom:18px}.barra-lateral nav{display:flex;gap:6px}.nav-titulo,.api-info{display:none}.nav-item{margin:0}.contenido{padding:31px 18px}.encabezado{display:block}.metodo{width:max-content;margin-top:16px}.seccion-formulario{grid-template-columns:1fr;gap:16px}.campos{grid-template-columns:1fr}}
</style>
