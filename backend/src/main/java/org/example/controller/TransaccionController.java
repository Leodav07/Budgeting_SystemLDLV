package org.example.controller;

import io.javalin.http.Context;
import org.example.dto.transaccion.ActualizarTransaccionRequest;
import org.example.dto.transaccion.CrearTransaccionRequest;
import org.example.model.Especiales.TransaccionEspecial;
import org.example.repository.TransaccionRepository;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class TransaccionController {

    private final TransaccionRepository repository = new TransaccionRepository();

    public void insertarTransaccion(Context ctx) throws SQLException {
        CrearTransaccionRequest transaccionrq = ctx.bodyAsClass(CrearTransaccionRequest.class);
        repository.CrearTransaccion(transaccionrq);

        ctx.status(201).json(Map.of("mensaje", "Transaccion creada exitosamente."));
    }

    public void actualizarTransaccion(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        ActualizarTransaccionRequest transaccionrq = ctx.bodyAsClass(ActualizarTransaccionRequest.class);

        repository.ActualizarTransaccion(id, transaccionrq);
        ctx.json(Map.of("mensaje", "Transaccion actualizada exitosamente."));

    }

    public void eliminarTransaccion(Context ctx) throws SQLException{
        int id = Integer.parseInt(ctx.pathParam("id"));
        repository.EliminarTransaccion(id);
        ctx.json(Map.of("mensaje", "Transaccion eliminada correctamente."));

    }

    public void consultarTransaccion(Context ctx) throws SQLException {
        int id = Integer.parseInt(ctx.pathParam("id"));
        TransaccionEspecial transaccionEspecial = repository.consultarTransaccion(id);

        if(transaccionEspecial == null){
            ctx.status(404).json(Map.of(
                    "mensaje", "Transaccion no encontrada"
            ));
            return;
        }

        ctx.json(transaccionEspecial);
    }

    public void listarTransacciones(Context ctx) throws SQLException {
        String id = ctx.pathParam("id");
        List<TransaccionEspecial> transaccionEspeciales = repository.Listar(id);
        ctx.json(transaccionEspeciales);
    }
}
