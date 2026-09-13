package org.example;

import io.javalin.Javalin;
import org.example.config.DBConnection;
import org.example.controller.UsuarioController;
import org.example.exception.ApiExceptionController;
import routes.UsuarioRoutes;

import java.sql.SQLException;
import java.util.Map;


public class Main {
    public static void main(String[] args) {

        Javalin app = Javalin.create();
        UsuarioRoutes.registrar(app);

        app.exception(ApiExceptionController.class, (err, ctx) ->{
                ctx.status(err.getStatus()).json(Map.of(
                        "codigo", err.getCodigo(),
                        "mensaje", err.getMessage()
                ));
    });


        app.start(7070);

    }

}



