package org.example.controller;

import io.javalin.http.Context;
import org.example.dto.usuario.ActualizarUsuarioRequest;
import org.example.dto.usuario.CrearUsuarioRequest;
import org.example.repository.UsuarioRepository;

import java.sql.SQLException;
import java.util.Map;


public class UsuarioController {

    private final UsuarioRepository repository = new UsuarioRepository();

    public void insertarUsuario(Context ctx) throws SQLException {
        CrearUsuarioRequest usuariorq = ctx.bodyAsClass(CrearUsuarioRequest.class);
        repository.CrearUsuario(usuariorq);

        ctx.status(201).json(Map.of("mensaje", "Usuario creado exitosamente."));
    }

    public void actualizarUsuario(Context ctx) throws SQLException {
        String dni = ctx.pathParam("id");
        ActualizarUsuarioRequest usuariorq = ctx.bodyAsClass(ActualizarUsuarioRequest.class);
        repository.ActualizarUsuario(dni, usuariorq);
        ctx.json(Map.of("mensaje", "Usuario actualizado exitosamente."));
    }
}
