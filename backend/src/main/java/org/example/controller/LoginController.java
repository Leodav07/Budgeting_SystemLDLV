package org.example.controller;

import io.javalin.http.Context;
import org.example.config.login.LoginAuth;
import org.example.dto.categoria.CrearCategoriaRequest;
import org.example.dto.login.LoginRequest;

import java.sql.SQLException;
import java.util.Map;

public class LoginController {
    private final LoginAuth logAuth = new LoginAuth();

    public void authLogin(Context ctx) throws SQLException {
        LoginRequest logrq = ctx.bodyAsClass(LoginRequest.class);
        if(logAuth.Auth(logrq)){
        ctx.status(201).json(Map.of("mensaje", "Usuario.",
                                    "dni", logrq.dni()));

        }else{
            ctx.status(401).json(Map.of("mensaje", "Fallido."));
        }

    }
}
