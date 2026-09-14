package org.example.model.Especiales;

import java.math.BigDecimal;

public record ConsultaPresupuestoDetalle (
        int id_presupuesto,
        int id_subcategoria,
        BigDecimal monto_asignado,
        String justificacion_monto,
        int id_categoria,
        String nombre_subcategoria,
        String descripcion_subcategoria,
        Boolean estado_subcategoria,
        Boolean por_defecto,
        String nombre_categoria,
        String descripcion_categoria,
        String tipo,
        String icono_nombre,
        String color_hex,
        Integer orden
) {
}
