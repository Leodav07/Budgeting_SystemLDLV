package org.example.config;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;



public class DBConnection {
    Connection conn = null;
    public Connection getConnection() throws SQLException {
        try {
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost/budget_system",
                    "root",
                    "hihi1213");

            System.out.println("Connected to database");
            return conn;
        } catch (SQLException ex) {
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());

        }
        return conn;
    }
}

