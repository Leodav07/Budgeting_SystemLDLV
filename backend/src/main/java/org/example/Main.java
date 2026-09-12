package org.example;

import io.javalin.Javalin;
import org.example.config.DBConnection;
import org.example.controller.UsuarioController;
import routes.UsuarioRoutes;

import java.sql.SQLException;
import java.util.Map;


public class Main {
    public static void main(String[] args) {

        Javalin app = Javalin.create();
        UsuarioRoutes.registrar(app);

        app.exception(SQLException.class, (error, ctx) -> {
            ctx.status(500).json(Map.of(
                    "mensaje", "Ocurrio un error al insertar usuario."

            ));
            error.printStackTrace();
        });

        app.start(7070);

    }

}



