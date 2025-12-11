<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Proyecto3A.dao.CatalogoDao" %>
<%@ page import="com.Proyecto3A.model.Catalogo" %>

<%
    CatalogoDao dao = new CatalogoDao();
    Catalogo producto = null;

    String idParam = request.getParameter("id");
    if (idParam != null) {
        int id = Integer.parseInt(idParam);
        producto = dao.obtenerPorId(id);
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            double descuento = Double.parseDouble(request.getParameter("descuento"));
            
            // ✅ Obtener usuario de sesión CORRECTAMENTE
            String usuario = (String) session.getAttribute("nombreUsuario");
            if (usuario == null || usuario.trim().isEmpty()) {
                usuario = "Sistema";
            }

            // ✅ Usar el método con auditoría
            boolean exito = dao.ponerEnOferta(id, descuento, usuario);

            if (exito) {
                response.sendRedirect("productosDescuento.jsp?mensaje=Oferta aplicada correctamente");
                return;
            } else {
                throw new Exception("No se pudo aplicar la oferta");
            }

        } catch (Exception e) {
            out.println("<script>alert('❌ Error: " + e.getMessage().replace("'", "\\'") + "');</script>");
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Poner en Oferta</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <!-- ✅ SweetAlert2 -->
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
            color: #ff6600;
        }
        .btn-success {
            background-color: #ff6600;
            border: none;
        }
        .btn-success:hover {
            background-color: #e65c00;
        }
    </style>
</head>
<body>

<div class="container">
    <h3 class="text-center mb-4">🏷️ Poner producto en oferta</h3>

    <% if (producto != null) { %>
    <form id="ofertaForm" method="post">
        <input type="hidden" name="id" value="<%= producto.getId() %>">

        <div class="mb-3">
            <label class="form-label">Producto</label>
            <input type="text" class="form-control" value="<%= producto.getProductos() %>" readonly>
        </div>

        <div class="mb-3">
            <label class="form-label">Precio Actual (S/)</label>
            <input type="number" class="form-control" id="precio" value="<%= producto.getPrecio() %>" readonly>
        </div>

        <div class="mb-3">
            <label class="form-label">Descuento (%)</label>
            <input type="number" class="form-control" id="descuento" name="descuento" min="1" max="90" required>
        </div>

        <div class="mb-3">
            <label class="form-label">Nuevo Precio (S/)</label>
            <input type="number" step="0.01" class="form-control" id="precioFinal" readonly>
        </div>

        <div class="d-flex justify-content-between">
            <a href="catalogo.jsp" class="btn btn-secondary">⬅️ Cancelar</a>
            <button type="submit" class="btn btn-success">💾 Aplicar oferta</button>
        </div>
    </form>

    <script>
        const precio = document.getElementById('precio');
        const descuento = document.getElementById('descuento');
        const precioFinal = document.getElementById('precioFinal');
        const form = document.getElementById('ofertaForm');

        descuento.addEventListener('input', () => {
            const p = parseFloat(precio.value);
            const d = parseFloat(descuento.value);
            if (!isNaN(p) && !isNaN(d)) {
                const nuevo = p - (p * (d / 100));
                precioFinal.value = nuevo.toFixed(2);
            } else {
                precioFinal.value = '';
            }
        });

        // ✅ Validación visual con SweetAlert2
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            const d = parseFloat(descuento.value);
            if (d > 50) {
                const resultado = await Swal.fire({
                    icon: 'warning',
                    title: 'Descuento alto detectado ⚠️',
                    html: `Estás aplicando un <b>${d}%</b> de descuento superior al 50.<br>¿Seguro que deseas continuar?`,
                    showCancelButton: true,
                    confirmButtonColor: '#ff6600',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Sí, aplicar oferta',
                    cancelButtonText: 'Cancelar'
                });
                if (resultado.isConfirmed) form.submit();
            } else {
                form.submit();
            }
        });
    </script>
    <% } else { %>
        <div class="alert alert-danger text-center">
            ⚠️ Producto no encontrado.
        </div>
    <% } %>
</div>

</body>
</html>