package org.example.dto.subcategoria;

public record ActualizarSubcategoriaRequest (
        String p_nombre,
        String p_descripcion,
        Boolean p_estado,
        String p_modificado_por
) {
}
