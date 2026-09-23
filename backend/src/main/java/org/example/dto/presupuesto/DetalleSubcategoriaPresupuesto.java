package org.example.dto.presupuesto;

import java.math.BigDecimal;

public record DetalleSubcategoriaPresupuesto (
        int id_subcategoria,
        BigDecimal monto_mensual
) {
}
