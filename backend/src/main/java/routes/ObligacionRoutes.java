package routes;

import io.javalin.Javalin;
import org.example.controller.CategoriaController;
import org.example.controller.ObligacionController;

public class ObligacionRoutes {
    public static void registrar(Javalin app){

        ObligacionController obligacionController = new ObligacionController();

        app.post("/api/obligaciones", obligacionController::insertarObligacion);
        app.put("/api/obligaciones/{id}", obligacionController::actualizarObligacion);
        app.delete("/api/obligaciones/{id}", obligacionController::eliminarObligacion);
        app.get("/api/obligaciones/{id}", obligacionController::consultarObligacions);
        app.get("/api/usuarios/{id}/obligaciones", obligacionController::listarObligaciones);
    }
}
