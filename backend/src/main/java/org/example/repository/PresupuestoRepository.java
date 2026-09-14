package org.example.repository;

import org.example.config.DBConnection;
import org.example.dto.categoria.ActualizarCategoriaRequest;
import org.example.dto.categoria.CrearCategoriaRequest;
import org.example.dto.presupuesto.ActualizarPresupuestoRequest;
import org.example.dto.presupuesto.CrearPresupuestoRequest;
import org.example.dto.presupuesto.ListarPresupuestoUsuarioRequest;
import org.example.exception.ApiExceptionController;
import org.example.model.Categoria;
import org.example.model.Presupuesto;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class PresupuestoRepository {

    private final DBConnection dbConnection = new DBConnection();

    public void CrearPresupuesto(CrearPresupuestoRequest presupuestorq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_insertar_presupuesto(?,?,?,?,?,?,?,?,?,?,?)}")) {

            statement.setString(1, presupuestorq.p_usuario_dni());
            statement.setString(2, presupuestorq.p_nombre());
            statement.setString(3, presupuestorq.p_descripcion());
            statement.setInt(4, presupuestorq.p_anio_inicio());
            statement.setInt(5, presupuestorq.p_mes_inicio());
            statement.setInt(6, presupuestorq.p_anio_final());
            statement.setInt(7, presupuestorq.p_mes_final());
            statement.setBigDecimal(8, presupuestorq.p_total_ingresos());
            statement.setBigDecimal(9, presupuestorq.p_total_gastos());
            statement.setBigDecimal(10, presupuestorq.p_total_ahorro());
            statement.setString(11, presupuestorq.p_creado_por());

            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("ANIO_FINAL_MENOR")){
                throw new ApiExceptionController(404, "ANIO_FINAL_MENOR",
                        "El anio final no puede ser menor que el anio inicial.");

            } else if (err.getMessage().contains("MES_FINAL_MENOR")){
                throw new ApiExceptionController(404, "MES_FINAL_MENOR",
                        "El mes final no puede ser menor que el mes inicial.");
            } else if (err.getMessage().contains("TRASLAPACION")){
                throw new ApiExceptionController(404, "TRASLAPACION",
                        "Las fechas se traslapan con un presupuesto ya activo.");
            }

            throw err;
        }
    }


    public void ActualizarPresupuesto(int id, ActualizarPresupuestoRequest presupuestorq) throws SQLException {

        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_actualizar_presupuesto(?,?,?,?,?,?,?,?,?,?,?,?,?)}")) {

            statement.setString(1, presupuestorq.p_usuario_dni());
            statement.setInt(2, id);
            statement.setString(3, presupuestorq.p_nombre());
            statement.setString(4, presupuestorq.p_descripcion());
            statement.setInt(5, presupuestorq.p_anio_inicio());
            statement.setInt(6, presupuestorq.p_mes_inicio());
            statement.setInt(7, presupuestorq.p_anio_final());
            statement.setInt(8, presupuestorq.p_mes_final());
            statement.setBigDecimal(9, presupuestorq.p_total_ingresos());
            statement.setBigDecimal(10, presupuestorq.p_total_gastos());
            statement.setBigDecimal(11, presupuestorq.p_total_ahorro());
            statement.setString(12, presupuestorq.p_estado());
            statement.setString(13, presupuestorq.p_modificado_por());
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("ANIO_FINAL_MENOR")){
                throw new ApiExceptionController(404, "ANIO_FINAL_MENOR",
                        "El anio final no puede ser menor que el anio inicial.");

            } else if (err.getMessage().contains("MES_FINAL_MENOR")){
                throw new ApiExceptionController(404, "MES_FINAL_MENOR",
                        "El mes final no puede ser menor que el mes inicial.");
            } else if (err.getMessage().contains("TRASLAPACION")){
                throw new ApiExceptionController(404, "TRASLAPACION",
                        "Las fechas se traslapan con un presupuesto ya activo.");
            } else if (err.getMessage().contains("PRESUPUESTO_NO_EXISTE")){
            throw new ApiExceptionController(404, "PRESUPUESTO_NO_EXISTE",
                    "El presupuesto no existe en el sistema.");
        }

            throw err;
        }
    }

    public void EliminarPresupuesto(int id) throws SQLException{
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_eliminar_presupuesto(?)}")) {
            statement.setInt(1, id);
            statement.execute();

        }catch(SQLException err){
            if (err.getMessage().contains("PRESUPUESTO_NO_EXISTE")){
                throw new ApiExceptionController(404, "PRESUPUESTO_NO_EXISTE",
                        "El presupuesto no existe en el sistema.");
            }

            else if (err.getMessage().contains("PRESUPUESTO_ASOCIADO")){
                throw new ApiExceptionController(404, "PRESUPUESTO_ASOCIADO",
                        "El presupuesto esta asociado a una transaccion.");
            }
            throw err;
        }
    }

    public Presupuesto consultarPresupuesto(int id) throws SQLException {
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_consultar_presupuesto(?)}")) {

            statement.setInt(1, id);

            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearPresupuesto(resultado);
                }
            }
        }catch(SQLException err){
            if (err.getMessage().contains("PRESUPUESTO_NO_EXISTE")){
                throw new ApiExceptionController(404, "PRESUPUESTO_NO_EXISTE",
                        "El presupuesto no existe en el sistema.");
            }


            throw err;
        }
        return null;
    }


    public List<Presupuesto> Listar(String usuario_dni, ListarPresupuestoUsuarioRequest presupuestorq) throws SQLException{

        List<Presupuesto> presupuestos = new ArrayList<>();

        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_listar_presupuestos_usuario(?,?)}")){

            statement.setString(1, usuario_dni);
            statement.setString(2, presupuestorq.p_estado());

            try (ResultSet resultado = statement.executeQuery()) {
                while (resultado.next()) {
                    presupuestos.add(mapearPresupuesto(resultado));
                }
            }
        }

        return presupuestos;
    }


    private Presupuesto mapearPresupuesto(ResultSet result) throws SQLException {
        return new Presupuesto(
                result.getInt("id_presupuesto"),
                result.getString("usuario_dni"),
                result.getString("nombre"),
                result.getString("descripcion"),
                result.getInt("anio_inicio"),
                result.getInt("mes_inicio"),
                result.getInt("anio_fin"),
                result.getInt("mes_fin"),
                result.getBigDecimal("total_ingresos"),
                result.getBigDecimal("total_gastos"),
                result.getBigDecimal("total_ahorro"),
                result.getObject("fecha_creacion", LocalDateTime.class),
                result.getString("estado")

        );
    }
}
