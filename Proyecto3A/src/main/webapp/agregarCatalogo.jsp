<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Proyecto3A.dao.CatalogoDao" %>
<%@ page import="com.Proyecto3A.model.Catalogo" %>

<%
    String mensaje = null;
    String tipoMensaje = null;

    // Solo procesar cuando el método es POST
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            String productos = request.getParameter("productos");
            String precioStr = request.getParameter("precio");
            String oferta = request.getParameter("oferta");
            String precioFinalStr = request.getParameter("preciofinal");
            String foto = request.getParameter("foto");
            String fechaVenc = request.getParameter("fechavencimiento");
            String stockStr = request.getParameter("stock");
            
            // Obtener usuario de sesión
            String usuario = (String) session.getAttribute("nombreUsuario");
            if (usuario == null) usuario = "Sistema";

            // Validaciones básicas
            if (productos == null || productos.trim().isEmpty()) {
                throw new IllegalArgumentException("El nombre del producto es obligatorio.");
            }

            double precio = (precioStr == null || precioStr.isEmpty()) ? 0.0 : Double.parseDouble(precioStr);
            double precioFinal = (precioFinalStr == null || precioFinalStr.isEmpty()) ? precio : Double.parseDouble(precioFinalStr);
            int stock = (stockStr == null || stockStr.isEmpty()) ? 0 : Integer.parseInt(stockStr);

            java.sql.Date sqlFechaVenc = null;
            if (fechaVenc != null && !fechaVenc.trim().isEmpty()) {
                sqlFechaVenc = java.sql.Date.valueOf(fechaVenc);
            }

            Catalogo c = new Catalogo();
            c.setProductos(productos);
            c.setPrecio(precio);
            c.setOferta((oferta != null && !oferta.trim().isEmpty()) ? oferta : null);
            c.setPrecioFinal(precioFinal);
            c.setFoto((foto != null && !foto.trim().isEmpty()) ? foto : "imagenes/default.png");
            c.setFechaVencimiento(sqlFechaVenc);
            c.setStock(stock); // NUEVO: Stock inicial
            c.setEnOferta(false);
            c.setDescuentoPorcentaje(null);
            c.setEstado("activo");

            CatalogoDao dao = new CatalogoDao();
            // ✅ Pasar el usuario de sesión
            boolean exito = dao.agregarProducto(c, usuario);

            if (exito) {
                mensaje = "✅ Producto agregado correctamente con stock inicial de " + stock + " unidades";
                tipoMensaje = "success";
            } else {
                mensaje = "❌ Error al agregar el producto";
                tipoMensaje = "error";
            }
        } catch (Exception e) {
            mensaje = "❌ Error: " + (e.getMessage() != null ? e.getMessage() : "Error desconocido");
            tipoMensaje = "error";
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Agregar Producto</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        body {
            background: linear-gradient(135deg, #ece9e6, #ffffff);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: transform 0.2s ease-in-out;
        }
        .card:hover {
            transform: translateY(-3px);
        }
        .btn-primary {
            background: #007bff;
            border: none;
            border-radius: 8px;
        }
        .btn-primary:hover {
            background: #0056b3;
        }
        .btn-secondary {
            border-radius: 8px;
        }
        .form-control {
            border-radius: 8px;
            box-shadow: none;
        }
        h3 {
            color: #333;
            font-weight: 600;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="card p-4">
        <h3 class="text-center mb-4">🆕 Agregar Producto</h3>

        <form method="post" action="agregarCatalogo.jsp">
            <div class="mb-3">
                <label class="form-label">Nombre del producto *</label>
                <input type="text" name="productos" class="form-control" required>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Precio *</label>
                    <input type="number" name="precio" step="0.01" class="form-control" required>
                </div>
                
                <div class="col-md-6 mb-3">
                    <label class="form-label">Stock inicial *</label>
                    <input type="number" name="stock" min="0" class="form-control" value="0" required>
                    <small class="text-muted">Cantidad disponible al inicio</small>
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label">Oferta (opcional, ejemplo: 10%)</label>
                <input type="text" name="oferta" class="form-control" placeholder="Ej: 10%">
            </div>

            <div class="mb-3">
                <label class="form-label">Precio Final *</label>
                <input type="number" name="preciofinal" step="0.01" class="form-control" required>
                <small class="text-muted">Si hay oferta, poner el precio con descuento</small>
            </div>

            <div class="mb-3">
                <label class="form-label">Ruta de la imagen *</label>
                <input type="text" name="foto" class="form-control" placeholder="Ej: imagenes/aceite_1l.jpg" required>
                <small class="text-muted">La imagen debe existir en la carpeta <strong>imagenes/</strong> dentro del proyecto.</small>
            </div>

            <div class="mb-3">
                <label class="form-label">Fecha de vencimiento</label>
                <input type="date" name="fechavencimiento" class="form-control">
            </div>

            <div class="d-flex justify-content-between">
                <a href="catalogo.jsp" class="btn btn-secondary">⬅️ Volver</a>
                <button type="submit" class="btn btn-primary">💾 Guardar Producto</button>
            </div>
        </form>
    </div>
</div>

<!-- ✅ Notificación moderna después de guardar -->
<%
    if (mensaje != null && tipoMensaje != null) {
%>
<script>
    Swal.fire({
        icon: '<%= tipoMensaje %>',
        title: '<%= mensaje %>',
        showConfirmButton: false,
        timer: 1800,
        background: '#fefefe',
        backdrop: `rgba(0,0,0,0.4)`
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