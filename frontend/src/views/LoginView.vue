<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { loginService } from '@/services/loginService'
import { usuarioService } from '@/services/usuarioService'
import { useSession } from '@/services/session'
import AppAlert from '@/components/AppAlert.vue'

const router = useRouter()
const session = useSession()

const form = reactive({ dni: '', p_contrasenia: '' })
const errors = reactive({})
const loading = ref(false)
const loginError = ref(null)

function validate() {
  Object.keys(errors).forEach((k) => delete errors[k])
  if (!form.dni.trim()) errors.dni = 'El DNI es obligatorio.'
  if (!form.p_contrasenia) errors.p_contrasenia = 'La contraseña es obligatoria.'
  return Object.keys(errors).length === 0
}

async function submit() {
  loginError.value = null
  if (!validate()) return
  loading.value = true
  try {
    const data = await loginService.autenticar(form.dni.trim(), form.p_contrasenia)
    const dni = data.dni || form.dni.trim()

    let nombreCompleto = dni
    try {
      const usuario = await usuarioService.consultar(dni)
      nombreCompleto = [usuario.primer_nombre, usuario.primer_apellido].filter(Boolean).join(' ') || dni
    } catch {
      // si falla la consulta del nombre, seguimos con el DNI como respaldo
    }

    session.iniciarSesion(dni, nombreCompleto)
    router.push('/')
  } catch (e) {
    loginError.value = e.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-screen">
    <div class="login-panel">
      <div class="login-hero">
        <div class="login-hero-mark">PS</div>
        <h1>Presupuesto Personal</h1>
        <p>Planifica tus ingresos, controla tus gastos y alcanza tus metas de ahorro en un solo lugar.</p>
        <ul class="login-hero-points">
          <li>Presupuestos mensuales por categoría</li>
          <li>Seguimiento de obligaciones y vencimientos</li>
          <li>Reportes claros de tu situación financiera</li>
        </ul>
      </div>

      <div class="card card-pad login-card">
        <h2>Iniciar sesión</h2>
        <p class="login-subtitle">Ingresa tus credenciales para continuar</p>

        <AppAlert v-if="loginError" :message="loginError" />

        <form class="form-grid single" @submit.prevent="submit">
          <div class="field">
            <label>DNI</label>
            <input
              v-model="form.dni"
              class="input"
              :class="{ invalid: errors.dni }"
              maxlength="18"
              autocomplete="username"
              placeholder="Tu número de identidad"
            />
            <span class="field-error" v-if="errors.dni">{{ errors.dni }}</span>
          </div>
          <div class="field">
            <label>Contraseña</label>
            <input
              v-model="form.p_contrasenia"
              type="password"
              class="input"
              :class="{ invalid: errors.p_contrasenia }"
              autocomplete="current-password"
              placeholder="••••••••"
              @keyup.enter="submit"
            />
            <span class="field-error" v-if="errors.p_contrasenia">{{ errors.p_contrasenia }}</span>
          </div>

          <button type="submit" class="btn btn-primary" :disabled="loading" style="margin-top: 6px">
            <span v-if="loading" class="spinner" /> Iniciar sesión
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-screen {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background: linear-gradient(135deg, #eef2ff 0%, #f4f6fb 45%, #ecfdf5 100%);
}

.login-panel {
  width: 100%;
  max-width: 860px;
  display: grid;
  grid-template-columns: 1.1fr 1fr;
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  overflow: hidden;
  border: 1px solid var(--color-border);
}

.login-hero {
  background: linear-gradient(160deg, var(--color-primary) 0%, #7c3aed 100%);
  color: #fff;
  padding: 40px 34px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 14px;
}

.login-hero-mark {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 18px;
}

.login-hero h1 {
  color: #fff;
  font-size: 26px;
}

.login-hero p {
  color: rgba(255, 255, 255, 0.88);
  font-size: 14px;
}

.login-hero-points {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 8px;
  font-size: 13.5px;
  color: rgba(255, 255, 255, 0.92);
}

.login-hero-points li {
  padding-left: 20px;
  position: relative;
}

.login-hero-points li::before {
  content: '✓';
  position: absolute;
  left: 0;
  font-weight: 700;
}

.login-card {
  display: flex;
  flex-direction: column;
  justify-content: center;
  border: none;
  border-radius: 0;
  box-shadow: none;
  padding: 40px 34px;
}

.login-subtitle {
  color: var(--color-text-soft);
  font-size: 13.5px;
  margin-bottom: 18px;
}

@media (max-width: 720px) {
  .login-panel {
    grid-template-columns: 1fr;
  }
  .login-hero {
    padding: 28px 26px;
  }
  .login-card {
    padding: 28px 26px;
  }
}
</style>
