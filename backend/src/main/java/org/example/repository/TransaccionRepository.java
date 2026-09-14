package org.example.repository;

import org.example.config.DBConnection;

import org.example.dto.transaccion.ActualizarTransaccionRequest;
import org.example.dto.transaccion.CrearTransaccionRequest;
import org.example.exception.ApiExceptionController;
import org.example.model.Especiales.TransaccionEspecial;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class TransaccionRepository {
    private final DBConnection dbConnection = new DBConnection();

    public void CrearTransaccion(CrearTransaccionRequest transaccionrq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_insertar_transaccion(?,?,?,?,?,?,?,?,?,?,?,?,?)}")) {

            statement.setString(1, transaccionrq.p_usuario_dni());
            statement.setInt(2, transaccionrq.p_id_presupuesto());
            statement.setInt(3, transaccionrq.p_anio());
            statement.setInt(4, transaccionrq.p_mes());
            statement.setInt(5, transaccionrq.p_id_subcategoria());
            statement.setString(6, transaccionrq.p_tipo());
            statement.setString(7, transaccionrq.p_descripcion());
            statement.setBigDecimal(8, transaccionrq.p_monto());
            statement.setObject(9, transaccionrq.p_fecha_ocurrido());
            statement.setString(10, transaccionrq.p_metodo_pago());
            statement.setString(11, transaccionrq.p_num_factura());
            statement.setString(12, transaccionrq.p_observaciones());
            statement.setString(13, transaccionrq.p_creado_por());

            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("TIPO_TRANSACCION_NO_COINCIDE_CAT")){
                throw new ApiExceptionController(404, "TIPO_TRANSACCION_NO_COINCIDE_CAT",
                        "El tipo de transaccion no coincide con el tipo de categoria.");

            }
            else if  (err.getMessage().contains("ANIO_Y_MES_NO_DENTRO_DE_VIGENCIA_PRESUPUESTO")){
                throw new ApiExceptionController(404, "ANIO_Y_MES_NO_DENTRO_DE_VIGENCIA_PRESUPUESTO",
                        "El anio y el mes no estan dentro de la vigencia del presupuesto.");

            }

            throw err;
        }
    }


    public void ActualizarTransaccion(int id, ActualizarTransaccionRequest transaccionrq) throws SQLException {

        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_actualizar_transaccion(?,?,?,?,?,?,?,?,?,?,?,?,?)}")) {

            statement.setInt(1, id);
            statement.setInt(2, transaccionrq.p_id_presupuesto());
            statement.setInt(3, transaccionrq.p_anio());
            statement.setInt(4, transaccionrq.p_mes());
            statement.setInt(5, transaccionrq.p_id_subcategoria());
            statement.setString(6, transaccionrq.p_tipo());
            statement.setString(7, transaccionrq.p_descripcion());
            statement.setBigDecimal(8, transaccionrq.p_monto());
            statement.setObject(9, transaccionrq.p_fecha_ocurrido());
            statement.setString(10, transaccionrq.p_metodo_pago());
            statement.setString(11, transaccionrq.p_num_factura());
            statement.setString(12, transaccionrq.p_observaciones());
            statement.setString(13, transaccionrq.p_creado_por());

            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("TRANSACCION_NO_EXISTE")){
                throw new ApiExceptionController(404, "TRANSACCION_NO_EXISTE",
                        "La transaccion no existe en el sistema.");

            }
            else if  (err.getMessage().contains("TIPO_TRANSACCION_NO_COINCIDE_CAT")){
                throw new ApiExceptionController(404, "TIPO_TRANSACCION_NO_COINCIDE_CAT",
                        "El tipo de transaccion no coincide con el tipo de categoria.");

            }
            else if  (err.getMessage().contains("ANIO_Y_MES_NO_DENTRO_DE_VIGENCIA_PRESUPUESTO")){
                throw new ApiExceptionController(404, "ANIO_Y_MES_NO_DENTRO_DE_VIGENCIA_PRESUPUESTO",
                        "El anio y el mes no estan dentro de la vigencia del presupuesto.");

            }

            throw err;
        }
    }

    public void EliminarTransaccion(int id) throws SQLException{
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_eliminar_transaccion(?)}")) {
            statement.setInt(1, id);
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("TRANSACCION_NO_EXISTE")){
                throw new ApiExceptionController(404, "TRANSACCION_NO_EXISTE",
                        "La transaccion no existe en el sistema.");

            } else if  (err.getMessage().contains("TRANSACCION_TIPO_AHORRO")){
                throw new ApiExceptionController(404, "TRANSACCION_TIPO_AHORRO",
                        "La transaccion es de tipo AHORRO, no se puede eliminar.");

            }
            throw err;
        }
    }

    public TransaccionEspecial consultarTransaccion(int id) throws SQLException {
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_consultar_transaccion(?)}")) {

            statement.setInt(1, id);

            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearTransaccion(resultado);
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("TRANSACCION_NO_EXISTE")){
                throw new ApiExceptionController(404, "TRANSACCION_NO_EXISTE",
                        "La transaccion no existe en el sistema.");

            }
            throw err;
        }
        return null;
    }


    public List<TransaccionEspecial> Listar(String id) throws SQLException{

        List<TransaccionEspecial> transaccionEspeciales = new ArrayList<>();

        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_listar_transacciones(?)}")){
            statement.setString(1, id);
            try (ResultSet resultado = statement.executeQuery()) {
                while (resultado.next()) {
                    transaccionEspeciales.add(mapearTransaccion(resultado));
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("PRESUPUESTO_NO_EXISTE")){
                throw new ApiExceptionController(404, "PRESUPUESTO_NO_EXISTE",
                        "El presupuesto no existe en el sistema.");

            }
            throw err;
        }

        return transaccionEspeciales;
    }


    private TransaccionEspecial mapearTransaccion(ResultSet result) throws SQLException {
        return new TransaccionEspecial(
                result.getString("usuario_dni"),
                result.getInt("id_presupuesto"),
                result.getInt("anio"),
                result.getInt("mes"),
                result.getInt("id_subcategoria"),
                result.getString("tipo"),
                result.getString("descripcion"),
                result.getBigDecimal("monto"),
                (LocalDateTime) result.getObject("fecha_ocurrido"),
                result.getString("num_factura"),
                result.getString("observaciones"),
                (LocalDateTime) result.getObject("fecha_registro")
        );
    }
}
