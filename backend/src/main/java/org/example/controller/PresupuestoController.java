package org.example.controller;

import io.javalin.http.Context;
import org.example.dto.presupuesto.ActualizarPresupuestoRequest;
import org.example.dto.presupuesto.CrearPresupuestoCompletoRequest;
import org.example.dto.presupuesto.CrearPresupuestoRequest;
import org.example.model.Presupuesto;
import org.example.repository.PresupuestoRepository;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class PresupuestoController {

    private final PresupuestoRepository repository = new PresupuestoRepository();

    public void insertarPresupuesto(Context ctx) throws SQLException {
        CrearPresupuestoRequest presupuestorq = ctx.bodyAsClass(CrearPresupuestoRequest.class);
        repository.CrearPresupuesto(presupuestorq);

        ctx.status(201).json(Map.of("mensaje", "Presupuesto creado exitosamente."));
    }

    public void insertarPresupuestoCompleto(Context ctx) throws SQLException {
        CrearPresupuestoCompletoRequest presupuestorq = ctx.bodyAsClass(CrearPresupuestoCompletoRequest.class);
        repository.CrearPresupuestoCompleto(presupuestorq);

        ctx.status(201).json(Map.of("mensaje", "Presupuesto creado exitosamente."));
    }

    public void actualizarPresupuesto(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        ActualizarPresupuestoRequest presupuestorq = ctx.bodyAsClass(ActualizarPresupuestoRequest.class);

        repository.ActualizarPresupuesto(id, presupuestorq);
        ctx.json(Map.of("mensaje", "Presupuesto actualizado exitosamente."));

    }

    public void eliminarPresupuesto(Context ctx) throws SQLException{
        int id = Integer.parseInt(ctx.pathParam("id"));
        repository.EliminarPresupuesto(id);
        ctx.json(Map.of("mensaje", "Presupuesto eliminado correctamente."));

    }

    public void consultarPresupuestos(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        Presupuesto presupuesto = repository.consultarPresupuesto(id);

        if(presupuesto == null){
            ctx.status(404).json(Map.of(
                    "mensaje", "Presupuesto no encontrado"
            ));
            return;
        }

        ctx.json(presupuesto);
    }

    public void listarPresupuestos(Context ctx) throws SQLException {
        String id = ctx.pathParam("id");
        String estado = ctx.queryParam("estado");
        List<Presupuesto> presupuestos = repository.Listar(id, estado);

        ctx.json(presupuestos);
    }
}
