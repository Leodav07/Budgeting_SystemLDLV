package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record Transaccion (
        int id_transaccion,
        String usuario_dni,
        int id_presupuesto,
        int anio,
        int mes,
        int id_subcategoria,
        String tipo,
        String descripcion,
        BigDecimal monto,
        LocalDateTime fecha_ocurrido,
        String num_factura,
        String observaciones,
        LocalDateTime fecha_registro
) {
}
