<%-- Archivo: WebContent/detalleCierre.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Proyecto3A.model.CierreMensual" %>
<%
    CierreMensual cierre = (CierreMensual) request.getAttribute("cierre");
    if (cierre == null) {
        response.sendRedirect("CierreMensualServlet?opcion=listar");
        return;
    }
    
    Integer rolId = (Integer) session.getAttribute("rolId");
    
    double ganancia = cierre.getGanancia();
    double margen = cierre.getMargenGanancia();
    String tiendaNombre = "Tienda " + cierre.getTiendaid();
    switch(cierre.getTiendaid()) {
        case 1: tiendaNombre = "Tienda 3A San Juan"; break;
        case 2: tiendaNombre = "Tienda 3A Los Olivos"; break;
        case 3: tiendaNombre = "Tienda 3A Surco"; break;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Detalle Cierre Mensual - Tiendas 3A</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    
    <style>
        body {
            background-color: #f8f9fa;
        }
        
        .card {
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        
        .valor-destacado {
            font-size: 2rem;
            font-weight: 700;
            color: #004aad;
        }
        
        .badge-estado {
            padding: 8px 16px;
            font-size: 1rem;
            border-radius: 25px;
        }
        
        .indicador {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100px;
            height: 100px;
            border-radius: 50%;
            margin: 0 auto;
            color: white;
            font-weight: bold;
            font-size: 1.5rem;
        }
        
        .positivo { background-color: #28a745; }
        .negativo { background-color: #dc3545; }
        .neutral { background-color: #6c757d; }
    </style>
</head>
<body>

    <!-- NAVBAR -->
    <nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center" href="principal.jsp">
                <img src="imagenes/logo.png" alt="Logo Tiendas 3A" height="55">
                <span class="ms-2 fw-bold">Tiendas 3A</span>
            </a>
            <div class="d-flex">
                <a href="CierreMensualServlet?opcion=listar" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-1"></i> Volver
                </a>
            </div>
        </div>
    </nav>

    <!-- CONTENIDO -->
    <div class="container py-5">
        <!-- Encabezado -->
        <div class="row mb-4">
            <div class="col">
                <h1 class="fw-bold">
                    <i class="bi bi-file-earmark-text me-2"></i> 
                    Cierre Mensual: <%= cierre.getMesNombre() %> <%= cierre.getAnio() %>
                </h1>
                <p class="text-muted">
                    <%= tiendaNombre %> | ID: <%= String.format("%04d", cierre.getId()) %>
                </p>
            </div>
            <div class="col-auto">
                <span class="badge-estado bg-success text-white">
                    <%= cierre.getEstado().toUpperCase() %>
                </span>
            </div>
        </div>

        <!-- KPI Cards -->
        <div class="row mb-4">
            <div class="col-md-3 mb-3">
                <div class="card h-100">
                    <div class="card-body text-center">
                        <h6 class="text-muted mb-3">VENTAS TOTALES</h6>
                        <div class="valor-destacado text-success">
                            S/ <%= String.format("%,.2f", cierre.getTotalventas()) %>
                        </div>
                        <small class="text-muted">Total facturado</small>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <div class="card h-100">
                    <div class="card-body text-center">
                        <h6 class="text-muted mb-3">COSTOS TOTALES</h6>
                        <div class="valor-destacado text-danger">
                            S/ <%= String.format("%,.2f", cierre.getTotalcostos()) %>
                        </div>
                        <small class="text-muted">Costos operativos</small>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <div class="card h-100">
                    <div class="card-body text-center">
                        <h6 class="text-muted mb-3">GANANCIA NETA</h6>
                        <div class="valor-destacado <%= ganancia >= 0 ? "text-success" : "text-danger" %>">
                            S/ <%= String.format("%,.2f", Math.abs(ganancia)) %>
                            <%= ganancia >= 0 ? "▲" : "▼" %>
                        </div>
                        <small class="text-muted">Ventas - Costos</small>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <div class="card h-100">
                    <div class="card-body text-center">
                        <h6 class="text-muted mb-3">MARGEN DE GANANCIA</h6>
                        <div class="valor-destacado <%= margen >= 0 ? "text-success" : "text-danger" %>">
                            <%= String.format("%.1f%%", margen) %>
                        </div>
                        <small class="text-muted">Porcentaje de rentabilidad</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Detalle -->
        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="bi bi-calculator me-2"></i> Análisis de Rentabilidad
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-borderless">
                                <tbody>
                                    <tr>
                                        <td class="fw-bold" width="40%">Ventas Totales:</td>
                                        <td class="text-end">S/ <%= String.format("%,.2f", cierre.getTotalventas()) %></td>
                                    </tr>
                                    <tr>
                                        <td class="fw-bold">(-) Costos Totales:</td>
                                        <td class="text-end text-danger">- S/ <%= String.format("%,.2f", cierre.getTotalcostos()) %></td>
                                    </tr>
                                    <tr class="border-top">
                                        <td class="fw-bold">(=) Ganancia Neta:</td>
                                        <td class="text-end">
                                            <span class="<%= ganancia >= 0 ? "text-success fw-bold" : "text-danger fw-bold" %>">
                                                S/ <%= String.format("%,.2f", Math.abs(ganancia)) %>
                                            </span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="fw-bold">Margen de Ganancia:</td>
                                        <td class="text-end">
                                            <span class="<%= margen >= 0 ? "text-success fw-bold" : "text-danger fw-bold" %>">
                                                <%= String.format("%.1f%%", margen) %>
                                            </span>
                                        </td>
                                    </tr>
                                    <tr class="border-top">
                                        <td class="fw-bold">Rendimiento:</td>
                                        <td class="text-end">
                                            <% if (margen > 20) { %>
                                            <span class="text-success fw-bold">⭐ Excelente</span>
                                            <% } else if (margen > 10) { %>
                                            <span class="text-success fw-bold">👍 Bueno</span>
                                            <% } else if (margen > 0) { %>
                                            <span class="text-warning fw-bold">⚠️ Aceptable</span>
                                            <% } else { %>
                                            <span class="text-danger fw-bold">❌ Crítico</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Indicadores -->
                        <div class="row mt-4">
                            <div class="col-md-6 text-center">
                                <div class="indicador <%= ganancia >= 0 ? "positivo" : "negativo" %>">
                                    <%= ganancia >= 0 ? "+" : "-" %>
                                </div>
                                <p class="mt-2 fw-bold">Resultado Financiero</p>
                            </div>
                            <div class="col-md-6 text-center">
                                <div class="indicador <%= margen > 15 ? "positivo" : margen > 5 ? "neutral" : "negativo" %>">
                                    <%= String.format("%.0f", margen) %>%
                                </div>
                                <p class="mt-2 fw-bold">Eficiencia Operativa</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="bi bi-info-circle me-2"></i> Información del Cierre
                        </h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item d-flex justify-content-between">
                                <span class="text-muted">Periodo:</span>
                                <span class="fw-bold"><%= cierre.getMesNombre() %> <%= cierre.getAnio() %></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between">
                                <span class="text-muted">Tienda:</span>
                                <span><%= tiendaNombre %></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between">
                                <span class="text-muted">ID Tienda:</span>
                                <span class="fw-bold">#<%= String.format("%03d", cierre.getTiendaid()) %></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between">
                                <span class="text-muted">Estado:</span>
                                <span class="fw-bold text-success">
                                    <%= cierre.getEstado().toUpperCase() %>
                                </span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between">
                                <span class="text-muted">ID Registro:</span>
                                <span class="fw-bold">#<%= String.format("%04d", cierre.getId()) %></span>
                            </li>
                        </ul>
                        
                        <!-- Botones de acción -->
                        <div class="mt-4">
                            <a href="CierreMensualServlet?opcion=listar" class="btn btn-outline-secondary w-100 mb-2">
                                <i class="bi bi-arrow-left me-1"></i> Volver al Listado
                            </a>
                            
                            <!-- Botón para generar PDF (simulado) -->
                            <button class="btn btn-outline-primary w-100 mt-2" 
                                    onclick="exportarPDF(<%= cierre.getId() %>)">
                                <i class="bi bi-file-earmark-pdf me-1"></i> Exportar a PDF
                            </button>
                            
                            <% if (rolId == 3) { // Solo admin %>
                            <!-- Botón para reabrir cierre (solo admin) -->
                            <button class="btn btn-outline-warning w-100 mt-2" 
                                    onclick="reabrirCierre(<%= cierre.getId() %>)">
                                <i class="bi bi-arrow-clockwise me-1"></i> Reabrir Cierre
                            </button>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Análisis Comparativo -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="bi bi-graph-up me-2"></i> Análisis Comparativo
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4 text-center">
                                <h6 class="text-muted">Productividad</h6>
                                <% 
                                    double productividad = (cierre.getTotalventas() / cierre.getTotalcostos()) * 100;
                                    String productividadClase = productividad > 150 ? "text-success" : 
                                                              productividad > 100 ? "text-warning" : "text-danger";
                                %>
                                <h3 class="<%= productividadClase %>">
                                    <%= String.format("%.0f", productividad) %>%
                                </h3>
                                <small class="text-muted">Ventas vs Costos</small>
                            </div>
                            <div class="col-md-4 text-center">
                                <h6 class="text-muted">Eficiencia</h6>
                                <h3 class="<%= margen > 15 ? "text-success" : margen > 5 ? "text-warning" : "text-danger" %>">
                                    <%= String.format("%.0f", margen) %>%
                                </h3>
                                <small class="text-muted">Margen Operativo</small>
                            </div>
                            <div class="col-md-4 text-center">
                                <h6 class="text-muted">Rentabilidad</h6>
                                <h3 class="<%= ganancia >= 0 ? "text-success" : "text-danger" %>">
                                    <%= ganancia >= 0 ? "+" : "-" %>S/ <%= String.format("%.0f", Math.abs(ganancia/1000)) %>K
                                </h3>
                                <small class="text-muted">Ganancia Neta</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function exportarPDF(id) {
            if (confirm('¿Desea exportar este cierre mensual a PDF?')) {
                alert('Función de exportación a PDF en desarrollo. El archivo se descargará automáticamente.');
                window.open('CierreMensualServlet?opcion=exportar&id=' + id, '_blank');
            }
        }
        
        function reabrirCierre(id) {
            if (confirm('¿Está seguro de reabrir este cierre mensual? Esto permitirá modificaciones.')) {
                if (confirm('⚠️ ADVERTENCIA: Reabrir un cierre mensual puede afectar los reportes financieros. ¿Continuar?')) {
                    window.location.href = 'CierreMensualServlet?opcion=reabrir&id=' + id;
                }
            }
        }
    </script>
</body>
</html>