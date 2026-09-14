package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record Presupuesto (
        int id_presupuesto,
        String usuario_dni,
        String nombre,
        String descripcion,
        Integer anio_inicio,
        Integer mes_inicio,
        Integer anio_fin,
        Integer mes_fin,
        BigDecimal total_ingresos,
        BigDecimal total_gastos,
        BigDecimal total_ahorro,
        LocalDateTime fecha_creacion,
        String estado
) {
}
