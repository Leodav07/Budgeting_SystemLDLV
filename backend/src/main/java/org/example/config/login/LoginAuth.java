package org.example.config.login;

import org.example.config.DBConnection;
import org.example.dto.login.LoginRequest;
import org.example.exception.ApiExceptionController;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

public class LoginAuth {

    PasswordAuthentication pAuth = new PasswordAuthentication();
    private final DBConnection dbConnection = new DBConnection();


    public LoginAuth(){}

    public boolean Auth(LoginRequest loginrq) throws SQLException {
        try(Connection connection = dbConnection.getConnection();
            CallableStatement statement =
                    connection.prepareCall("{CALL sp_auth(?,?,?)}")){

            PasswordAuthentication pAuth = new PasswordAuthentication();

            statement.setString(1, loginrq.dni());
            statement.setString(2,loginrq.p_contrasenia());
            statement.registerOutParameter(3, Types.VARCHAR);

            statement.execute();
            String token = statement.getString(3);
            if(pAuth.authenticate(loginrq.p_contrasenia().toCharArray(), token)){
                return true;
            }else{
                return false;
            }
        }catch(SQLException err){
            if  (err.getMessage().contains("USUARIO_NO_EXISTE")){
                throw new ApiExceptionController(409, "USUARIO_NO_EXISTE",
                        "Credenciales invalidas.");

            }

            throw err;
        }
    }

}
