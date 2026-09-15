package org.example.repository;

import org.example.config.DBConnection;
import org.example.dto.categoria.ActualizarCategoriaRequest;
import org.example.dto.categoria.CrearCategoriaRequest;
import org.example.exception.ApiExceptionController;
import org.example.model.Categoria;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoriaRepository {

    private final DBConnection dbConnection = new DBConnection();

    public void CrearCategoria(CrearCategoriaRequest categoriarq) throws SQLException{
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                connection.prepareCall("{CALL sp_insertar_categoria(?,?,?,?,?,?,?)}")) {

            statement.setString(1, categoriarq.p_nombre());
            statement.setString(2, categoriarq.p_descripcion());
            statement.setString(3, categoriarq.p_tipo());
            statement.setString(4, categoriarq.p_icono_nombre());
            statement.setString(5, categoriarq.p_color_hex());

            if(categoriarq.p_orden() == null){
                statement.setNull(6, Types.VARCHAR);
            }else {
                statement.setInt(6, categoriarq.p_orden());
            }
            statement.setString(7, categoriarq.p_creado_por());

            statement.execute();

        }
    }


    public void ActualizarCategoria(int id, ActualizarCategoriaRequest categoriarq) throws SQLException {

        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_actualizar_categoria(?,?,?,?)}")) {

            statement.setInt(1, id);
            statement.setString(2, categoriarq.p_nombre());
            statement.setString(3, categoriarq.p_descripcion());
            statement.setString(4, categoriarq.p_modificado_por());
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("CATEGORIA_NO_EXISTE")){
                throw new ApiExceptionController(404, "CATEGORIA_NO_EXISTE",
                        "La categoria no existe en el sistema.");

            }

            throw err;
        }
    }

    public void EliminarCategoria(int id) throws SQLException{
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_eliminar_categoria(?)}")) {
            statement.setInt(1, id);
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("CATEGORIA_NO_EXISTE")){
                throw new ApiExceptionController(404, "CATEGORIA_NO_EXISTE",
                        "La categoria no existe en el sistema.");

            } else if (err.getMessage().contains("SUBCATEGORIA_ACTIVA")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_ACTIVA",
                        "La categoria a eliminar cuenta con subcategoria/s activa/s.");
            }

            throw err;
        }
    }

    public Categoria consultarId(int id) throws SQLException {
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_consultar_categoria(?)}")) {

            statement.setInt(1, id);

            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearCategoria(resultado);
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("CATEGORIA_NO_EXISTE")){
                throw new ApiExceptionController(404, "CATEGORIA_NO_EXISTE",
                        "La categoria no existe en el sistema.");

            }

            throw err;
        }
        return null;
    }


    public List<Categoria> Listar(String tipo) throws SQLException{

        List<Categoria> categorias = new ArrayList<>();

        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_listar_categorias(?)}")){
            statement.setString(1, tipo);
            try (ResultSet resultado = statement.executeQuery()) {
                while (resultado.next()) {
                    categorias.add(mapearCategoria(resultado));
                }
            }
        }

        return categorias;
    }


    private Categoria mapearCategoria(ResultSet result) throws SQLException {
        return new Categoria(
                result.getInt("id_categoria"),
                result.getString("nombre"),
                result.getString("descripcion"),
                result.getString("tipo"),
                result.getString("icono_nombre"),
                result.getString("color_hex"),
                result.getInt("orden")

        );
    }

}
