package org.example.controller;

import io.javalin.http.Context;
import org.example.dto.presupuesto_detalle.ActualizarPresupuestoDetalle;
import org.example.dto.presupuesto_detalle.CrearPresupuestoDetalle;
import org.example.model.Especiales.ConsultaPresupuestoDetalle;
import org.example.model.Especiales.ListarPresupuestoDetalle;
import org.example.repository.PresupuestoDetalleRepository;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class PresupuestoDetalleController {

    private final PresupuestoDetalleRepository repository = new PresupuestoDetalleRepository();

    public void insertarPresupuestoDetalle(Context ctx) throws SQLException{
        CrearPresupuestoDetalle pdetallerq = ctx.bodyAsClass(CrearPresupuestoDetalle.class);
        repository.CrearPresupuestoDetalle(pdetallerq);
        ctx.status(201).json(Map.of("mensaje", "Presupuesto detalle creado exitosamente."));
    }


    public void actualizarPresupuestoDetalle(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        ActualizarPresupuestoDetalle pdetallerq = ctx.bodyAsClass(ActualizarPresupuestoDetalle.class);

        repository.ActualizarPresupuestoDetalle(id, pdetallerq);
        ctx.json(Map.of("mensaje", "Presupuesto detalle actualizado exitosamente."));

    }

    public void eliminarPresupuestoDetalle(Context ctx) throws SQLException{
        int id = Integer.parseInt(ctx.pathParam("id"));
        repository.EliminarPresupuestoDetalle(id);
        ctx.json(Map.of("mensaje", "Presupuesto detalle eliminado correctamente."));

    }

    public void consultarPresupuestoDetalle(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        ConsultaPresupuestoDetalle presupuestoDetalle = repository.consultarPresupuestoDetalle(id);

        if(presupuestoDetalle == null){
            ctx.status(404).json(Map.of(
                    "mensaje", "Presupuesto detalle no encontrado"
            ));
            return;
        }

        ctx.json(presupuestoDetalle);
    }

    public void listarDetallesPresupuesto(Context ctx) throws SQLException {
        String id = ctx.pathParam("id");
        List<ListarPresupuestoDetalle> detallesPresupuesto = repository.Listar(id);
        ctx.json(detallesPresupuesto);
    }
}
