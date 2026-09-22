package org.example.repository;

import org.example.config.DBConnection;
import org.example.config.login.PasswordAuthentication;
import org.example.dto.usuario.ActualizarUsuarioRequest;
import org.example.dto.usuario.CrearUsuarioRequest;
import org.example.dto.usuario.EliminarUsuarioRequest;
import org.example.exception.ApiExceptionController;
import org.example.model.Usuario;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class UsuarioRepository {

    private final DBConnection dbConnection = new DBConnection();

    public void CrearUsuario(CrearUsuarioRequest usuariorq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_insertar_usuario(?,?,?,?,?,?,?,?,?)}")){

            PasswordAuthentication pAuth = new PasswordAuthentication();

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

            statement.setString(9, pAuth.hash(usuariorq.p_contrasenia().toCharArray()));


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

    public void EliminarUsuario(String dni, EliminarUsuarioRequest usuariorq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_eliminar_usuario(?,?)}")) {
            statement.setString(1, dni);
            statement.setString(2, usuariorq.p_modificado_por());
            statement.execute();

        }catch(SQLException err){
            if  (err.getMessage().contains("USUARIO_NO_EXISTE")){
                throw new ApiExceptionController(404, "USUARIO_NO_EXISTE",
                        "El usuario no existe en el sistema.");

            }

            throw err;
        }
    }

    public Usuario consultarDNI(String dni) throws  SQLException{
        try (Connection connection = dbConnection.getConnection();
             CallableStatement statement =
                     connection.prepareCall("{CALL sp_consultar_usuario(?)}")) {

            statement.setString(1, dni);

            try (ResultSet resultado = statement.executeQuery()) {
                if (resultado.next()) {
                    return mapearUsuario(resultado);
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

    public List<Usuario> Listar() throws SQLException{

        List<Usuario> usuarios = new ArrayList<>();

        try (Connection connection = dbConnection.getConnection();
        CallableStatement statement = connection.prepareCall("{CALL sp_listar_usuarios()}")){

            try (ResultSet resultado = statement.executeQuery()) {
                while (resultado.next()) {
                    usuarios.add(mapearUsuario(resultado));
                }
            }
        }

        return usuarios;
    }

    private Usuario mapearUsuario(ResultSet result) throws SQLException {
        return new Usuario(
          result.getString("usuario_dni"),
          result.getString("primer_nombre"),
                result.getString("segundo_nombre"),
                result.getString("primer_apellido"),
                result.getString("segundo_apellido"),
                result.getString("email"),
                result.getObject("fecha_registro", LocalDateTime.class),
                result.getBigDecimal("salario"),
                result.getBoolean("estado")
        );
    }
}
