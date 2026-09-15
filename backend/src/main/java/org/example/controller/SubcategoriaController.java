package org.example.controller;

import io.javalin.http.Context;

import org.example.dto.subcategoria.ActualizarSubcategoriaRequest;
import org.example.dto.subcategoria.CrearSubcategoriaRequest;
import org.example.model.Especiales.CategoriaSubcategoria;
import org.example.repository.SubcategoriaRepository;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class SubcategoriaController {

    private final SubcategoriaRepository repository = new SubcategoriaRepository();

    public void insertarSubcategoria(Context ctx) throws SQLException {
        CrearSubcategoriaRequest subcategoriarq = ctx.bodyAsClass(CrearSubcategoriaRequest.class);
        repository.CrearSubcategoria(subcategoriarq);

        ctx.status(201).json(Map.of("mensaje", "Subcategoria creada exitosamente."));
    }

    public void actualizarSubcategoria(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        ActualizarSubcategoriaRequest subcategoriarq = ctx.bodyAsClass(ActualizarSubcategoriaRequest.class);

        repository.ActualizarSubcategoria(id, subcategoriarq);
        ctx.json(Map.of("mensaje", "Subcategoria actualizada exitosamente."));

    }

    public void eliminarSubcategoria(Context ctx) throws SQLException{
        int id = Integer.parseInt(ctx.pathParam("id"));
        repository.EliminarSubcategoria(id);
        ctx.json(Map.of("mensaje", "Subcategoria eliminada correctamente."));

    }

    public void consultarSubcategoria(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));

        CategoriaSubcategoria categoriaSubcategoria = repository.consultarCategoriaSubcategoriaId(id);

        if(categoriaSubcategoria == null){
            ctx.status(404).json(Map.of(
                    "mensaje", "Subcategoria no encontrada"
            ));
            return;
        }

        ctx.json(categoriaSubcategoria);
    }

    public void listarSubcategoriasPorCategoria(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        List<CategoriaSubcategoria> categoriaSubcategorias = repository.Listar(id);

        ctx.json(categoriaSubcategorias);
    }

}
