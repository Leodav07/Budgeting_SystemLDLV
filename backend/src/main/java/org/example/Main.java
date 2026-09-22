package org.example;

import io.javalin.Javalin;
import org.example.controller.ReporteController;
import org.example.exception.ApiExceptionController;
import routes.*;
import io.javalin.json.JavalinJackson;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import java.sql.SQLException;
import java.util.Map;


public class Main {
    public static void main(String[] args) {

        Javalin app = Javalin.create(config -> {
            config.jsonMapper(new JavalinJackson().updateMapper(mapper -> {
                mapper.registerModule(new JavaTimeModule());
                mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            }));
        });
        LoginRoute.registrar(app);
        UsuarioRoutes.registrar(app);
        CategoriaRoutes.registrar(app);
        PresupuestoRoutes.registrar(app);
        SubcategoriaRoutes.registrar(app);
        ObligacionRoutes.registrar(app);
        TransaccionRoutes.registrar(app);
        PresupuestoDetalleRoutes.registrar(app);
        ReporteRoutes.registrar(app);

        app.exception(ApiExceptionController.class, (err, ctx) ->{
                ctx.status(err.getStatus()).json(Map.of(
                        "codigo", err.getCodigo(),
                        "mensaje", err.getMessage()
                ));
    });


        app.start(7070);

    }

}



