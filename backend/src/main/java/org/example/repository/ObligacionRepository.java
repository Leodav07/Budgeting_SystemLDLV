package org.example.repository;

import org.example.config.DBConnection;
import org.example.dto.obligacion.ActualizarObligacionRequest;
import org.example.dto.obligacion.CrearObligacionRequest;
import org.example.dto.obligacion.EliminarObligacionRequest;
import org.example.exception.ApiExceptionController;
import org.example.model.Especiales.ObligacionSubcategoria;
import org.example.model.Especiales.ObligacionesUsuarios;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ObligacionRepository {
    private final DBConnection dbConnection = new DBConnection();

    public void CrearObligacion(CrearObligacionRequest obligacionrq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_insertar_obligacion(?,?,?,?,?,?,?,?,?)}")) {

            statement.setString(1, obligacionrq.p_usuario_dni());
            statement.setInt(2, obligacionrq.p_id_subcategoria());
            statement.setString(3, obligacionrq.p_nombre());
            statement.setString(4, obligacionrq.p_descripcion());
            statement.setBigDecimal(5, obligacionrq.p_monto_fijo());
            setNullableInt(statement, 6, obligacionrq.p_vence_dia());
            statement.setDate(7, obligacionrq.p_fecha_inicio());
            statement.setDate(8, obligacionrq.p_fecha_final());
            statement.setString(9, obligacionrq.p_creado_por());

            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("SUBCATEGORIA_NO_EXISTE_DESACTIVADA")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_NO_EXISTE_DESACTIVADA",
                        "La subcategoria ingresada no existe o esta desactivada en el sistema.");

            }
            else if  (err.getMessage().contains("FECHA_FINAL_MAYOR")){
                throw new ApiExceptionController(404, "FECHA_FINAL_MAYOR",
                        "La fecha final debe ser mayor a la fecha inicial.");

            }else if  (err.getMessage().contains("SUBCATEGORIA_NO_GASTO")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_NO_GASTO",
                        "La subcategoria debe ser de tipo gasto dentro de categoria.");

            }

            throw err;
        }
    }


    public void ActualizarObligacion(int id, ActualizarObligacionRequest obligacionrq) throws SQLException {

        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_actualizar_obligacion(?,?,?,?,?,?,?,?,?)}")) {

            statement.setInt(1, id);
            statement.setInt(2, obligacionrq.p_id_subcategoria());
            statement.setString(3, obligacionrq.p_nombre());
            statement.setString(4, obligacionrq.p_descripcion());
            statement.setBigDecimal(5, obligacionrq.p_monto_fijo());
            setNullableInt(statement, 6, obligacionrq.p_vence_dia());
            statement.setDate(7, obligacionrq.p_fecha_inicio());
            statement.setDate(8, obligacionrq.p_fecha_final());
            statement.setString(9, obligacionrq.p_modificado_por());

            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("OBLIGACION_NO_EXISTE")){
            throw new ApiExceptionController(404, "OBLIGACION_NO_EXISTE",
                    "La obligacion no existe en el sistema.");

        }
            else if  (err.getMessage().contains("SUBCATEGORIA_NO_EXISTE_DESACTIVADA")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_NO_EXISTE_DESACTIVADA",
                        "La subcategoria ingresada no existe o esta desactivada en el sistema.");

            }
            else if  (err.getMessage().contains("FECHA_FINAL_MAYOR")){
                throw new ApiExceptionController(404, "FECHA_FINAL_MAYOR",
                        "La fecha final debe ser mayor a la fecha inicial.");

            }else if  (err.getMessage().contains("SUBCATEGORIA_NO_GASTO")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_NO_GASTO",
                        "La subcategoria debe ser de tipo gasto dentro de categoria.");

            }

            throw err;
        }
    }

    public void EliminarObligacion(int id, EliminarObligacionRequest obligacionrq) throws SQLException{
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_eliminar_obligacion(?,?)}")) {
            statement.setInt(1, id);
            statement.setString(2, obligacionrq.p_modificado_por());
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("OBLIGACION_NO_EXISTE")){
                throw new ApiExceptionController(404, "OBLIGACION_NO_EXISTE",
                        "La obligacion no existe en el sistema.");

            }
            throw err;
        }
    }

    public ObligacionSubcategoria consultarObligacion(int id) throws SQLException {
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_consultar_obligacion(?)}")) {

            statement.setInt(1, id);

            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearObligacionSubcategoria(resultado);
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("OBLIGACION_NO_EXISTE")){
                throw new ApiExceptionController(404, "OBLIGACION_NO_EXISTE",
                        "La obligacion no existe en el sistema.");

            }
            throw err;
        }
        return null;
    }


    public List<ObligacionesUsuarios> Listar(String id, Boolean vigente) throws SQLException{

        List<ObligacionesUsuarios> obligacionesUsuarios = new ArrayList<>();

        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_listar_obligaciones_usuario(?,?)}")){
            statement.setString(1, id);
            if (vigente == null){
                statement.setNull(2, Types.BOOLEAN);
            }else{
            statement.setBoolean(2, vigente);
            }

            try (ResultSet resultado = statement.executeQuery()) {
                while (resultado.next()) {
                    obligacionesUsuarios.add(mapearObligacionesUsuarios(resultado));
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("USUARIO_NO_EXISTE")){
                throw new ApiExceptionController(404, "USUARIO_NO_EXISTE",
                        "El usuario ingresado no existe en el sistema.");

            }
            throw err;
        }

        return obligacionesUsuarios;
    }


    private void setNullableInt(CallableStatement statement, int index, Integer value) throws SQLException {
        if (value == null) {
            statement.setNull(index, Types.INTEGER);
        } else {
            statement.setInt(index, value);
        }
    }

    private ObligacionSubcategoria mapearObligacionSubcategoria(ResultSet result) throws SQLException {
        return new ObligacionSubcategoria(
                result.getString("usuario_dni"),
                result.getInt("id_subcategoria"),
                result.getString("nombre_obligacion"),
                result.getString("descripcion_obligacion"),
                result.getBigDecimal("monto_fijo"),
                result.getInt("vence_dia"),
                result.getBoolean("vigente"),
                result.getDate("fecha_inicio"),
                result.getDate("fecha_final"),
                result.getString("nombre_subcategoria"),
                result.getString("descripcion_subcategoria"),
                result.getBoolean("estado"),
                result.getBoolean("por_defecto")

        );
    }

    private ObligacionesUsuarios mapearObligacionesUsuarios(ResultSet result) throws SQLException {
        return new ObligacionesUsuarios(
                result.getString("usuario_dni"),
                result.getInt("id_subcategoria"),
                result.getString("nombre_obligacion"),
                result.getString("descripcion_obligacion"),
                result.getBigDecimal("monto_fijo"),
                result.getInt("vence_dia"),
                result.getBoolean("vigente"),
                result.getDate("fecha_inicio"),
                result.getDate("fecha_final")

        );
    }
}
