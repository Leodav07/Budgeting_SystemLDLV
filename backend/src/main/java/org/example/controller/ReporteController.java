package org.example.controller;

import io.javalin.http.Context;
import org.example.config.login.LoginAuth;
import org.example.dto.login.LoginRequest;
import org.example.dto.reporteria.Reporte1Request;
import org.example.dto.reporteria.Reporte2Request;
import org.example.dto.reporteria.Reporte3Request;
import org.example.repository.ReporteRepository;

import java.sql.SQLException;
import java.util.Map;

public class ReporteController {
    private final ReporteRepository reporteRepository = new ReporteRepository();

    public void reporteIngresosGastos(Context ctx) throws SQLException {
        Reporte1Request reporterq = ctx.bodyAsClass(Reporte1Request.class);
        reporteRepository.reporteria1(reporterq);
        ctx.status(201).json(Map.of("mensaje", "Usuario."));

    }

    public void reporteDistribucionGastos(Context ctx) throws SQLException {
        Reporte2Request reporterq = ctx.bodyAsClass(Reporte2Request.class);
        reporteRepository.reporteria2(reporterq);
        ctx.status(201).json(Map.of("mensaje", "Usuario."));

    }

    public void reporteAnalisis(Context ctx) throws SQLException {
        Reporte3Request reporterq = ctx.bodyAsClass(Reporte3Request.class);
        reporteRepository.reporteria3(reporterq);
        ctx.status(201).json(Map.of("mensaje", "Usuario."));

    }
}
