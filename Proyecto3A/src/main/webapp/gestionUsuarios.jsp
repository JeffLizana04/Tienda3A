<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Proyecto3A.dao.PersonalDao" %>
<%@ page import="com.Proyecto3A.model.Usuario" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.SQLException" %>
<%
    // Verificar sesión y permisos
    String rol = (String) session.getAttribute("rolUsuario");
    Integer rolId = (Integer) session.getAttribute("rolId");
    
    if (rol == null || rolId == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // Solo administrador puede ver esta página
    if (rolId != 3) {
        response.sendRedirect("principal.jsp");
        return;
    }
    
    PersonalDao personalDao = new PersonalDao();
    List<Usuario> usuarios = null;
    List<Map<String, Object>> roles = null;
    List<Map<String, Object>> tiendas = null;
    
    try {
        usuarios = personalDao.listarPersonal();
        roles = personalDao.obtenerRoles();
        tiendas = personalDao.obtenerTiendas();
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    // Obtener mensajes de resultado
    String mensaje = request.getParameter("mensaje");
    String tipoMensaje = request.getParameter("tipo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Personal - Tiendas 3A</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .navbar {
            background-color: #ff6600;
        }
        .table-actions {
            white-space: nowrap;
        }
        .badge-activo {
            background-color: #28a745;
        }
        .badge-inactivo {
            background-color: #dc3545;
        }
        .card {
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
            <a class="navbar-brand" href="principal.jsp">
                <i class="bi bi-shop"></i> Tiendas 3A - Gestión de Personal
            </a>
            <div class="d-flex align-items-center">
                <span class="text-light me-3">
                    <i class="bi bi-person-circle"></i> <%= session.getAttribute("nombreUsuario") %>
                </span>
                <a href="principal.jsp" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-arrow-left"></i> Volver al Panel
                </a>
            </div>
        </div>
    </nav>

    <!-- Contenido principal -->
    <div class="container mt-4">
        <!-- Mensajes de éxito/error -->
        <% if (mensaje != null) { %>
        <div class="alert alert-<%= tipoMensaje != null ? tipoMensaje : "success" %> alert-dismissible fade show" role="alert">
            <%= mensaje %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Card principal -->
        <div class="card">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="bi bi-people-fill text-warning"></i> Gestión de Personal
                </h5>
                <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#modalNuevoUsuario">
                    <i class="bi bi-person-plus"></i> Nuevo Usuario
                </button>
            </div>
            <div class="card-body">
                <!-- Tabla de usuarios -->
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Nombre</th>
                                <th>Correo</th>
                                <th>Rol</th>
                                <th>Tienda</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (usuarios != null && !usuarios.isEmpty()) { 
                                for (Usuario usuario : usuarios) { 
                            %>
                            <tr>
                                <td><%= usuario.getId() %></td>
                                <td><%= usuario.getNombre() %></td>
                                <td><%= usuario.getCorreo() %></td>
                                <td><%= usuario.getRolNombre() %></td>
                                <td>Tienda <%= usuario.getTiendaid() %></td>
                                <td>
                                    <span class="badge <%= usuario.getEstado().equals("activo") ? "bg-success" : "bg-danger" %>">
                                        <%= usuario.getEstado() %>
                                    </span>
                                </td>
                                <td class="table-actions">
                                    <button class="btn btn-sm btn-outline-warning" 
                                            onclick="editarUsuario(<%= usuario.getId() %>, '<%= usuario.getNombre() %>', '<%= usuario.getCorreo() %>', <%= usuario.getRolid() %>, <%= usuario.getTiendaid() %>, '<%= usuario.getEstado() %>')">
                                        <i class="bi bi-pencil"></i> Editar
                                    </button>
                                    <% if (usuario.getEstado().equals("activo")) { %>
                                    <button class="btn btn-sm btn-outline-danger" 
                                            onclick="cambiarEstado(<%= usuario.getId() %>, 'inactivo')">
                                        <i class="bi bi-person-x"></i> Desactivar
                                    </button>
                                    <% } else { %>
                                    <button class="btn btn-sm btn-outline-success" 
                                            onclick="cambiarEstado(<%= usuario.getId() %>, 'activo')">
                                        <i class="bi bi-person-check"></i> Activar
                                    </button>
                                    <% } %>
                                </td>
                            </tr>
                            <% } 
                            } else { %>
                            <tr>
                                <td colspan="7" class="text-center text-muted">No hay usuarios registrados</td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Nuevo Usuario -->
    <div class="modal fade" id="modalNuevoUsuario" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="GestionPersonalServlet" method="post">
                    <div class="modal-header">
                        <h5 class="modal-title">Nuevo Usuario</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="accion" value="crear">
                        <div class="mb-3">
                            <label class="form-label">Nombre Completo *</label>
                            <input type="text" class="form-control" name="nombre" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Correo Electrónico *</label>
                            <input type="email" class="form-control" name="correo" id="correoNuevo" required>
                            <div id="correoError" class="text-danger small d-none">Este correo ya está registrado</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Contraseña *</label>
                            <input type="password" class="form-control" name="contrasenha" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Rol *</label>
                            <select class="form-select" name="rolid" required>
                                <option value="">Seleccionar rol</option>
                                <% if (roles != null) {
                                    for (Map<String, Object> rolItem : roles) { %>
                                    <option value="<%= rolItem.get("id") %>"><%= rolItem.get("nombre") %></option>
                                <% }
                                } %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tienda *</label>
                            <select class="form-select" name="tiendaid" required>
                                <option value="">Seleccionar tienda</option>
                                <% if (tiendas != null) {
                                    for (Map<String, Object> tienda : tiendas) { %>
                                    <option value="<%= tienda.get("id") %>"><%= tienda.get("nombre") %></option>
                                <% }
                                } %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Estado *</label>
                            <select class="form-select" name="estado" required>
                                <option value="activo">Activo</option>
                                <option value="inactivo">Inactivo</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary" id="btnCrearUsuario">Crear Usuario</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal Editar Usuario -->
    <div class="modal fade" id="modalEditarUsuario" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="GestionPersonalServlet" method="post">
                    <div class="modal-header">
                        <h5 class="modal-title">Editar Usuario</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="accion" value="actualizar">
                        <input type="hidden" name="id" id="editarId">
                        <div class="mb-3">
                            <label class="form-label">Nombre Completo *</label>
                            <input type="text" class="form-control" name="nombre" id="editarNombre" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Correo Electrónico *</label>
                            <input type="email" class="form-control" name="correo" id="editarCorreo" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Rol *</label>
                            <select class="form-select" name="rolid" id="editarRolid" required>
                                <option value="">Seleccionar rol</option>
                                <% if (roles != null) {
                                    for (Map<String, Object> rolItem : roles) { %>
                                    <option value="<%= rolItem.get("id") %>"><%= rolItem.get("nombre") %></option>
                                <% }
                                } %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tienda *</label>
                            <select class="form-select" name="tiendaid" id="editarTiendaid" required>
                                <option value="">Seleccionar tienda</option>
                                <% if (tiendas != null) {
                                    for (Map<String, Object> tienda : tiendas) { %>
                                    <option value="<%= tienda.get("id") %>"><%= tienda.get("nombre") %></option>
                                <% }
                                } %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Estado *</label>
                            <select class="form-select" name="estado" id="editarEstado" required>
                                <option value="activo">Activo</option>
                                <option value="inactivo">Inactivo</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary">Guardar Cambios</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery (para verificar correo) -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <script>
        // Función para verificar correo único
        $('#correoNuevo').on('blur', function() {
            var correo = $(this).val();
            if (correo) {
                $.ajax({
                    url: 'VerificarCorreoServlet',
                    type: 'GET',
                    data: { correo: correo },
                    success: function(response) {
                        if (response === 'true' || response === true) {
                            $('#correoError').removeClass('d-none');
                            $('#btnCrearUsuario').prop('disabled', true);
                        } else {
                            $('#correoError').addClass('d-none');
                            $('#btnCrearUsuario').prop('disabled', false);
                        }
                    }
                });
            }
        });
        
        // Función para abrir modal de edición
        function editarUsuario(id, nombre, correo, rolid, tiendaid, estado) {
            $('#editarId').val(id);
            $('#editarNombre').val(nombre);
            $('#editarCorreo').val(correo);
            $('#editarRolid').val(rolid);
            $('#editarTiendaid').val(tiendaid);
            $('#editarEstado').val(estado);
            
            var modal = new bootstrap.Modal(document.getElementById('modalEditarUsuario'));
            modal.show();
        }
        
        // Función para cambiar estado
        function cambiarEstado(id, nuevoEstado) {
            if (confirm('¿Está seguro de cambiar el estado de este usuario?')) {
                var form = document.createElement('form');
                form.method = 'post';
                form.action = 'GestionPersonalServlet';
                
                var inputAccion = document.createElement('input');
                inputAccion.type = 'hidden';
                inputAccion.name = 'accion';
                inputAccion.value = 'cambiarEstado';
                form.appendChild(inputAccion);
                
                var inputId = document.createElement('input');
                inputId.type = 'hidden';
                inputId.name = 'id';
                inputId.value = id;
                form.appendChild(inputId);
                
                var inputEstado = document.createElement('input');
                inputEstado.type = 'hidden';
                inputEstado.name = 'estado';
                inputEstado.value = nuevoEstado;
                form.appendChild(inputEstado);
                
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>