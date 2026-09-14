package org.example.repository;

import org.example.config.DBConnection;
import org.example.dto.presupuesto_detalle.ActualizarPresupuestoDetalle;
import org.example.dto.presupuesto_detalle.CrearPresupuestoDetalle;
import org.example.exception.ApiExceptionController;
import org.example.model.Especiales.ConsultaPresupuestoDetalle;
import org.example.model.Especiales.ListarPresupuestoDetalle;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class PresupuestoDetalleRepository {

    private final DBConnection dbConnection = new DBConnection();

    public void CrearPresupuestoDetalle(CrearPresupuestoDetalle pdetallerq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_insertar_presupuesto_detalle(?,?,?,?,?)}")) {

            statement.setInt(1, pdetallerq.p_id_presupuesto());
            statement.setInt(2, pdetallerq.p_id_subcategoria());
            statement.setBigDecimal(3, pdetallerq.p_monto_asignado());
            statement.setString(4, pdetallerq.p_justificacion_monto());
            statement.setString(5, pdetallerq.p_creado_por());

            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("PRESUPUESTO_NO_EXISTE")){
                throw new ApiExceptionController(404, "PRESUPUESTO_NO_EXISTE",
                        "El presupuesto no existe en el sistema.");

            }
            else if  (err.getMessage().contains("SUBCATEGORIA_NO_EXISTE")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_NO_EXISTE",
                        "La subcategoria no existe o esta desactivada.");

            }
            else if  (err.getMessage().contains("SUBCATEGORIA_YA_ASOCIADA")){
                throw new ApiExceptionController(404, "SUBCATEGORIA_YA_ASOCIADA",
                        "La subcategoria ya esta asociada a otro presupuesto.");

            }

            throw err;
        }
    }


    public void ActualizarPresupuestoDetalle(int id, ActualizarPresupuestoDetalle pdetallerq) throws SQLException {

        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_actualizar_presupuesto_detalle(?,?,?,?)}")) {

            statement.setInt(1, id);
            statement.setBigDecimal(2, pdetallerq.p_monto_asignado());
            statement.setString(3, pdetallerq.p_justificacion_monto());
            statement.setString(4, pdetallerq.p_modificado_por());
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("PRESUPUESTO_DETALLE_NO_EXISTE")){
                throw new ApiExceptionController(404, "PRESUPUESTO_DETALLE_NO_EXISTE",
                        "El presupuesto detalle no existe en el sistema.");

            }

            throw err;
        }
    }

    public void EliminarPresupuestoDetalle(int id) throws SQLException{
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_eliminar_presupuesto_detalle(?)}")) {
            statement.setInt(1, id);
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("PRESUPUESTO_DETALLE_NO_EXISTE")){
                throw new ApiExceptionController(404, "PRESUPUESTO_DETALLE_NO_EXISTE",
                        "El presupuesto detalle no existe en el sistema.");

            }
            throw err;
        }
    }

    public ConsultaPresupuestoDetalle consultarPresupuestoDetalle(int id) throws SQLException {
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_consultar_presupuesto_detalle(?)}")) {

            statement.setInt(1, id);

            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearPresupuestoDetalleCategoria(resultado);
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("PRESUPUESTO_DETALLE_NO_EXISTE")){
                throw new ApiExceptionController(404, "PRESUPUESTO_DETALLE_NO_EXISTE",
                        "El presupuesto detalle no existe en el sistema.");

            }
            throw err;
        }
        return null;
    }


    public List<ListarPresupuestoDetalle> Listar(String id) throws SQLException{

        List<ListarPresupuestoDetalle> presupuestoDetalles = new ArrayList<>();

        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_listar_detalles_presupuesto(?)}")){
            statement.setString(1, id);
            try (ResultSet resultado = statement.executeQuery()) {
                while (resultado.next()) {
                    presupuestoDetalles.add(mapearPresupuestoDetalles(resultado));
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("PRESUPUESTO_NO_EXISTE")){
                throw new ApiExceptionController(404, "PRESUPUESTO_NO_EXISTE",
                        "El presupuesto no existe en el sistema.");

            }
            throw err;
        }

        return presupuestoDetalles;
    }


    private ConsultaPresupuestoDetalle mapearPresupuestoDetalleCategoria(ResultSet result) throws SQLException {
        return new ConsultaPresupuestoDetalle(
                result.getInt("id_presupuesto"),
                result.getInt("id_subcategoria"),
                result.getBigDecimal("monto_asignado"),
                result.getString("justificacion_monto"),
                result.getInt("id_categoria"),
                result.getString("nombre_subcategoria"),
                result.getString("descripcion_subcategoria"),
                result.getBoolean("estado_subcategoria"),
                result.getBoolean("por_defecto"),
                result.getString("nombre_categoria"),
                result.getString("descripcion_categoria"),
                result.getString("tipo"),
                result.getString("icono_nombre"),
                result.getString("color_hex"),
                result.getInt("orden")

        );
    }


    private ListarPresupuestoDetalle mapearPresupuestoDetalles(ResultSet result) throws SQLException {
        return new ListarPresupuestoDetalle(
                result.getString("usuario_dni"),
                result.getString("nombre_presupuesto"),
                result.getString("descripcion_presupuesto"),
                result.getInt("anio_inicio"),
                result.getInt("mes_inicio"),
                result.getInt("anio_fin"),
                result.getInt("mes_fin"),
                result.getBigDecimal("total_ingresos"),
                result.getBigDecimal("total_gastos"),
                result.getBigDecimal("total_ahorro"),
                (LocalDateTime) result.getObject("fecha_creacion"),
                result.getString("estado_presupuesto"),
                result.getInt("id_presupuesto"),
                result.getInt("id_subcategoria"),
                result.getBigDecimal("monto_asignado"),
                result.getString("justificacion_monto"),
                result.getInt("id_categoria"),
                result.getString("nombre_subcategoria"),
                result.getString("descripcion_subcategoria"),
                result.getBoolean("estado_subcategoria"),
                result.getBoolean("por_defecto")

        );
    }
}
