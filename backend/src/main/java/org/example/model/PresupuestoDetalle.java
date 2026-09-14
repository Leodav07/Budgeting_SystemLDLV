package org.example.model;

import java.math.BigDecimal;

public record PresupuestoDetalle (
        int id_pdetalle,
        int id_presupuesto,
        int id_subcategoria,
        BigDecimal monto_asignado,
        String justificacion_monto
){
}
