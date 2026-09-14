package org.example.dto.categoria;

public record CrearCategoriaRequest (
        String p_nombre,
        String p_descripcion,
        String p_tipo,
        String p_icono_nombre,
        String p_color_hex,
        Integer p_orden,
        String p_creado_por
) {
}
