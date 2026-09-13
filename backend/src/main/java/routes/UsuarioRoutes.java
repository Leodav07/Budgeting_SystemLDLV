package routes;

import io.javalin.Javalin;
import org.example.controller.UsuarioController;

public class UsuarioRoutes {

    public static void registrar(Javalin app) {
        UsuarioController userController = new UsuarioController();

        app.post("/api/usuarios", userController::insertarUsuario);
        app.put("/api/usuarios/{id}", userController::actualizarUsuario);
        app.patch("/api/usuarios/{id}", userController::eliminarUsuario);
        app.get("/api/usuarios/{id}", userController::consultarUsuario);
        app.get("/api/usuarios", userController::listarUsuarios);
    }
}
