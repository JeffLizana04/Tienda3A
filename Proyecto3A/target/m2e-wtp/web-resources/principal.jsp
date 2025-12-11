<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Proyecto3A.service.AlertaService" %>
<%@ page import="com.Proyecto3A.model.Catalogo" %>
<%@ page import="java.util.List" %>
<%
    // Verificar sesión
    String rol = (String) session.getAttribute("rolUsuario");
    if (rol == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    int rolId = (session.getAttribute("rolId") != null) ? (Integer) session.getAttribute("rolId") : 0;
    
    // Alertas de productos próximos a vencer
    AlertaService alertaService = new AlertaService();
    List<Catalogo> productosProximos = alertaService.obtenerAlertasVencimiento();
    boolean hayAlertas = alertaService.hayProductosProximosAVencer();
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Tiendas 3A - Panel de Control</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        body {
            background-color: #f5f6fa;
            font-family: 'Segoe UI', sans-serif;
        }

        .navbar {
            background-color: #ff6600; 
        }

        .navbar-brand {
            font-weight: bold;
            color: #ffffff !important;
            font-size: 1.6rem;
            display: flex;
            align-items: center;
        }

        .navbar-brand img {
            height: 55px;
            margin-right: 10px;
        }

        .dashboard-header {
            text-align: center;
            margin-bottom: 50px;
        }

        .dashboard-header h1 {
            color: #004aad;
            font-weight: 700;
        }

        .dashboard-header p {
            color: #6c757d;
            font-size: 1.1rem;
        }

        .card {
            border: none;
            border-radius: 15px;
            transition: all 0.25s ease;
            height: 100%; /* 🔹 igual altura */
        }

        .card:hover {
            transform: translateY(-6px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.1);
        }

        .card i {
            font-size: 2.5rem;
            margin-bottom: 10px;
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
        }

        .footer {
            background-color: #004aad;
            color: white;
            text-align: center;
            padding: 15px 0;
            margin-top: 50px;
        }

        /* 🔹 Forzar que todas las tarjetas tengan misma altura y contenido centrado */
        .equal-card {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            height: 100%;
        }

        .card p {
            min-height: 55px; /* iguala la altura del texto descriptivo */
        }
        
       .welcome-text {
            background: #ffffff;
            color: #ff6600;
            padding: 6px 16px;
            border-radius: 25px;
            font-weight: 600;
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }

        .badge-rol {
            background: #004aad;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }

    </style>
</head>
<body>

    <!-- NAVBAR -->
   <nav class="navbar navbar-expand-lg shadow-sm">
    <div class="container">
        <a class="navbar-brand" href="#">
            <img src="imagenes/logo.png" alt="Logo Tiendas 3A">
            Tiendas 3A
        </a>
        
        <div class="d-flex align-items-center gap-3">
            <span class="badge-rol">
                <i class="bi bi-person-badge"></i> <%= rol %>
            </span>
            <span class="welcome-text">
                <i class="bi bi-person-fill"></i>
                <%= session.getAttribute("nombreUsuario") %>
            </span>
            <!-- BOTÓN DE CERRAR SESIÓN -->
            <a href="logout.jsp" class="btn btn-outline-light btn-sm">
                <i class="bi bi-box-arrow-right"></i> Cerrar Sesión
		            </a>
		        </div>
		    </div>
		</nav>
    
    <!-- ALERTAS DE PRODUCTOS PRÓXIMOS A VENCER -->
    <% if (hayAlertas) { %>
    <div class="alert-container">
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <h5 class="alert-heading">⚠️ ALERTA: Productos próximos a vencer</h5>
            <div class="row">
                <% for (Catalogo producto : productosProximos) { %>
                <div class="col-md-6 mb-2">
                    <div class="d-flex justify-content-between align-items-center">
                        <span><strong><%= producto.getProductos() %></strong> - Vence: <%= producto.getFechaVencimiento() %></span>
                        <% if (rolId == 1 || rolId == 3) { // Solo jefetienda y admin %>
                        <a href="sugerirOferta.jsp?id=<%= producto.getId() %>" class="btn btn-sm btn-outline-danger">
                            🏷️ Sugerir Oferta
                        </a>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </div>
    
    <style>
    .alert-container {
        margin: 20px auto;
        max-width: 95%;
    }
    .alert {
        border-radius: 12px;
        border-left: 5px solid #ffc107;
    }
    </style>
    <% } %>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="container py-5">
        <div class="dashboard-header">
            <h1>Panel de Administración</h1>
            <p>Gestión integral de productos, personal y operaciones internas</p>
        </div>

        <div class="row g-4 justify-content-center">

            <!-- Productos - Todos los roles -->
            <div class="col-md-4 d-flex">
                <div class="card text-center p-4 shadow-sm equal-card w-100">
                    <div>
                        <i class="bi bi-box-seam text-primary"></i>
                        <h5 class="card-title mt-2">Productos</h5>
                        <p class="text-muted">Gestión de inventario, precios y fechas de vencimiento.</p>
                    </div>
                    <a href="catalogo.jsp" class="btn btn-orange mt-3">Ir a Productos</a>
                </div>
            </div>

            <!-- Ofertas - Todos los roles -->
            <div class="col-md-4 d-flex">
                <div class="card text-center p-4 shadow-sm equal-card w-100">
                    <div>
                        <i class="bi bi-tag-fill text-success" style="font-size: 2rem;"></i>
                        <h5 class="card-title mt-2">Ofertas</h5>
                        <p class="text-muted">Descuentos automáticos y promociones activas.</p>
                    </div>
                    <a href="productosDescuento.jsp" class="btn btn-orange mt-3">
                        🏷️ Ver Ofertas
                    </a>
                </div>
            </div>

            <!-- Guías de Ingreso - Solo jefetienda y administrador (NO reponedor) -->
            <% if (rolId == 1 || rolId == 3) { // 1 = jefetienda, 3 = administrador %>
            <div class="col-md-4 d-flex">
                <div class="card text-center p-4 shadow-sm equal-card w-100">
                    <div>
                        <i class="bi bi-clipboard-check text-info"></i>
                        <h5 class="card-title mt-2">Guías de Ingreso</h5>
                        <p class="text-muted">Registro y gestión de guías de ingreso de productos al inventario.</p>
                    </div>
                    <a href="guia?opcion=listar" class="btn btn-orange mt-3">Ir a Guías</a>
                </div>
            </div>
            <% } %>

            <!-- Personal - Solo administrador (NO jefetienda) -->
            <% if (rolId == 3) { %>
            <div class="col-md-4 d-flex">
                <div class="card text-center p-4 shadow-sm equal-card w-100">
                    <div>
                        <i class="bi bi-people-fill text-warning"></i>
                        <h5 class="card-title mt-2">Personal</h5>
                        <p class="text-muted">Jefes de tienda, reponedores y empleados.</p>
                    </div>
                    <a href="home?opcion=gestionPersonal" class="btn btn-orange mt-3">Ir a Personal</a>
                </div>
            </div>
            <% } %>

            <!-- Reportes - Solo jefetienda y administrador -->
            <% if (rolId == 1 || rolId == 3) { %>
            <div class="col-md-4 d-flex">
                <div class="card text-center p-4 shadow-sm equal-card w-100">
                    <div>
                        <i class="bi bi-calendar-month text-info" style="font-size: 2.5rem;"></i>
                        <h5 class="card-title mt-2">Cierre Mensual</h5>
                        <p class="text-muted">Gestión y análisis de cierres mensuales de ventas.</p>
                    </div>
                    <a href="CierreMensualServlet" class="btn btn-orange mt-3">
                        Ir a Cierres
                    </a>
                </div>
            </div>
            <% } %>
            
            <!-- Auditoría - Solo administrador -->
            <% if (rolId == 3) { %>
            <div class="col-md-4 d-flex">
                <div class="card text-center p-4 shadow-sm equal-card w-100">
                    <div>
                        <i class="bi bi-clipboard-data text-info"></i>
                        <h5 class="card-title mt-2">Auditoría</h5>
                        <p class="text-muted">Registro completo de todos los cambios en el sistema.</p>
                    </div>
                    <a href="auditoria.jsp" class="btn btn-orange mt-3">
                        📊 Ver Auditoría
                    </a>
                </div>
            </div>
            <% } %>

        </div>
    </div>

    <!-- FOOTER -->
    <footer class="footer">
        <p class="mb-0">© 2025 Tiendas 3A — Sistema de Gestión Interna</p>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>