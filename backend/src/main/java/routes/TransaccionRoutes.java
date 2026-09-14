package routes;

import io.javalin.Javalin;
import org.example.controller.TransaccionController;

public class TransaccionRoutes {


    public static void registrar(Javalin app){
        TransaccionController transaccionController = new TransaccionController();

        app.post("/api/transacciones", transaccionController::insertarTransaccion);
        app.put("/api/transacciones/{id}", transaccionController::actualizarTransaccion);
        app.delete("/api/transacciones/{id}", transaccionController::eliminarTransaccion);
        app.get("/api/transacciones/{id}", transaccionController::consultarTransaccion);
        app.get("/api/transacciones/{id}/presupuesto", transaccionController::listarTransacciones);

    }
}
