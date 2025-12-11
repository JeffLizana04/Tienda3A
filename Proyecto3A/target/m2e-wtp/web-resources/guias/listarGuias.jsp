<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Proyecto3A.model.Guia" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<Guia> guias = (List<Guia>) request.getAttribute("guias");
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    
    if (mensaje != null) {
        session.removeAttribute("mensaje");
    }
    if (error != null) {
        session.removeAttribute("error");
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Guias de Ingreso - Tiendas 3A</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        .card-header { background-color: #004aad; color: white; }
        .badge-pendiente { background-color: #ffc107; }
        .badge-procesado { background-color: #28a745; }
        .badge-anulado { background-color: #dc3545; }
        .btn-orange { background-color: #ff6600; border: none; color: white; }
        .btn-orange:hover { background-color: #e05500; }
        .btn-blue { background-color: #004aad; border: none; color: white; }
        .btn-blue:hover { background-color: #003d8f; }
        .table-hover tbody tr:hover { background-color: rgba(0, 74, 173, 0.05); }
    </style>
</head>
<body>
    <div class="container-fluid py-4">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <a href="principal.jsp" class="btn btn-blue mb-2">
                    <i class="bi bi-arrow-left"></i> Volver al Panel
                </a>
                <h2 class="mt-2"><i class="bi bi-clipboard-check"></i> Guías de Ingreso</h2>
            </div>
            <div>
                <a href="guia?opcion=nuevo" class="btn btn-orange">
                    <i class="bi bi-plus-circle"></i> Nueva Guía
                </a>
            </div>
        </div>
        
        <!-- Mensajes -->
        <% if (mensaje != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <%= mensaje %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <!-- Filtros -->
        <div class="card mb-4">
            <div class="card-header">
                <i class="bi bi-funnel"></i> Filtros de Búsqueda
            </div>
            <div class="card-body">
                <form action="guia?opcion=buscar" method="get" class="row g-3">
                    <input type="hidden" name="opcion" value="buscar">
                    
                    <div class="col-md-3">
                        <label class="form-label">Número de Guía</label>
                        <input type="text" class="form-control" name="numeroGuia" 
                               value="<%= request.getParameter("numeroGuia") != null ? request.getParameter("numeroGuia") : "" %>">
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label">Estado</label>
                        <select class="form-select" name="estado">
                            <option value="">Todos</option>
                            <option value="pendiente" <%= "pendiente".equals(request.getParameter("estado")) ? "selected" : "" %>>Pendiente</option>
                            <option value="procesado" <%= "procesado".equals(request.getParameter("estado")) ? "selected" : "" %>>Procesado</option>
                            <option value="anulado" <%= "anulado".equals(request.getParameter("estado")) ? "selected" : "" %>>Anulado</option>
                        </select>
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label">Fecha Inicio</label>
                        <input type="date" class="form-control" name="fechaInicio" 
                               value="<%= request.getParameter("fechaInicio") != null ? request.getParameter("fechaInicio") : "" %>">
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label">Fecha Fin</label>
                        <input type="date" class="form-control" name="fechaFin" 
                               value="<%= request.getParameter("fechaFin") != null ? request.getParameter("fechaFin") : "" %>">
                    </div>
                    
                    <div class="col-12 text-end">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-search"></i> Buscar
                        </button>
                        <a href="guia?opcion=listar" class="btn btn-secondary">
                            <i class="bi bi-arrow-clockwise"></i> Limpiar
                        </a>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Tabla de Guías -->
        <div class="card">
            <div class="card-header">
                <i class="bi bi-list-ul"></i> Lista de Guías (<%= guias != null ? guias.size() : 0 %>)
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>N° Guía</th>
                                <th>Proveedor</th>
                                <th>Fecha Recep.</th>
                                <th>Productos</th>
                                <th>Total (S/)</th>
                                <th>Tienda</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (guias != null && !guias.isEmpty()) { 
                                for (Guia guia : guias) { 
                                    String badgeClass = "";
                                    if ("pendiente".equals(guia.getEstado())) badgeClass = "badge-pendiente";
                                    else if ("procesado".equals(guia.getEstado())) badgeClass = "badge-procesado";
                                    else if ("anulado".equals(guia.getEstado())) badgeClass = "badge-anulado";
                            %>
                            <tr>
                                <td><strong><%= guia.getNumeroGuia() %></strong></td>
                                <td><%= guia.getProveedor() %></td>
                                <td><%= sdf.format(guia.getFechaRecepcion()) %></td>
                                <td><span class="badge bg-secondary"><%= guia.getTotalProductos() %></span></td>
                                <td><strong>S/ <%= String.format("%.2f", guia.getTotalValor()) %></strong></td>
                                <td><%= guia.getTiendaNombre() != null ? guia.getTiendaNombre() : "N/A" %></td>
                                <td>
                                    <span class="badge <%= badgeClass %>"><%= guia.getEstado() %></span>
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm" role="group">
                                        <a href="guia?opcion=detalle&id=<%= guia.getIdGuia() %>" 
                                           class="btn btn-outline-info" title="Ver Detalle">
                                            <i class="bi bi-eye"></i>
                                        </a>
                                        
                                        <% if ("pendiente".equals(guia.getEstado())) { %>
                                        <a href="guia?opcion=editar&id=<%= guia.getIdGuia() %>" 
                                           class="btn btn-outline-primary" title="Editar">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <a href="guia?opcion=procesar&id=<%= guia.getIdGuia() %>" 
                                           class="btn btn-outline-success" title="Marcar como Procesado"
                                           onclick="return confirm('¿Marcar esta guía como procesada?')">
                                            <i class="bi bi-check-circle"></i>
                                        </a>
                                        <a href="guia?opcion=anular&id=<%= guia.getIdGuia() %>" 
                                           class="btn btn-outline-danger" title="Anular"
                                           onclick="return confirm('¿Anular esta guía? Se revertirá el stock.')">
                                            <i class="bi bi-x-circle"></i>
                                        </a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } 
                            } else { %>
                            <tr>
                                <td colspan="8" class="text-center py-4 text-muted">
                                    <i class="bi bi-inbox" style="font-size: 2rem;"></i><br>
                                    No hay guías registradas
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- Botón de volver al final -->
            <div class="card-footer text-center">
                <a href="principal.jsp" class="btn btn-blue">
                    <i class="bi bi-house-door"></i> Volver al Panel Principal
                </a>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>