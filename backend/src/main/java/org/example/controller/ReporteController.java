package org.example.controller;

import io.javalin.http.Context;
import org.example.config.login.LoginAuth;
import org.example.dto.login.LoginRequest;
import org.example.dto.reporteria.Reporte1Request;
import org.example.dto.reporteria.Reporte2Request;
import org.example.dto.reporteria.Reporte3Request;
import org.example.dto.reporteria.Reporte4Request;
import org.example.model.Especiales.ReporteAnalisis;
import org.example.model.Especiales.ReporteCumplimiento;
import org.example.model.Especiales.ReporteDistribucionGastos;
import org.example.model.Especiales.ReporteIngresoGasto;
import org.example.repository.ReporteRepository;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class ReporteController {
    private final ReporteRepository reporteRepository = new ReporteRepository();

    public void reporteIngresosGastos(Context ctx) throws SQLException {
        Reporte1Request reporterq = ctx.bodyAsClass(Reporte1Request.class);
      List<ReporteIngresoGasto> rpIngresosgastos =  reporteRepository.reporteria1(reporterq);
        ctx.json(rpIngresosgastos);

    }

    public void reporteDistribucionGastos(Context ctx) throws SQLException {
        Reporte2Request reporterq = ctx.bodyAsClass(Reporte2Request.class);
        List<ReporteDistribucionGastos> rpDistribucionGastos =  reporteRepository.reporteria2(reporterq);
        ctx.json(rpDistribucionGastos);


    }

    public void reporteAnalisis(Context ctx) throws SQLException {
        Reporte3Request reporterq = ctx.bodyAsClass(Reporte3Request.class);
        List<ReporteAnalisis> rpAnalisis =  reporteRepository.reporteria3(reporterq);
        ctx.json(rpAnalisis);
    }

    public void reporteCumplimiento(Context ctx) throws SQLException {
        Reporte4Request reporterq = ctx.bodyAsClass(Reporte4Request.class);
        List<ReporteCumplimiento> rpCumplimiento =  reporteRepository.reporteria4(reporterq);
        ctx.json(rpCumplimiento);

    }
}
