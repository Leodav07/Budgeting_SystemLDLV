package org.example.model.Especiales;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ListarPresupuestoDetalle (
        String usuario_dni,
        String nombre_presupuesto,
        String descripcion_presupuesto,
        int anio_inicio,
        int mes_inicio,
        int anio_fin,
        int mes_fin,
        BigDecimal total_ingresos,
        BigDecimal total_gastos,
        BigDecimal total_ahorro,
        LocalDateTime fecha_creacion,
        String estado_presupuesto,
        int id_presupuesto,
        int id_subcategoria,
        BigDecimal monto_asignado,
        String justificacion_monto,
        int id_categoria,
        String nombre_subcategoria,
        String descripcion_subcategoria,
        Boolean estado_subcategoria,
        Boolean por_defecto
) {
}
