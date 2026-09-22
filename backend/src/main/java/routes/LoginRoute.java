package routes;

import io.javalin.Javalin;
import org.example.controller.LoginController;
import org.example.controller.ObligacionController;

public class LoginRoute {
    public static void registrar(Javalin app){

        LoginController loginController = new LoginController();

        app.post("/api/login", loginController::authLogin);
    }
}
