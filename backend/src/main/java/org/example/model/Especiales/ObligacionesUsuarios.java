package org.example.model.Especiales;

import java.math.BigDecimal;
import java.sql.Date;

public record ObligacionesUsuarios (
        String usuario_dni,
        int id_subcategoria,
        String nombre_obligacion,
        String descripcion_obligacion,
        BigDecimal monto_fijo,
        Integer vence_dia,
        Boolean vigente,
        Date fecha_incio,
        Date fecha_final
){
}
