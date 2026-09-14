package routes;

import io.javalin.Javalin;
import org.example.controller.PresupuestoDetalleController;

public class PresupuestoDetalleRoutes {
    public static void registrar(Javalin app) {
        PresupuestoDetalleController detalleController = new PresupuestoDetalleController();

        app.post("/api/presupuestos_detalles", detalleController::insertarPresupuestoDetalle);
        app.put("/api/presupuestos_detalles/{id}", detalleController::actualizarPresupuestoDetalle);
        app.patch("/api/presupuestos_detalles/{id}", detalleController::eliminarPresupuestoDetalle);
        app.get("/api/presupuestos_detalles/{id}", detalleController::consultarPresupuestoDetalle);
        app.get("/api/presupuestos/{id}/presupuestos_detalles", detalleController::listarDetallesPresupuesto);
    }
}
