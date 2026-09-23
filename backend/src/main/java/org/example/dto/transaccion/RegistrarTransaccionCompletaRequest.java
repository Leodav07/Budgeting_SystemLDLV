package org.example.dto.transaccion;

import java.math.BigDecimal;
import java.sql.Date;

public record RegistrarTransaccionCompletaRequest (
        String p_usuario_dni,
        int p_id_presupuesto,
        int p_anio,
        int p_mes,
        int p_id_subcategoria,
        String p_tipo,
        String p_descripcion,
        BigDecimal p_monto,
        Date p_fecha,
        String p_metodo_pago,
        String p_num_factura,
        String p_observaciones,
        String p_creado_por,
        Integer p_id_obligacion
) {
}
