package org.example.repository;

import org.example.config.DBConnection;
import org.example.dto.subcategoria.ActualizarSubcategoriaRequest;
import org.example.dto.subcategoria.CrearSubcategoriaRequest;
import org.example.exception.ApiExceptionController;
import org.example.model.Especiales.CategoriaSubcategoria;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SubcategoriaRepository {
    private final DBConnection dbConnection = new DBConnection();

    public void CrearSubcategoria(CrearSubcategoriaRequest subcategoriarq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_insertar_subcategoria(?,?,?,?)}")) {

            statement.setInt(1, subcategoriarq.p_id_categoria());
            statement.setString(2, subcategoriarq.p_nombre());
            statement.setString(3, subcategoriarq.p_descripcion());
            statement.setString(4, subcategoriarq.p_creado_por());

            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("CATEGORIA_NO_EXISTE")){
                throw new ApiExceptionController(404, "CATEGORIA_NO_EXISTE",
                        "La categoria no existe en el sistema.");

            }

            throw err;
        }
    }


    public void ActualizarSubcategoria(int id, ActualizarSubcategoriaRequest subcategoriarq) throws SQLException {

        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_actualizar_subcategoria(?,?,?,?,?)}")) {

            statement.setInt(1, id);
            statement.setString(2, subcategoriarq.p_nombre());
            statement.setString(3, subcategoriarq.p_descripcion());
            statement.setBoolean(4, subcategoriarq.p_estado());
            statement.setString(5, subcategoriarq.p_modificado_por());
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("SUBCATEGORIA_NO_EXISTE")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_NO_EXISTE",
                        "La subcategoria no existe en el sistema.");

            }

            throw err;
        }
    }

    public void EliminarSubcategoria(int id) throws SQLException{
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_eliminar_subcategoria(?)}")) {
            statement.setInt(1, id);
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("SUBCATEGORIA_NO_EXISTE")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_NO_EXISTE",
                        "La subcategoria no existe en el sistema.");

            }
            else if  (err.getMessage().contains("NO_ELIMINAR_SUBCATEGORIA")){
                throw new ApiExceptionController(404, "NO_ELIMINAR_SUBCATEGORIA",
                        "No es posible eliminar esta categoria ya que esta en uso en presupuestos o transacciones.");

            }
            throw err;
        }
    }

    public CategoriaSubcategoria consultarCategoriaSubcategoriaId(int id) throws SQLException {
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_consultar_subcategoria(?)}")) {

            statement.setInt(1, id);

            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearCategoriaSubcategoria(resultado);
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("SUBCATEGORIA_NO_EXISTE")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_NO_EXISTE",
                        "La categoria no existe en el sistema.");

            }

            throw err;
        }
        return null;
    }


    public List<CategoriaSubcategoria> Listar(int id) throws SQLException{

        List<CategoriaSubcategoria> categoriasSubcategorias = new ArrayList<>();

        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_listar_subcategorias_por_categoria(?)}")){
            statement.setInt(1, id);

            try (ResultSet resultado = statement.executeQuery()) {
                while (resultado.next()) {
                    categoriasSubcategorias.add(mapearCategoriaSubcategoria(resultado));
                }
            }
        }

        return categoriasSubcategorias;
    }


    private CategoriaSubcategoria mapearCategoriaSubcategoria(ResultSet result) throws SQLException {
        return new CategoriaSubcategoria(
                result.getInt("id_categoria"),
                result.getString("nombre_categoria"),
                result.getString("descripcion_categoria"),
                result.getString("tipo"),
                result.getString("nombre_subcategoria"),
                result.getString("descripcion_subcategoria"),
                result.getBoolean("estado"),
                result.getBoolean("por_defecto")

        );
    }
}
