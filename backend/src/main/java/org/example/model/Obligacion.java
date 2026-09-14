package org.example.model;

import java.math.BigDecimal;
import java.sql.Date;

public record Obligacion (
        int id_obligacion,
        String usuario_dni,
        int id_subcategoria,
        String nombre,
        String descripcion,
        BigDecimal monto_fijo,
        Integer vence_dia,
        Boolean vigente,
        Date fecha_inicio,
        Date fecha_final
){
}
