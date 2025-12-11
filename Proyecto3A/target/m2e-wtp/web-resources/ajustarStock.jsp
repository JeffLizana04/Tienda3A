<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Proyecto3A.dao.CatalogoDao" %>
<%@ page import="com.Proyecto3A.model.Catalogo" %>

<%
    CatalogoDao dao = new CatalogoDao();
    Catalogo producto = null;
    String mensaje = null;
    String tipoMensaje = null;

    String idParam = request.getParameter("id");
    String nombreProducto = request.getParameter("producto");
    
    if (idParam != null) {
        int id = Integer.parseInt(idParam);
        producto = dao.obtenerPorId(id);
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));
            String tipoMovimiento = request.getParameter("tipoMovimiento");
            String motivo = request.getParameter("motivo");
            
            // Obtener usuario de sesión
            String usuario = (String) session.getAttribute("nombreUsuario");
            if (usuario == null || usuario.trim().isEmpty()) {
                usuario = "Sistema";
            }
            
            // Validar cantidad
            if (cantidad <= 0) {
                throw new Exception("La cantidad debe ser mayor a 0");
            }
            
            // Validar stock para salidas
            if (tipoMovimiento.equals("salida")) {
                int stockActual = dao.obtenerStock(id);
                if (stockActual < cantidad) {
                    throw new Exception("Stock insuficiente. Stock actual: " + stockActual + " unidades");
                }
            }
            
            // Actualizar stock
            boolean exito = dao.actualizarStock(id, cantidad, tipoMovimiento, usuario);
            
            if (exito) {
                String movimiento = tipoMovimiento.equals("entrada") ? "entrada" : "salida";
                mensaje = "✅ Stock actualizado correctamente. " + movimiento + " de " + cantidad + " unidades.";
                tipoMensaje = "success";
            } else {
                throw new Exception("No se pudo actualizar el stock");
            }

        } catch (Exception e) {
            mensaje = "❌ Error: " + (e.getMessage() != null ? e.getMessage() : "Error desconocido");
            tipoMensaje = "error";
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Ajustar Stock</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        body {
            background-color: #f4f6f8;
            font-family: "Poppins", sans-serif;
        }
        .container {
            max-width: 550px;
            margin-top: 60px;
            background: white;
            padding: 25px;
            border-radius: 14px;
            box-shadow: 0 6px 14px rgba(0,0,0,0.1);
        }
        h3 {
            font-weight: 600;
            color: #004aad;
            border-bottom: 2px solid #004aad;
            padding-bottom: 10px;
        }
        .btn-success {
            background-color: #28a745;
            border: none;
        }
        .btn-success:hover {
            background-color: #218838;
        }
        .btn-danger {
            background-color: #dc3545;
            border: none;
        }
        .btn-danger:hover {
            background-color: #c82333;
        }
        .stock-info {
            background: #e8f4ff;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #004aad;
        }
        .form-label {
            font-weight: 600;
        }
    </style>
</head>
<body>

<div class="container">
    <h3 class="text-center mb-4">📦 Ajustar Stock de Producto</h3>

    <% if (producto != null) { %>
    
    <div class="stock-info">
        <h5><%= producto.getProductos() %></h5>
        <p><strong>Stock actual:</strong> <span class="badge bg-primary fs-6"><%= producto.getStock() %> unidades</span></p>
        <p><strong>Precio:</strong> S/ <%= producto.getPrecio() %></p>
    </div>

    <form id="stockForm" method="post">
        <input type="hidden" name="id" value="<%= producto.getId() %>">
        
        <div class="mb-3">
            <label class="form-label">Tipo de movimiento *</label>
            <div class="d-flex gap-2">
                <div class="form-check">
                    <input class="form-check-input" type="radio" name="tipoMovimiento" id="entrada" value="entrada" checked>
                    <label class="form-check-label text-success" for="entrada">
                        <i class="bi bi-plus-circle"></i> Entrada (Agregar stock)
                    </label>
                </div>
                <div class="form-check">
                    <input class="form-check-input" type="radio" name="tipoMovimiento" id="salida" value="salida">
                    <label class="form-check-label text-danger" for="salida">
                        <i class="bi bi-dash-circle"></i> Salida (Reducir stock)
                    </label>
                </div>
            </div>
        </div>

        <div class="mb-3">
            <label for="cantidad" class="form-label">Cantidad *</label>
            <input type="number" class="form-control" id="cantidad" name="cantidad" min="1" required>
            <small class="text-muted">Cantidad de unidades a agregar o retirar</small>
        </div>

        <div class="mb-3">
            <label for="motivo" class="form-label">Motivo del ajuste</label>
            <select class="form-select" id="motivo" name="motivo">
                <option value="compra">Compra/Ingreso</option>
                <option value="venta">Venta</option>
                <option value="devolucion">Devolución</option>
                <option value="perdida">Pérdida/Deterioro</option>
                <option value="inventario">Ajuste de inventario</option>
                <option value="otros">Otros</option>
            </select>
        </div>

        <div class="mb-3">
            <label for="observaciones" class="form-label">Observaciones</label>
            <textarea class="form-control" id="observaciones" name="observaciones" rows="2" placeholder="Detalles adicionales del ajuste..."></textarea>
        </div>

        <div class="d-flex justify-content-between">
            <a href="catalogo.jsp" class="btn btn-secondary">⬅️ Cancelar</a>
            <button type="submit" class="btn btn-primary" id="btnGuardar">
                💾 Aplicar ajuste
            </button>
        </div>
    </form>

    <script>
        const form = document.getElementById('stockForm');
        const cantidadInput = document.getElementById('cantidad');
        const tipoEntrada = document.getElementById('entrada');
        const tipoSalida = document.getElementById('salida');
        
        // Validación antes de enviar
        form.addEventListener('submit', function(e) {
            const cantidad = parseInt(cantidadInput.value);
            const tipoMovimiento = document.querySelector('input[name="tipoMovimiento"]:checked').value;
            
            if (cantidad <= 0) {
                e.preventDefault();
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: 'La cantidad debe ser mayor a 0'
                });
                return;
            }
            
            // Mostrar confirmación para salidas
            if (tipoMovimiento === 'salida') {
                e.preventDefault();
                Swal.fire({
                    icon: 'question',
                    title: 'Confirmar salida de stock',
                    html: `¿Estás seguro de retirar <b>${cantidad} unidades</b> del stock?<br><br>
                          <small>Stock actual: <%= producto.getStock() %> unidades</small>`,
                    showCancelButton: true,
                    confirmButtonColor: '#dc3545',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Sí, retirar',
                    cancelButtonText: 'Cancelar'
                }).then((result) => {
                    if (result.isConfirmed) {
                        document.getElementById('btnGuardar').innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Procesando...';
                        document.getElementById('btnGuardar').disabled = true;
                        form.submit();
                    }
                });
            } else {
                // Para entradas, solo mostrar loading
                document.getElementById('btnGuardar').innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Procesando...';
                document.getElementById('btnGuardar').disabled = true;
            }
        });
    </script>

    <% } else { %>
        <div class="alert alert-danger text-center">
            ⚠️ Producto no encontrado.
        </div>
        <div class="text-center mt-3">
            <a href="catalogo.jsp" class="btn btn-secondary">⬅️ Volver al catálogo</a>
        </div>
    <% } %>
</div>

<!-- Notificación después de guardar -->
<%
    if (mensaje != null && tipoMensaje != null) {
%>
<script>
    Swal.fire({
        icon: '<%= tipoMensaje %>',
        title: '<%= mensaje %>',
        showConfirmButton: true,
        confirmButtonColor: '#004aad',
        backdrop: 'rgba(0,0,0,0.4)'
    }).then(() => {
        <% if ("success".equals(tipoMensaje)) { %>
            window.location.href = "catalogo.jsp";
        <% } %>
    });
</script>
<%
    }
%>

</body>
</html>