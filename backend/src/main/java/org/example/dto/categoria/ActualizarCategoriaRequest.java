package org.example.dto.categoria;

public record ActualizarCategoriaRequest (
        String p_nombre,
        String p_descripcion,
        String p_modificado_por
){
}
