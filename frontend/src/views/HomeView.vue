<script setup>
import { reactive, ref } from 'vue'

const form = reactive({
  dni: '',
  p_nombre: '',
  p_apellido: '',
  s_nombre: '',
  s_apellido: '',
  correo_elec: '',
  psalario: '',
  pcreado_por: 'usuario-demo',
})

const enviando = ref(false)
const resultado = ref(null)

async function registrarUsuario() {
  resultado.value = null
  enviando.value = true

  const datos = {
    ...form,
    s_nombre: form.s_nombre.trim() || null,
    s_apellido: form.s_apellido.trim() || null,
    psalario: Number(form.psalario),
  }

  try {
    const respuesta = await fetch('/api/usuarios', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(datos),
    })

    const contenido = await respuesta.json().catch(() => ({}))

    if (!respuesta.ok) {
      throw new Error(contenido.mensaje || 'No se pudo registrar el usuario.')
    }

    resultado.value = {
      tipo: 'exito',
      mensaje: contenido.mensaje || 'Usuario registrado correctamente.',
    }
  } catch (error) {
    resultado.value = {
      tipo: 'error',
      mensaje: error.message || 'No fue posible conectar con el backend.',
    }
  } finally {
    enviando.value = false
  }
}
</script>

<template>
  <main class="pagina">
    <section class="tarjeta">
      <p class="etiqueta">Prueba de backend</p>
      <h1>Registrar usuario</h1>
      <p class="descripcion">
        Envía los datos a <code>POST /api/usuarios</code> para comprobar que el procedimiento
        almacenado registra el usuario en MySQL.
      </p>

      <form @submit.prevent="registrarUsuario">
        <div class="campos">
          <label>
            DNI *
            <input v-model.trim="form.dni" required maxlength="18" />
          </label>

          <label>
            Primer nombre *
            <input v-model.trim="form.p_nombre" required maxlength="20" />
          </label>

          <label>
            Segundo nombre
            <input v-model="form.s_nombre" maxlength="20" />
          </label>

          <label>
            Primer apellido *
            <input v-model.trim="form.p_apellido" required maxlength="20" />
          </label>

          <label>
            Segundo apellido
            <input v-model="form.s_apellido" maxlength="20" />
          </label>

          <label>
            Correo electrónico *
            <input v-model.trim="form.correo_elec" required type="email" maxlength="50" />
          </label>

          <label>
            Salario *
            <input v-model="form.psalario" required type="number" min="0" step="0.01" />
          </label>

          <label>
            Creado por *
            <input v-model.trim="form.pcreado_por" required maxlength="100" />
          </label>
        </div>

        <button :disabled="enviando" type="submit">
          {{ enviando ? 'Registrando…' : 'Registrar usuario' }}
        </button>
      </form>

      <p v-if="resultado" class="resultado" :class="resultado.tipo" role="status">
        {{ resultado.mensaje }}
      </p>
    </section>
  </main>
</template>

<style scoped>
.pagina {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 2rem 1rem;
  background: #f3f6fb;
}

.tarjeta {
  width: min(100%, 760px);
  padding: 2.25rem;
  border-radius: 16px;
  background: #fff;
  box-shadow: 0 12px 35px rgb(30 58 95 / 12%);
}

.etiqueta { margin-bottom: .3rem; color: #176b4d; font-weight: 700; font-size: .85rem; text-transform: uppercase; letter-spacing: .08em; }
h1 { margin-bottom: .5rem; color: #172033; font-size: 2rem; }
.descripcion { margin-bottom: 1.75rem; color: #5d6778; }
code { padding: .1rem .35rem; border-radius: 4px; background: #e9eef8; color: #273e71; }
.campos { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1rem; }
label { display: grid; gap: .4rem; color: #2c3545; font-weight: 600; }
input { width: 100%; padding: .7rem .8rem; border: 1px solid #c8d0dc; border-radius: 7px; font: inherit; }
input:focus { outline: 3px solid #b8d9ff; border-color: #2774c8; }
button { width: 100%; padding: .8rem 1rem; border: 0; border-radius: 7px; background: #176b4d; color: #fff; font: inherit; font-weight: 700; cursor: pointer; }
button:hover:not(:disabled) { background: #10563d; }
button:disabled { cursor: wait; opacity: .7; }
.resultado { margin-top: 1.25rem; padding: .75rem 1rem; border-radius: 7px; }
.exito { color: #075a38; background: #e0f6eb; }
.error { color: #a51d2d; background: #fde9eb; }
@media (max-width: 600px) { .tarjeta { padding: 1.5rem; } .campos { grid-template-columns: 1fr; } }
</style>
