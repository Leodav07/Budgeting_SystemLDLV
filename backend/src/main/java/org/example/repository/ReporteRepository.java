package org.example.repository;

import org.example.config.DBConnection;
import org.example.dto.reporteria.Reporte1Request;
import org.example.dto.reporteria.Reporte2Request;
import org.example.dto.reporteria.Reporte3Request;
import org.example.exception.ApiExceptionController;
import org.example.model.Especiales.ReporteAnalisis;
import org.example.model.Especiales.ReporteDistribucionGastos;
import org.example.model.Especiales.ReporteIngresoGasto;
import org.example.model.Usuario;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;

public class ReporteRepository {

    private final DBConnection dbConnection = new DBConnection();

    public ReporteIngresoGasto reporteria1(Reporte1Request reporterq) throws  SQLException{
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_reporte1(?,?,?,?,?)}")) {

            statement.setString(1, reporterq.dni());
            statement.setInt(2, reporterq.p_anio_d());
            statement.setInt(3, reporterq.p_mes_d());
            statement.setInt(4, reporterq.p_anio_h());
            statement.setInt(5, reporterq.p_mes_h());

            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearReporte1(resultado);
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("USUARIO_NO_EXISTE")){
                throw new ApiExceptionController(404, "USUARIO_NO_EXISTE",
                        "El usuario no existe en el sistema.");

            }

            throw err;
        }
        return null;

    }

    private ReporteIngresoGasto mapearReporte1(ResultSet result) throws SQLException {
        return new ReporteIngresoGasto(
                result.getBigDecimal("ingresos"),
                result.getBigDecimal("gastos"),
                result.getInt("anio"),
                result.getInt("mes"),
                result.getBigDecimal("balance")
        );
    }

    public ReporteDistribucionGastos reporteria2(Reporte2Request reporterq) throws  SQLException{
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_reporte2(?,?,?)}")) {

            statement.setString(1, reporterq.dni());
            statement.setInt(2, reporterq.p_anio());
            statement.setInt(3, reporterq.p_mes());

            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearReport2(resultado);
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("USUARIO_NO_EXISTE")){
                throw new ApiExceptionController(404, "USUARIO_NO_EXISTE",
                        "El usuario no existe en el sistema.");

            }

            throw err;
        }
        return null;

    }


    private ReporteDistribucionGastos mapearReport2(ResultSet result) throws SQLException {
        return new ReporteDistribucionGastos(
                result.getString("nombre_categoria"),
                result.getBigDecimal("monto_total"),
                result.getInt("conteo_transacciones"),
                result.getBigDecimal("gran_total"),
                result.getBigDecimal("porcentaje")
        );
    }

    public ReporteAnalisis reporteria3(Reporte3Request reporterq) throws  SQLException{
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_reporte3(?,?,?,?,?)}")) {

            statement.setString(1, reporterq.dni());
            statement.setInt(2, reporterq.p_anio());
            statement.setInt(3, reporterq.p_mes());
            statement.setString(4, reporterq.p_tipo());
            statement.setInt(5, reporterq.p_id_presupuesto());


            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearReporte3(resultado);
                }
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("USUARIO_NO_EXISTE")){
                throw new ApiExceptionController(404, "USUARIO_NO_EXISTE",
                        "El usuario no existe en el sistema.");

            }

            throw err;
        }
        return null;

    }


    private ReporteAnalisis mapearReporte3(ResultSet result) throws SQLException {
        return new ReporteAnalisis(
                result.getInt("id_presupuesto"),
                result.getInt("id_subcategoria"),
                result.getString("nombre_subcategoria"),
                result.getBigDecimal("monto_presupuestado"),
                result.getInt("id_categoria"),
                result.getString("nombre_categoria"),
                result.getBigDecimal("monto_gastado")


        );
    }
}
