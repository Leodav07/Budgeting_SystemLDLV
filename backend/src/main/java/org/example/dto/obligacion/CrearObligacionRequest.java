package org.example.dto.obligacion;

import java.math.BigDecimal;
import java.sql.Date;

public record CrearObligacionRequest (
        String p_usuario_dni,
        int p_id_subcategoria,
        String p_nombre,
        String p_descripcion,
        BigDecimal p_monto_fijo,
        Integer p_vence_dia,
        Date p_fecha_inicio,
        Date p_fecha_final,
        String p_creado_por
) {
}
