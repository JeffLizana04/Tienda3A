// Archivo: com/Proyecto3A/controller/CierreMensualServlet.java
package com.Proyecto3A.servlets;

import com.Proyecto3A.dao.CierreMensualDao;
import com.Proyecto3A.model.CierreMensual;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/CierreMensualServlet")
public class CierreMensualServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private CierreMensualDao cierreDao;
    
    @Override
    public void init() {
        cierreDao = new CierreMensualDao();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar sesión
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("rolId") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        
        // Verificar permisos - Solo jefetienda (1) y administrador (3)
        int rolId = (Integer) session.getAttribute("rolId");
        if (rolId != 1 && rolId != 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                "No tiene permisos para acceder a esta página");
            return;
        }
        
        String opcion = request.getParameter("opcion");
        if (opcion == null) {
            opcion = "listar";
        }
        
        try {
            switch (opcion) {
                case "listar":
                    listarCierres(request, response);
                    break;
                case "ver":
                    verDetalle(request, response);
                    break;
                case "estadisticas":
                    mostrarEstadisticas(request, response);
                    break;
                case "resumen":
                    mostrarResumen(request, response);
                    break;
                default:
                    listarCierres(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("CierreMensualServlet?opcion=listar&error=true");
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("rolId") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        
        // Solo administrador puede crear nuevos cierres
        int rolId = (Integer) session.getAttribute("rolId");
        if (rolId != 3) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                "Solo el administrador puede crear cierres mensuales");
            return;
        }
        
        String opcion = request.getParameter("opcion");
        
        if (opcion != null && opcion.equals("crear")) {
            crearCierre(request, response);
        }
    }
    
    private void listarCierres(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<CierreMensual> cierres = cierreDao.listarCierresMensuales();
        request.setAttribute("cierres", cierres);
        
        // Calcular totales
        double totalVentas = 0;
        double totalCostos = 0;
        double totalGanancia = 0;
        
        for (CierreMensual cierre : cierres) {
            totalVentas += cierre.getTotalventas();
            totalCostos += cierre.getTotalcostos();
            totalGanancia += cierre.getGanancia();
        }
        
        request.setAttribute("totalVentas", totalVentas);
        request.setAttribute("totalCostos", totalCostos);
        request.setAttribute("totalGanancia", totalGanancia);
        
        // Obtener años disponibles
        List<Integer> anios = cierreDao.obtenerAniosDisponibles();
        request.setAttribute("anios", anios);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/cierreMensual.jsp");
        dispatcher.forward(request, response);
    }
    
    private void verDetalle(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            CierreMensual cierre = cierreDao.obtenerCierrePorId(id);
            
            if (cierre != null) {
                request.setAttribute("cierre", cierre);
                RequestDispatcher dispatcher = request.getRequestDispatcher("/detalleCierre.jsp");
                dispatcher.forward(request, response);
            } else {
                response.sendRedirect("CierreMensualServlet?opcion=listar&error=no_encontrado");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("CierreMensualServlet?opcion=listar&error=id_invalido");
        }
    }
    
    private void mostrarEstadisticas(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int anio = request.getParameter("anio") != null ? 
                   Integer.parseInt(request.getParameter("anio")) : 2025;
        
        List<CierreMensual> cierresAnuales = cierreDao.obtenerEstadisticasAnuales(anio);
        request.setAttribute("cierresAnuales", cierresAnuales);
        request.setAttribute("anioSeleccionado", anio);
        
        // Obtener años disponibles
        List<Integer> anios = cierreDao.obtenerAniosDisponibles();
        request.setAttribute("anios", anios);
        
        // Calcular total anual
        double totalVentasAnual = 0;
        double totalCostosAnual = 0;
        for (CierreMensual cierre : cierresAnuales) {
            totalVentasAnual += cierre.getTotalventas();
            totalCostosAnual += cierre.getTotalcostos();
        }
        
        request.setAttribute("totalVentasAnual", totalVentasAnual);
        request.setAttribute("totalCostosAnual", totalCostosAnual);
        request.setAttribute("totalGananciaAnual", totalVentasAnual - totalCostosAnual);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/estadisticasCierre.jsp");
        dispatcher.forward(request, response);
    }
    
    private void mostrarResumen(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int anio = request.getParameter("anio") != null ? 
                   Integer.parseInt(request.getParameter("anio")) : 2025;
        
        List<Object[]> resumenAnual = cierreDao.obtenerResumenAnual(anio);
        request.setAttribute("resumenAnual", resumenAnual);
        request.setAttribute("anioSeleccionado", anio);
        
        // Obtener años disponibles
        List<Integer> anios = cierreDao.obtenerAniosDisponibles();
        request.setAttribute("anios", anios);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/resumenCierre.jsp");
        dispatcher.forward(request, response);
    }
    
    private void crearCierre(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            CierreMensual cierre = new CierreMensual();
            
            cierre.setTiendaid(Integer.parseInt(request.getParameter("tiendaid")));
            cierre.setAnio(Integer.parseInt(request.getParameter("anio")));
            cierre.setMes(Integer.parseInt(request.getParameter("mes")));
            cierre.setTotalventas(Double.parseDouble(request.getParameter("totalventas")));
            cierre.setTotalcostos(Double.parseDouble(request.getParameter("totalcostos")));
            cierre.setEstado("cerrado");
            
            boolean insertado = cierreDao.insertarCierreMensual(cierre);
            
            if (insertado) {
                response.sendRedirect("CierreMensualServlet?opcion=listar&mensaje=creado");
            } else {
                response.sendRedirect("CierreMensualServlet?opcion=listar&error=creacion");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("CierreMensualServlet?opcion=listar&error=creacion");
        }
    }
}