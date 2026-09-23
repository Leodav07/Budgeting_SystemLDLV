package org.example.model.Especiales;

import java.math.BigDecimal;
import java.sql.Date;

public record ReporteCumplimiento (
        String nombre_obligacion,
        BigDecimal monto_fijo,
        int vence_dia,
        int id_obligacion,
        int dias_restantes,
        Date fecha_ultimo_pago,
        String estado
){
}
