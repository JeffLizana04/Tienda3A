<%-- Archivo: WebContent/cierreMensual.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Proyecto3A.model.CierreMensual" %>
<%@ page import="java.util.List" %>
<%
    // Verificar sesión y permisos
    String rol = (String) session.getAttribute("rolUsuario");
    Integer rolId = (Integer) session.getAttribute("rolId");
    Integer tiendaId = (Integer) session.getAttribute("tiendaId");
    
    if (rol == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // Solo jefetienda (1) y administrador (3)
    if (rolId != 1 && rolId != 3) {
        response.sendError(403, "Acceso denegado");
        return;
    }
    
    List<CierreMensual> cierres = (List<CierreMensual>) request.getAttribute("cierres");
    Double totalVentas = (Double) request.getAttribute("totalVentas");
    Double totalCostos = (Double) request.getAttribute("totalCostos");
    Double totalGanancia = (Double) request.getAttribute("totalGanancia");
    List<Integer> anios = (List<Integer>) request.getAttribute("anios");
    
    // Mensajes
    String mensaje = request.getParameter("mensaje");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Cierre Mensual - Tiendas 3A</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    
    <!-- Chart.js para gráficos -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .navbar {
            background-color: #ff6600;
        }
        
        .card {
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transition: transform 0.3s ease;
        }
        
        .card:hover {
            transform: translateY(-3px);
        }
        
        .card-header {
            border-radius: 12px 12px 0 0 !important;
            background-color: #004aad;
            color: white;
            font-weight: 600;
        }
        
        .estado-cerrado {
            background-color: #d4edda;
            color: #155724;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
        }
        
        .estado-pendiente {
            background-color: #fff3cd;
            color: #856404;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
        }
        
        .btn-orange {
            background-color: #ff6600;
            border: none;
            color: white;
            border-radius: 25px;
            padding: 8px 25px;
            transition: background-color 0.2s ease;
        }
        
        .btn-orange:hover {
            background-color: #e05500;
            color: white;
        }
        
        .btn-outline-orange {
            border: 2px solid #ff6600;
            color: #ff6600;
            border-radius: 25px;
            padding: 8px 20px;
            background: transparent;
        }
        
        .btn-outline-orange:hover {
            background-color: #ff6600;
            color: white;
        }
        
        .table-hover tbody tr:hover {
            background-color: rgba(255, 102, 0, 0.05);
        }
        
        .kpi-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
        }
        
        .kpi-card h3 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 0;
        }
        
        .kpi-card i {
            font-size: 2.8rem;
            opacity: 0.9;
        }
        
        .valor-positivo {
            color: #28a745;
            font-weight: 600;
        }
        
        .valor-negativo {
            color: #dc3545;
            font-weight: 600;
        }
        
        .mes-badge {
            background-color: #004aad;
            color: white;
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 500;
        }
    </style>
