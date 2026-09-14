package org.example.controller;

import io.javalin.http.Context;
import org.example.dto.categoria.ActualizarCategoriaRequest;
import org.example.dto.categoria.CrearCategoriaRequest;
import org.example.dto.obligacion.ActualizarObligacionRequest;
import org.example.dto.obligacion.CrearObligacionRequest;
import org.example.dto.obligacion.EliminarObligacionRequest;
import org.example.dto.obligacion.ListarObligacionesRequest;
import org.example.model.Categoria;
import org.example.model.Especiales.ObligacionSubcategoria;
import org.example.repository.CategoriaRepository;
import org.example.repository.ObligacionRepository;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class ObligacionController {

    private final ObligacionRepository repository = new ObligacionRepository();

    public void insertarObligacion(Context ctx) throws SQLException {
        CrearObligacionRequest obligacionrq = ctx.bodyAsClass(CrearObligacionRequest.class);
        repository.CrearObligacion(obligacionrq);

        ctx.status(201).json(Map.of("mensaje", "Obligacion creada exitosamente."));
    }

    public void actualizarObligacion(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        ActualizarObligacionRequest obligacionrq = ctx.bodyAsClass(ActualizarObligacionRequest.class);

        repository.ActualizarObligacion(id, obligacionrq);
        ctx.json(Map.of("mensaje", "Obligacion actualizada exitosamente."));

    }

    public void eliminarObligacion(Context ctx) throws SQLException{
        int id = Integer.parseInt(ctx.pathParam("id"));
        EliminarObligacionRequest obligacionrq = ctx.bodyAsClass(EliminarObligacionRequest.class);
        repository.EliminarObligacion(id, obligacionrq);
        ctx.json(Map.of("mensaje", "Obligacion eliminada correctamente."));

    }

    public void consultarObligacions(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        ObligacionSubcategoria obligacionSubcategoria = repository.consultarObligacion(id);

        if(obligacionSubcategoria == null){
            ctx.status(404).json(Map.of(
                    "mensaje", "Obligacion no encontrada"
            ));
            return;
        }

        ctx.json(obligacionSubcategoria);
    }

    public void listarObligaciones(Context ctx) throws SQLException {
        String id = ctx.pathParam("id");
        ListarObligacionesRequest obligacionrq = ctx.bodyAsClass(ListarObligacionesRequest.class);
        List<ObligacionSubcategoria> obligacionSubcategoria = repository.Listar(id, obligacionrq);
        ctx.json(obligacionSubcategoria);
    }
}
