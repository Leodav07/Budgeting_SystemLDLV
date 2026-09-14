package org.example.dto.subcategoria;

public record CrearSubcategoriaRequest (
        int p_id_categoria,
        String p_nombre,
        String p_descripcion,
        String p_creado_por
) {
}
