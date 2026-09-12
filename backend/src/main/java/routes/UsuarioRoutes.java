package routes;

import io.javalin.Javalin;
import org.example.controller.UsuarioController;

public class UsuarioRoutes {

    public static void registrar(Javalin app) {
        UsuarioController userController = new UsuarioController();

        app.post("/api/usuarios", userController::insertarUsuario);
    }
}
