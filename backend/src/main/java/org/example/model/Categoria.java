package org.example.model;

public record Categoria (
        int id_categoria,
        String nombre,
        String descripcion,
        String tipo,
        String icono_nombre,
        String color_hex,
        Integer orden
){
}
