package org.example;

import io.javalin.Javalin;
import org.example.exception.ApiExceptionController;
import routes.*;

import java.sql.SQLException;
import java.util.Map;


public class Main {
    public static void main(String[] args) {

        Javalin app = Javalin.create();
        UsuarioRoutes.registrar(app);
        CategoriaRoutes.registrar(app);
        PresupuestoRoutes.registrar(app);
        SubcategoriaRoutes.registrar(app);
        ObligacionRoutes.registrar(app);
        TransaccionRoutes.registrar(app);
        PresupuestoDetalleRoutes.registrar(app);

        app.exception(ApiExceptionController.class, (err, ctx) ->{
                ctx.status(err.getStatus()).json(Map.of(
                        "codigo", err.getCodigo(),
                        "mensaje", err.getMessage()
                ));
    });


        app.start(7070);

    }

}



