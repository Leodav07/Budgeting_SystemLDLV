package routes;

import io.javalin.Javalin;
import org.example.controller.PresupuestoController;
import org.example.controller.UsuarioController;

public class PresupuestoRoutes {
    public static void registrar(Javalin app) {
        PresupuestoController presupuestoController = new PresupuestoController();

        app.post("/api/presupuestos", presupuestoController::insertarPresupuesto);
        app.put("/api/presupuestos/{id}", presupuestoController::actualizarPresupuesto);
        app.patch("/api/presupuestos/{id}", presupuestoController::eliminarPresupuesto);
        app.get("/api/presupuestos/{id}", presupuestoController::consultarPresupuestos);
        app.get("/api/presupuestos", presupuestoController::listarPresupuestos);
    }
}
