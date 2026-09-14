package org.example.model.Especiales;

public record CategoriaSubcategoria (
        int c_id_categoria,
        String nombre_categoria,
        String descripcion_categoria,
        String c_tipo,
        String nombre_subcategoria,
        String descripcion_subcategoria,
        Boolean sc_estado,
        Boolean sc_por_defecto

){
}
