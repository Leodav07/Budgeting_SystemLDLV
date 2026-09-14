package org.example.dto.presupuesto;

import java.math.BigDecimal;

public record CrearPresupuestoRequest (
        String p_usuario_dni,
        String p_nombre,
        String p_descripcion,
        Integer p_anio_inicio,
        Integer p_mes_inicio,
        Integer p_anio_final,
        Integer p_mes_final,
        BigDecimal p_total_ingresos,
        BigDecimal p_total_gastos,
        BigDecimal p_total_ahorro,
        String p_creado_por
){
}
