package org.example.model.Especiales;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record TransaccionEspecial (
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
){
}
