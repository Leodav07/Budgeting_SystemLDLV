package org.example.model.Especiales;

import java.math.BigDecimal;

public record ReporteDistribucionGastos (
        String nombre_categoria,
        BigDecimal monto_total,
        int conteo_transacciones,
        BigDecimal gran_total,
        BigDecimal porcentaje
) {
}
