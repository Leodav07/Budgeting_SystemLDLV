package org.example.dto.presupuesto;

import java.sql.Date;
import java.util.List;

public record CrearPresupuestoCompletoRequest (
        String p_usuario_dni,
        String p_nombre,
        String p_descripcion,
        Date p_periodo_inicio,
        Date p_periodo_fin,
        List<DetalleSubcategoriaPresupuesto> p_lista_subcategorias_json,
        String p_creado_por
) {
}
