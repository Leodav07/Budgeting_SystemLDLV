package org.example.repository;

import org.example.config.DBConnection;
import org.example.dto.usuario.ActualizarUsuarioRequest;
import org.example.dto.usuario.CrearUsuarioRequest;
import org.example.exception.ApiExceptionController;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

public class UsuarioRepository {

    private final DBConnection dbConnection = new DBConnection();

    public void CrearUsuario(CrearUsuarioRequest usuariorq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_insertar_usuario(?,?,?,?,?,?,?,?)}")){

            statement.setString(1, usuariorq.dni());
            statement.setString(2,usuariorq.p_nombre());

            if(usuariorq.s_nombre() == null){
                statement.setNull(3, Types.VARCHAR);
            }else{
                statement.setString(3, usuariorq.s_nombre());
            }

            statement.setString(4, usuariorq.p_apellido());



            if(usuariorq.s_apellido() == null){
                statement.setNull(5, Types.VARCHAR);
            }else{
                statement.setString(5, usuariorq.s_apellido());
            }

            statement.setString(6, usuariorq.correo_elec());
            statement.setBigDecimal(7, usuariorq.psalario());
            statement.setString(8, usuariorq.pcreado_por());

            statement.execute();
        }catch(SQLException err){
            if  (err.getMessage().contains("USUARIO_YA_EXISTE")){
                throw new ApiExceptionController(409, "USUARIO_YA_EXISTE",
                        "El usuario ya existe en el sistema.");

            }

            throw err;
        }

    }

    public void ActualizarUsuario(String usuario_dni, ActualizarUsuarioRequest usuariorq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_actualizar_usuario(?,?,?,?,?,?,?,?)}")) {

            statement.setString(1, usuario_dni);
            statement.setString(2,usuariorq.p_nombre());

            if(usuariorq.s_nombre() == null){
                statement.setNull(3, Types.VARCHAR);
            }else{
                statement.setString(3, usuariorq.s_nombre());
            }

            statement.setString(4, usuariorq.p_apellido());



            if(usuariorq.s_apellido() == null){
                statement.setNull(5, Types.VARCHAR);
            }else{
                statement.setString(5, usuariorq.s_apellido());
            }

            statement.setString(6, usuariorq.correo_elec());
            statement.setBigDecimal(7, usuariorq.psalario());
            statement.setString(8, usuariorq.p_modificado_por());

            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("USUARIO_NO_EXISTE")){
                throw new ApiExceptionController(404, "USUARIO_NO_EXISTE",
                        "El usuario no existe en el sistema.");

            }

            throw err;
        }

    }
}
