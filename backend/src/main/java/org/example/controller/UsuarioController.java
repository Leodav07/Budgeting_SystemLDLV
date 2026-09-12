package org.example.controller;

import io.javalin.http.Context;
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
}
