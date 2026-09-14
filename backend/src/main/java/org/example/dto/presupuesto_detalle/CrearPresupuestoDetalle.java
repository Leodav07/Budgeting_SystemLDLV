package org.example.dto.presupuesto_detalle;

import java.math.BigDecimal;

public record CrearPresupuestoDetalle (
        int p_id_presupuesto,
        int p_id_subcategoria,
        BigDecimal p_monto_asignado,
        String p_justificacion_monto,
        String p_creado_por
){
}
