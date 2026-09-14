package org.example.dto.presupuesto_detalle;

import java.math.BigDecimal;

public record ActualizarPresupuestoDetalle (
        int p_id_presupuesto_detalle,
        BigDecimal p_monto_asignado,
        String p_justificacion_monto,
        String p_modificado_por
) {
}
