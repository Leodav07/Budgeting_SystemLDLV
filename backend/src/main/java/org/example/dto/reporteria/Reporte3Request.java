package org.example.dto.reporteria;

public record Reporte3Request (
        String dni,
        int p_anio ,
        int p_mes,
        String p_tipo,
        int p_id_presupuesto
) {
}
