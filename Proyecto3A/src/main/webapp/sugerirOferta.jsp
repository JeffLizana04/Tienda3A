<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Proyecto3A.dao.CatalogoDao" %>
<%@ page import="com.Proyecto3A.model.Catalogo" %>
<%
    String idParam = request.getParameter("id");
    Catalogo producto = null;
    double descuentoSugerido = 40.0; // Descuento automático del 40%
    
    if (idParam != null) {
        CatalogoDao dao = new CatalogoDao();
        producto = dao.obtenerPorId(Integer.parseInt(idParam));
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String usuario = (String) session.getAttribute("nombreUsuario");
            
            CatalogoDao dao = new CatalogoDao();
            boolean exito = dao.ponerEnOferta(id, descuentoSugerido, usuario);
            
            if (exito) {
                response.sendRedirect("catalogo.jsp?mensaje=Oferta aplicada automaticamente");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Sugerencia de Oferta Automática</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
    <div class="container mt-5">
        <div class="card shadow">
            <div class="card-header bg-warning text-dark">
                <h4 class="mb-0">🏷️ Sugerencia de Oferta Automática</h4>
            </div>
            <div class="card-body">
                <% if (producto != null) { 
                    double precioFinal = producto.getPrecio() * (1 - descuentoSugerido/100);
                %>
                <div class="alert alert-info">
                    <h5>📋 Producto: <strong><%= producto.getProductos() %></strong></h5>
                    <p>🗓️ <strong>Fecha de vencimiento:</strong> <%= producto.getFechaVencimiento() %></p>
                    <p>⏰ <strong>Días restantes:</strong> 
                        <%= java.time.LocalDate.now().until(producto.getFechaVencimiento().toLocalDate()).getDays() %> días
                    </p>
                </div>

                <div class="sugerencia-oferta p-3 bg-light rounded">
                    <h5 class="text-success">💡 Sugerencia Automática:</h5>
                    <p>Aplicar <strong>descuento del <%= descuentoSugerido %>%</strong> para acelerar venta</p>
                    
                    <div class="row mt-3">
                        <div class="col-md-6">
                            <p><strong>Precio original:</strong> S/ <%= producto.getPrecio() %></p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Precio con <%= descuentoSugerido %>% descuento:</strong> 
                               <span class="text-success fw-bold">S/ <%= String.format("%.2f", precioFinal) %></span>
                            </p>
                        </div>
                    </div>
                </div>

                <form method="post" class="mt-4">
                    <input type="hidden" name="id" value="<%= producto.getId() %>">
                    
                    <div class="d-flex justify-content-between">
                        <a href="principal.jsp" class="btn btn-secondary">↩️ Cancelar</a>
                        <button type="submit" class="btn btn-success">
                            ✅ Aplicar Oferta Automática
                        </button>
                    </div>
                </form>
                <% } else { %>
                <div class="alert alert-danger">Producto no encontrado</div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>