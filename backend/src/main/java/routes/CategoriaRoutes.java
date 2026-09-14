package routes;

import io.javalin.Javalin;
import org.example.controller.CategoriaController;

public class CategoriaRoutes {

    public static void registrar(Javalin app){

        CategoriaController categoriaController = new CategoriaController();

        app.post("/api/categorias", categoriaController::insertarCategoria);
        app.put("/api/categorias/{id}", categoriaController::actualizarCategoria);
        app.delete("/api/categorias/{id}", categoriaController::eliminarCategoria);
        app.get("/api/categorias/{id}", categoriaController::consultarCategoria);
        app.get("/api/categorias", categoriaController::listarCategorias);
    }
}
