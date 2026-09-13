package org.example.controller;

import io.javalin.http.Context;
import org.example.dto.usuario.ActualizarUsuarioRequest;
import org.example.dto.usuario.CrearUsuarioRequest;
import org.example.dto.usuario.EliminarUsuarioRequest;
import org.example.model.Usuario;
import org.example.repository.UsuarioRepository;

import java.sql.SQLException;
import java.util.List;
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

    public void eliminarUsuario(Context ctx) throws SQLException {
        String dni = ctx.pathParam("id");
        EliminarUsuarioRequest usuariorq = ctx.bodyAsClass(EliminarUsuarioRequest.class);
        repository.EliminarUsuario(dni, usuariorq);
        ctx.json(Map.of("mensaje", "Usuario eliminado exitosamente."));
    }

    public void consultarUsuario(Context ctx) throws SQLException {
        String dni = ctx.pathParam("id");
        Usuario usuario = repository.consultarDNI(dni);

        if(usuario == null){
            ctx.status(404).json(Map.of(
                    "mensaje", "Usuario no encontrado"
            ));
            return;
        }

        ctx.json(usuario);
    }

    public void listarUsuarios(Context ctx) throws SQLException {
        List<Usuario> usuarios = repository.Listar();

        ctx.json(usuarios);
    }
}
