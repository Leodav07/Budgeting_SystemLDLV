package org.example.model.Especiales;

import java.math.BigDecimal;

public record ReporteIngresoGasto (
        BigDecimal ingresos,
        BigDecimal gastos,
        int anio,
        int mes,
        BigDecimal balance
){
}
