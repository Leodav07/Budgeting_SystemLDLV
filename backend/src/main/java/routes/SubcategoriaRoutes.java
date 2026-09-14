package routes;

import io.javalin.Javalin;
import org.example.controller.CategoriaController;
import org.example.controller.SubcategoriaController;

public class SubcategoriaRoutes {
    public static void registrar(Javalin app){

        SubcategoriaController subcategoriaController = new SubcategoriaController();

        app.post("/api/subcategorias", subcategoriaController::insertarSubcategoria);
        app.put("/api/subcategorias/{id}", subcategoriaController::actualizarSubcategoria);
        app.delete("/api/subcategorias/{id}", subcategoriaController::eliminarSubcategoria);
        app.get("/api/subcategorias/{id}", subcategoriaController::consultarSubcategoria);
        app.get("/api/categorias/{id}/subcategorias", subcategoriaController::listarSubcategoriasPorCategoria);
    }
}
