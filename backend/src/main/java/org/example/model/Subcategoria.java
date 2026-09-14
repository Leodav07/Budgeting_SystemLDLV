package org.example.model;

public record Subcategoria (
        int id_subcategoria,
        int id_categoria,
        String nombre,
        String descripcion,
        Boolean estado,
        Boolean por_defecto
){
}