</head>
<body>

    <!-- NAVBAR -->
    <nav class="navbar navbar-expand-lg shadow-sm">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center" href="principal.jsp">
                <img src="imagenes/logo.png" alt="Logo Tiendas 3A" height="55">
                <span class="ms-2 fw-bold">Tiendas 3A</span>
            </a>
            
            <div class="d-flex align-items-center gap-3">
                <span class="badge bg-light text-dark">
                    <i class="bi bi-person-badge me-1"></i> <%= rol %>
                </span>
                <a href="principal.jsp" class="btn btn-sm btn-light">
                    <i class="bi bi-arrow-left me-1"></i> Volver
                </a>
            </div>
        </div>
    </nav>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="container py-5">
        <!-- Encabezado -->
        <div class="row mb-5">
            <div class="col-md-8">
                <h1 class="fw-bold text-primary">
                    <i class="bi bi-calendar-month me-2"></i> Cierre Mensual
                </h1>
                <p class="text-muted">Gestión y análisis de cierres mensuales de ventas e inventario</p>
            </div>
           
        </div>

        <!-- Mensajes -->
        <% if (mensaje != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <% if (mensaje.equals("creado")) { %>
            <i class="bi bi-check-circle-fill me-2"></i> Cierre mensual creado exitosamente.
            <% } %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <% if (error.equals("creacion")) { %>
            Error al crear el cierre mensual.
            <% } else if (error.equals("no_encontrado")) { %>
            Cierre mensual no encontrado.
            <% } else if (error.equals("id_invalido")) { %>
            ID de cierre inválido.
            <% } else { %>
            Error al procesar la solicitud.
            <% } %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- KPI Cards -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="kpi-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <h6 class="text-light opacity-75">VENTAS TOTALES</h6>
                            <h3>S/ <%= String.format("%,.2f", totalVentas != null ? totalVentas : 0) %></h3>
                        </div>
                        <i class="bi bi-cash-coin"></i>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="kpi-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <h6 class="text-light opacity-75">COSTOS TOTALES</h6>
                            <h3>S/ <%= String.format("%,.2f", totalCostos != null ? totalCostos : 0) %></h3>
                        </div>
                        <i class="bi bi-cash-stack"></i>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="kpi-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <h6 class="text-light opacity-75">GANANCIA NETA</h6>
                            <h3>S/ <%= String.format("%,.2f", totalGanancia != null ? totalGanancia : 0) %></h3>
                        </div>
                        <i class="bi bi-graph-up-arrow"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filtros -->
        <div class="card shadow mb-4">
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Filtrar por Año:</label>
                        <select class="form-select" id="filtroAnio" onchange="filtrarPorAnio()">
                            <option value="todos">Todos los años</option>
                            <% if (anios != null) { 
                                for (Integer anio : anios) { %>
                            <option value="<%= anio %>"><%= anio %></option>
                            <% }
                            } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Filtrar por Mes:</label>
                        <select class="form-select" id="filtroMes" onchange="filtrarPorMes()">
                            <option value="todos">Todos los meses</option>
                            <option value="1">Enero</option>
                            <option value="2">Febrero</option>
                            <option value="3">Marzo</option>
                            <option value="4">Abril</option>
                            <option value="5">Mayo</option>
                            <option value="6">Junio</option>
                            <option value="7">Julio</option>
                            <option value="8">Agosto</option>
                            <option value="9">Septiembre</option>
                            <option value="10">Octubre</option>
                            <option value="11">Noviembre</option>
                            <option value="12">Diciembre</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Filtrar por Tienda:</label>
                        <select class="form-select" id="filtroTienda" onchange="filtrarPorTienda()">
                            <option value="todos">Todas las tiendas</option>
                            <option value="1">Tienda 3A San Juan</option>
                            <option value="2">Tienda 3A Los Olivos</option>
                            <option value="3">Tienda 3A Surco</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tabla de Cierres -->
        <div class="card shadow">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="bi bi-list-check me-2"></i> Historial de Cierres Mensuales
                </h5>
                <span class="badge bg-light text-dark fs-6">
                    <%= cierres != null ? cierres.size() : 0 %> registros
                </span>
            </div>
            <div class="card-body">
                <% if (cierres == null || cierres.isEmpty()) { %>
                <div class="text-center py-5">
                    <i class="bi bi-calendar-x" style="font-size: 4rem; color: #dee2e6;"></i>
                    <h5 class="mt-3 text-muted">No hay cierres mensuales registrados</h5>
                    <p class="text-muted">Los cierres se generan automáticamente al final de cada mes</p>
                </div>
                <% } else { %>
                <div class="table-responsive">
                    <table class="table table-hover align-middle" id="tablaCierres">
                        <thead class="table-light">
                            <tr>
                                <th>Periodo</th>
                                <th>Tienda</th>
                                <th>Ventas Totales</th>
                                <th>Costos Totales</th>
                                <th>Ganancia Neta</th>
                                <th>Margen %</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (CierreMensual cierre : cierres) { 
                                double ganancia = cierre.getGanancia();
                                double margen = cierre.getMargenGanancia();
                                String tiendaNombre = "Tienda " + cierre.getTiendaid();
                                switch(cierre.getTiendaid()) {
                                    case 1: tiendaNombre = "Tienda 3A San Juan"; break;
                                    case 2: tiendaNombre = "Tienda 3A Los Olivos"; break;
                                    case 3: tiendaNombre = "Tienda 3A Surco"; break;
                                }
                            %>
                            <tr data-anio="<%= cierre.getAnio() %>" data-mes="<%= cierre.getMes() %>" data-tienda="<%= cierre.getTiendaid() %>">
                                <td>
                                    <span class="mes-badge"><%= cierre.getMesNombre() %></span>
                                    <span class="fw-bold ms-2"><%= cierre.getAnio() %></span>
                                </td>
                                <td>
                                    <i class="bi bi-shop me-1"></i>
                                    <span class="text-muted"><%= tiendaNombre %></span>
                                </td>
                                <td>
                                    <span class="fw-bold">S/ <%= String.format("%,.2f", cierre.getTotalventas()) %></span>
                                </td>
                                <td>
                                    <span class="text-muted">S/ <%= String.format("%,.2f", cierre.getTotalcostos()) %></span>
                                </td>
                                <td>
                                    <span class="<%= ganancia >= 0 ? "valor-positivo" : "valor-negativo" %> fw-bold">
                                        S/ <%= String.format("%,.2f", Math.abs(ganancia)) %>
                                        <%= ganancia >= 0 ? "▲" : "▼" %>
                                    </span>
                                </td>
                                <td>
                                    <span class="<%= margen >= 0 ? "valor-positivo" : "valor-negativo" %>">
                                        <%= String.format("%.1f%%", margen) %>
                                    </span>
                                </td>
                                <td>
                                    <span class="estado-<%= cierre.getEstado() %>">
                                        <i class="bi bi-circle-fill" style="font-size: 0.6rem;"></i>
                                        <%= cierre.getEstado().toUpperCase() %>
                                    </span>
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm" role="group">
                                        <a href="CierreMensualServlet?opcion=ver&id=<%= cierre.getId() %>" 
                                           class="btn btn-outline-primary" title="Ver detalle">
                                            <i class="bi bi-eye"></i>
                                        </a>
                                        <% if (rolId == 3) { // Solo admin puede exportar %>
                                        <button class="btn btn-outline-success" title="Exportar PDF"
                                                onclick="exportarPDF(<%= cierre.getId() %>)">
                                            <i class="bi bi-file-earmark-pdf"></i>
                                        </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>
            <div class="card-footer text-muted">
                <small>
                    <i class="bi bi-info-circle me-1"></i>
                    Última actualización: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %>
                </small>
            </div>
        </div>

        <!-- Gráficos -->
        <div class="row mt-5">
            <div class="col-md-6">
                <div class="card shadow">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-pie-chart me-2"></i> Distribución de Ventas por Tienda</h6>
                    </div>
                    <div class="card-body">
                        <canvas id="ventasTiendaChart" height="250"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card shadow">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-calendar3 me-2"></i> Tendencia Anual</h6>
                    </div>
                    <div class="card-body">
                        <canvas id="tendenciaAnualChart" height="250"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- FOOTER -->
    <footer class="footer mt-5">
        <div class="container py-3">
            <p class="mb-0 text-center">
                © 2025 Tiendas 3A — Sistema de Cierre Mensual | 
                <a href="principal.jsp" class="text-light text-decoration-underline">Volver al Panel Principal</a>
            </p>
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Script para filtros y gráficos -->
    <script>
        // Funciones de filtrado
        function filtrarPorAnio() {
            const anio = document.getElementById('filtroAnio').value;
            const filas = document.querySelectorAll('#tablaCierres tbody tr');
            
            filas.forEach(fila => {
                const filaAnio = fila.getAttribute('data-anio');
                if (anio === 'todos' || filaAnio === anio) {
                    fila.style.display = '';
                } else {
                    fila.style.display = 'none';
                }
            });
        }
        
        function filtrarPorMes() {
            const mes = document.getElementById('filtroMes').value;
            const filas = document.querySelectorAll('#tablaCierres tbody tr');
            
            filas.forEach(fila => {
                const filaMes = fila.getAttribute('data-mes');
                if (mes === 'todos' || filaMes === mes) {
                    fila.style.display = '';
                } else {
                    fila.style.display = 'none';
                }
            });
        }
        
        function filtrarPorTienda() {
            const tienda = document.getElementById('filtroTienda').value;
            const filas = document.querySelectorAll('#tablaCierres tbody tr');
            
            filas.forEach(fila => {
                const filaTienda = fila.getAttribute('data-tienda');
                if (tienda === 'todos' || filaTienda === tienda) {
                    fila.style.display = '';
                } else {
                    fila.style.display = 'none';
                }
            });
        }
        
        // Exportar PDF (simulado)
        function exportarPDF(id) {
            if (confirm('¿Desea exportar este cierre mensual a PDF?')) {
                alert('Función de exportación a PDF en desarrollo. El archivo se descargará automáticamente.');
                // En una implementación real, aquí se haría una petición al servidor
                window.location.href = 'CierreMensualServlet?opcion=exportar&id=' + id;
            }
        }
        
        // Gráfico de distribución de ventas por tienda
        <% if (cierres != null && !cierres.isEmpty()) { 
            double ventasTienda1 = 0, ventasTienda2 = 0, ventasTienda3 = 0;
            for (CierreMensual c : cierres) {
                switch(c.getTiendaid()) {
                    case 1: ventasTienda1 += c.getTotalventas(); break;
                    case 2: ventasTienda2 += c.getTotalventas(); break;
                    case 3: ventasTienda3 += c.getTotalventas(); break;
                }
            }
        %>
        const ventasCtx = document.getElementById('ventasTiendaChart').getContext('2d');
        new Chart(ventasCtx, {
            type: 'doughnut',
            data: {
                labels: ['San Juan', 'Los Olivos', 'Surco'],
                datasets: [{
                    data: [<%= ventasTienda1 %>, <%= ventasTienda2 %>, <%= ventasTienda3 %>],
                    backgroundColor: [
                        '#ff6600',
                        '#004aad',
                        '#28a745'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                let label = context.label || '';
                                if (label) {
                                    label += ': ';
                                }
                                label += 'S/ ' + context.parsed.toLocaleString('es-PE', {minimumFractionDigits: 2});
                                return label;
                            }
                        }
                    }
                }
            }
        });
        <% } %>
        
        // Gráfico de tendencia anual
        <% if (cierres != null && !cierres.isEmpty()) { 
            // Agrupar ventas por mes
            double[] ventasPorMes = new double[12];
            for (CierreMensual c : cierres) {
                if (c.getAnio() == 2025) { // Año actual
                    int mes = c.getMes() - 1;
                    if (mes >= 0 && mes < 12) {
                        ventasPorMes[mes] += c.getTotalventas();
                    }
                }
            }
        %>
        const tendenciaCtx = document.getElementById('tendenciaAnualChart').getContext('2d');
        new Chart(tendenciaCtx, {
            type: 'line',
            data: {
                labels: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
                datasets: [{
                    label: 'Ventas 2025',
                    data: [<%= String.join(",", java.util.Arrays.stream(ventasPorMes)
                        .mapToObj(d -> String.format("%.2f", d))
                        .toArray(String[]::new)) %>],
                    backgroundColor: 'rgba(255, 102, 0, 0.1)',
                    borderColor: '#ff6600',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return 'S/ ' + value.toLocaleString('es-PE');
                            }
                        }
                    }
                },
                plugins: {
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return 'S/ ' + context.parsed.y.toLocaleString('es-PE', {minimumFractionDigits: 2});
                            }
                        }
                    }
                }
            }
        });
        <% } %>
        
        // Inicializar filtros si hay parámetros en la URL
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            const anio = urlParams.get('anio');
            const mes = urlParams.get('mes');
            
            if (anio) {
                document.getElementById('filtroAnio').value = anio;
                filtrarPorAnio();
            }
            if (mes) {
                document.getElementById('filtroMes').value = mes;
                filtrarPorMes();
            }
        };
    </script>
</body>
</html>