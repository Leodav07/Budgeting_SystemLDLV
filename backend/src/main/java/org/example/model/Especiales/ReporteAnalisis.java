package org.example.model.Especiales;

import java.math.BigDecimal;

public record ReporteAnalisis (
        int id_presupuesto,
        int id_subcategoria,
        String nombre_subcategoria,
        BigDecimal monto_presupuestado,
        int id_categoria,
        String nombre_categoria,
        BigDecimal monto_gastado
){
}
