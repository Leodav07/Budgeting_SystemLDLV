package routes;

import io.javalin.Javalin;
import org.example.controller.PresupuestoController;
import org.example.controller.ReporteController;

public class ReporteRoutes {
    public static void registrar(Javalin app) {
        ReporteController reporteController = new ReporteController();

        app.post("/api/reporteria/reporte1", reporteController::reporteIngresosGastos);
        app.post("/api/reporteria/reporte2", reporteController::reporteDistribucionGastos);
        app.post("/api/reporteria/reporte3", reporteController::reporteAnalisis);
        app.post("/api/reporteria/reporte4", reporteController::reporteCumplimiento);


    }
}
