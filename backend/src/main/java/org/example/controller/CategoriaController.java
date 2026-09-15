package org.example.controller;

import io.javalin.http.Context;
import org.example.dto.categoria.ActualizarCategoriaRequest;
import org.example.dto.categoria.CrearCategoriaRequest;
import org.example.model.Categoria;
import org.example.model.Usuario;
import org.example.repository.CategoriaRepository;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class CategoriaController {

    private final CategoriaRepository repository = new CategoriaRepository();

    public void insertarCategoria(Context ctx) throws SQLException {
        CrearCategoriaRequest categoriarq = ctx.bodyAsClass(CrearCategoriaRequest.class);
        repository.CrearCategoria(categoriarq);

        ctx.status(201).json(Map.of("mensaje", "Categoria creada exitosamente."));
    }

    public void actualizarCategoria(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        ActualizarCategoriaRequest categoriarq = ctx.bodyAsClass(ActualizarCategoriaRequest.class);

        repository.ActualizarCategoria(id, categoriarq);
        ctx.json(Map.of("mensaje", "Categoria actualizada exitosamente."));

    }

    public void eliminarCategoria(Context ctx) throws SQLException{
        int id = Integer.parseInt(ctx.pathParam("id"));
        repository.EliminarCategoria(id);
        ctx.json(Map.of("mensaje", "Categoria eliminada correctamente."));

    }

    public void consultarCategoria(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        Categoria categoria = repository.consultarId(id);

        if(categoria == null){
            ctx.status(404).json(Map.of(
                    "mensaje", "Categoria no encontrada"
            ));
            return;
        }

        ctx.json(categoria);
    }

    public void listarCategorias(Context ctx) throws SQLException {
        String tipo = ctx.queryParam("tipo");
        List<Categoria> categorias = repository.Listar(tipo);

        ctx.json(categorias);
    }

}
