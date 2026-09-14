package org.example.dto.transaccion;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record CrearTransaccionRequest (
        String p_usuario_dni,
        int p_id_presupuesto,
        int p_anio,
        int p_mes,
        int p_id_subcategoria,
        String p_tipo,
        String p_descripcion,
        BigDecimal p_monto,
        LocalDateTime p_fecha_ocurrido,
        String p_metodo_pago,
        String p_num_factura,
        String p_observaciones,
        String p_creado_por
) {
}
