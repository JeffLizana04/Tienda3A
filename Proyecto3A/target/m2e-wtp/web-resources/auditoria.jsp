<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Proyecto3A.dao.AuditoriaDao" %>
<%@ page import="com.Proyecto3A.model.Auditoria" %>
<%@ page import="java.util.List" %>
<%
    AuditoriaDao auditoriaDao = new AuditoriaDao();
    List<Auditoria> auditorias = auditoriaDao.obtenerTodaAuditoria();
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Auditoría del Sistema</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
    <div class="container-fluid">
        <!-- Header -->
        <nav class="navbar navbar-dark bg-dark">
            <div class="container">
                <span class="navbar-brand mb-0 h1">
                    <i class="bi bi-clipboard-data"></i> Sistema de Auditoría
                </span>
                <a href="principal.jsp" class="btn btn-outline-light">↩️ Volver al Panel</a>
            </div>
        </nav>

        <div class="container mt-4">
            <h2 class="text-center mb-4">📊 Registro de Auditoría</h2>
            
            <!-- Filtros -->
            <div class="card mb-4">
                <div class="card-body">
                    <form method="get" class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label">Tabla</label>
                            <select name="tabla" class="form-select">
                                <option value="">Todas las tablas</option>
                                <option value="catalogo">Catálogo</option>
                                <option value="usuario">Usuarios</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Acción</label>
                            <select name="accion" class="form-select">
                                <option value="">Todas las acciones</option>
                                <option value="INSERT">Creación</option>
                                <option value="UPDATE">Modificación</option>
                                <option value="DELETE">Eliminación</option>
                            </select>
                        </div>
                        <div class="col-md-4 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary w-100">🔍 Filtrar</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Tabla de Auditoría -->
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">📋 Historial de Cambios</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-striped table-hover mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th>Fecha</th>
                                    <th>Usuario</th>
                                    <th>Tabla</th>
                                    <th>Acción</th>
                                    <th>ID Registro</th>
                                    <th>Detalles</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Auditoria audit : auditorias) { %>
                                <tr>
                                    <td><%= audit.getFechaAccion() %></td>
                                    <td>
                                        <span class="badge bg-info">
                                            <i class="bi bi-person"></i> <%= audit.getUsuario() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge bg-secondary"><%= audit.getTablaAfectada() %></span>
                                    </td>
                                    <td>
                                        <% 
                                            String badgeColor = "";
                                            String icon = "";
                                            if ("INSERT".equals(audit.getAccion())) {
                                                badgeColor = "success";
                                                icon = "bi-plus-circle";
                                            } else if ("UPDATE".equals(audit.getAccion())) {
                                                badgeColor = "warning";
                                                icon = "bi-pencil";
                                            } else {
                                                badgeColor = "danger";
                                                icon = "bi-trash";
                                            }
                                        %>
                                        <span class="badge bg-<%= badgeColor %>">
                                            <i class="bi <%= icon %>"></i> <%= audit.getAccion() %>
                                        </span>
                                    </td>
                                    <td>#<%= audit.getIdRegistro() %></td>
                                    <td>
                                        <small class="text-muted"><%= audit.getDetalles() %></small>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <% if (auditorias.isEmpty()) { %>
            <div class="text-center mt-4">
                <div class="alert alert-info">
                    <i class="bi bi-info-circle"></i> No hay registros de auditoría disponibles.
                </div>
            </div>
            <% } %>
        </div>
    </div>
</body>
</html>