<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Proyecto3A.dao.CatalogoDao" %>
<%@ page import="com.Proyecto3A.model.Catalogo" %>
<%@ page import="java.sql.Date" %>

<%
    CatalogoDao dao = new CatalogoDao();
    Catalogo producto = null;

    // Obtener ID desde la URL
    String idParam = request.getParameter("id");

    if (idParam != null) {
        int id = Integer.parseInt(idParam);
        producto = dao.obtenerPorId(id);
    }

    // ✅ Procesar formulario POST
    if (request.getMethod().equalsIgnoreCase("POST")) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String productos = request.getParameter("productos");
            double precio = Double.parseDouble(request.getParameter("precio"));

            // Descuento opcional
            String descuentoStr = request.getParameter("descuento");
            Double descuento = (descuentoStr == null || descuentoStr.isEmpty()) ? null : Double.parseDouble(descuentoStr);

            double precioFinal = Double.parseDouble(request.getParameter("preciofinal"));
            String foto = request.getParameter("foto");

            String fechaV = request.getParameter("fechaVencimiento");
            Date fechaVencimiento = Date.valueOf(fechaV);

            boolean enOferta = (request.getParameter("enOferta") != null);

            // ✅ Obtener usuario de sesión CORRECTAMENTE
            String usuario = (String) session.getAttribute("nombreUsuario");
            if (usuario == null || usuario.trim().isEmpty()) {
                usuario = "Sistema";
            }

            Catalogo c = new Catalogo();
            c.setId(id);
            c.setProductos(productos);
            c.setPrecio(precio);
            c.setDescuentoPorcentaje(descuento);
            c.setPrecioFinal(precioFinal);
            c.setFoto(foto);
            c.setFechaVencimiento(fechaVencimiento);
            c.setEnOferta(enOferta);
            c.setOferta(descuento != null ? descuento + "%" : null);

            // ✅ Pasar el usuario de sesión AL MÉTODO CORRECTO
            boolean exito = dao.actualizarProducto(c, usuario);

            if (exito) {
                response.sendRedirect("catalogo.jsp?mensaje=Producto actualizado correctamente");
            } else {
                response.sendRedirect("catalogo.jsp?error=Error al actualizar producto");
            }
            return;

        } catch (Exception e) {
            out.println("<script>alert('❌ Error al actualizar: " + e.getMessage().replace("'", "\\'") + "');</script>");
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Producto</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f8f9fa;
        }
        .container {
            max-width: 650px;
            margin-top: 50px;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        h3 {
            font-weight: 600;
        }
        .product-image {
            display: block;
            margin: 0 auto 20px;
            border-radius: 10px;
            max-width: 100%;
            height: auto;
            object-fit: cover;
        }
        .preview-box {
            text-align: center;
            margin-bottom: 20px;
        }
        .preview-box img {
            width: 250px;
            height: 250px;
            border-radius: 12px;
            object-fit: contain;
            border: 1px solid #ddd;
            background-color: #fff;
        }
    </style>
</head>
<body>

<div class="container">
    <h3 class="text-center mb-4">✏️ Editar Producto</h3>

    <% if (producto != null) { %>

        <!-- 🖼️ Vista previa de la imagen -->
        <div class="preview-box">
            <img src="<%= producto.getFoto() %>" alt="Imagen del producto">
            <p class="mt-2 text-muted">Tienda 3A</p>
        </div>

        <form method="post" action="editarCatalogo.jsp">
            <input type="hidden" name="id" value="<%= producto.getId() %>">

            <div class="mb-3">
                <label class="form-label">Nombre del Producto</label>
                <input type="text" class="form-control" name="productos" value="<%= producto.getProductos() %>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Precio (S/)</label>
                <input type="number" step="0.01" class="form-control" name="precio" value="<%= producto.getPrecio() %>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Descuento (%)</label>
                <input type="number" step="0.01" class="form-control" name="descuento"
                       value="<%= (producto.getDescuentoPorcentaje() != null ? producto.getDescuentoPorcentaje() : "") %>">
            </div>

            <div class="mb-3">
                <label class="form-label">Precio Final (S/)</label>
                <input type="number" step="0.01" class="form-control" name="preciofinal" value="<%= producto.getPrecioFinal() %>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">URL de Imagen</label>
                <input type="text" class="form-control" name="foto" value="<%= producto.getFoto() %>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Fecha de Vencimiento</label>
                <input type="date" class="form-control" name="fechaVencimiento"
                       value="<%= (producto.getFechaVencimiento() != null ? producto.getFechaVencimiento().toString() : "") %>" required>
            </div>

            <div class="form-check mb-3">
                <input type="checkbox" class="form-check-input" name="enOferta" <%= producto.isEnOferta() ? "checked" : "" %>>
                <label class="form-check-label">¿Está en oferta?</label>
            </div>

            <div class="d-flex justify-content-between">
                <a href="catalogo.jsp" class="btn btn-secondary">⬅️ Volver</a>
                <button type="submit" class="btn btn-primary">💾 Guardar Cambios</button>
            </div>
        </form>

    <% } else { %>
        <div class="alert alert-danger text-center">
            ⚠️ Producto no encontrado.
        </div>
    <% } %>
</div>

</body>
</html>