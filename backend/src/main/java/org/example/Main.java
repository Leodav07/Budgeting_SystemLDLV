package org.example;

import io.javalin.Javalin;
import io.javalin.config.RouterConfig;
import org.example.DBConnection;

import java.sql.SQLException;


public class Main {
    public static void main(String[] args) {

        DBConnection DB = new DBConnection();
        try {
            DB.getConnection();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

}



