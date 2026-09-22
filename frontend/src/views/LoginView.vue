<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { loginService } from '@/services/loginService'
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
    session.iniciarSesion(data.dni || form.dni.trim())
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
    <div class="card card-pad login-card">
      <div class="app-brand" style="margin-bottom: 18px">
        <div class="app-brand-mark">PS</div>
        <div class="app-brand-text">
          <h1>Presupuesto Personal</h1>
          <span>Inicia sesión para continuar</span>
        </div>
      </div>

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
</template>

<style scoped>
.login-screen {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
}
.login-card {
  width: 100%;
  max-width: 360px;
}
</style>
