package org.example.repository;

import org.example.config.DBConnection;
import org.example.dto.usuario.CrearUsuarioRequest;

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
        }

    }
}
