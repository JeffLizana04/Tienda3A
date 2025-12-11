<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.Proyecto3A.dao.CatalogoDao" %>
<%@ page import="com.Proyecto3A.model.Catalogo" %>
<%
    // Verificar sesión y permisos
    String rol = (String) session.getAttribute("rolUsuario");
    if (rol == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    int rolId = (session.getAttribute("rolId") != null) ? (Integer) session.getAttribute("rolId") : 0;
    boolean puedeEditar = rolId == 1 || rolId == 3; // jefetienda y admin
    boolean puedeCambiarEstado = rolId == 1 || rolId == 3;
    boolean puedePonerOferta = rolId == 1 || rolId == 3;
    
    CatalogoDao dao = new CatalogoDao();
    List<Catalogo> lista = dao.listarProductos();
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Catálogo de Productos - 3A</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        /* 🎨 Paleta 3A */
        :root {
            --color-primario: #ff6600;
            --color-secundario: #1e1e1e;
            --color-fondo: #f4f4f4;
            --color-texto: #333;
            --color-blanco: #fff;
        }

        body {
            background-color: var(--color-fondo);
            color: var(--color-texto);
            font-family: "Poppins", sans-serif;
        }

        /* 🧱 Contenedor principal */
        .container {
            margin-top: 50px;
        }

        h2 {
            color: var(--color-secundario);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* 💳 Tarjeta de producto */
        .card {
            border: none;
            border-radius: 16px;
            background: var(--color-blanco);
            box-shadow: 0 4px 10px rgba(0,0,0,0.08);
            transition: all 0.3s ease-in-out;
        }

        .card:hover {
            transform: translateY(-6px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.12);
        }

        .card img {
            height: 220px;
            object-fit: cover;
            border-radius: 16px 16px 0 0;
        }

        /* 🏷️ Títulos y precios */
        .card-title {
            font-size: 1.1rem;
            font-weight: 600;
        }

        .price-old {
            text-decoration: line-through;
            color: #999;
            font-size: 0.9rem;
        }

        .price-new {
            color: var(--color-primario);
            font-weight: bold;
            font-size: 1.1rem;
        }

        .badge-oferta {
            background: var(--color-primario);
            color: var(--color-blanco);
            font-weight: 500;
            padding: 4px 8px;
            border-radius: 8px;
            font-size: 0.8rem;
        }

        .badge-stock {
            background: #28a745;
            color: var(--color-blanco);
            font-weight: 500;
            padding: 4px 8px;
            border-radius: 8px;
            font-size: 0.8rem;
        }

        .badge-stock-bajo {
            background: #ffc107;
            color: #212529;
            font-weight: 500;
            padding: 4px 8px;
            border-radius: 8px;
            font-size: 0.8rem;
        }

        .badge-stock-critico {
            background: #dc3545;
            color: var(--color-blanco);
            font-weight: 500;
            padding: 4px 8px;
            border-radius: 8px;
            font-size: 0.8rem;
        }

        /* 🔘 Botones */
        .btn-orange {
            background-color: var(--color-primario);
            color: var(--color-blanco);
            border: none;
            border-radius: 8px;
            transition: background 0.3s ease;
        }

        .btn-orange:hover {
            background-color: #e65c00;
            color: var(--color-blanco);
        }

        .btn-outline-success {
            border-color: var(--color-primario);
            color: var(--color-primario);
            border-radius: 8px;
        }

        .btn-outline-success:hover {
            background-color: var(--color-primario);
            color: white;
        }

        .btn-outline-secondary {
            border-radius: 8px;
        }

        .btn-sm {
            border-radius: 8px;
            padding: 5px 10px;
        }

        /* 🔹 Header superior */
        .top-header {
            background: var(--color-secundario);
            color: var(--color-blanco);
            padding: 15px 0;
            text-align: center;
            font-weight: 600;
            letter-spacing: 1px;
        }
        
        .badge-rol {
            background: #004aad;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        .stock-info {
            font-size: 0.9rem;
            margin-bottom: 10px;
        }
    </style>
</head>

<body>
    <div class="top-header">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <span><i class="bi bi-box-seam"></i> PANEL DE CATÁLOGO - 3A</span>
                <span class="badge-rol">
                    <i class="bi bi-person-badge"></i> <%= rol %>
                </span>
            </div>
        </div>
    </div>

    <div class="container">
        <h2 class="text-center mb-4">📦 Catálogo de Productos</h2>

        <!-- 🔙 Botones de acción -->
        <div class="text-end mb-4">
            <a href="principal.jsp" class="btn btn-secondary me-2">⬅️ Volver</a>
            <% if (puedeEditar) { %>
            <a href="agregarCatalogo.jsp" class="btn btn-orange">➕ Agregar Producto</a>
            <% } %>
        </div>

        <div class="row">
            <%
                for (Catalogo c : lista) {
                    // Determinar el color del badge de stock según la cantidad
                    String stockBadgeClass = "badge-stock";
                    String stockText = c.getStock() + " unidades";
                    
                    if (c.getStock() <= 10) {
                        stockBadgeClass = "badge-stock-critico";
                        stockText = "⚠️ " + c.getStock() + " unidades (CRÍTICO)";
                    } else if (c.getStock() <= 25) {
                        stockBadgeClass = "badge-stock-bajo";
                        stockText = c.getStock() + " unidades (BAJO)";
                    }
            %>
            <div class="col-md-4 mb-4">
                <div class="card">
                    <img src="<%= c.getFoto() %>" alt="Imagen del producto">

                    <div class="card-body">
                        <h5 class="card-title d-flex justify-content-between align-items-center">
                            <%= c.getProductos() %>
                            <% if (c.isEnOferta()) { %>
                                <span class="badge-oferta">Oferta <%= c.getDescuentoPorcentaje() %>%</span>
                            <% } %>
                        </h5>

                        <!-- Stock -->
                        <div class="stock-info">
                            <span class="<%= stockBadgeClass %>">
                                <i class="bi bi-box-seam"></i> <%= stockText %>
                            </span>
                        </div>

                        <!-- Precios -->
                        <% if (c.isEnOferta()) { %>
                            <p class="price-old">Antes: S/ <%= c.getPrecio() %></p>
                            <p class="price-new">Ahora: S/ <%= c.getPrecioFinal() %></p>
                        <% } else { %>
                            <p class="mb-2">💲 Precio: <strong>S/ <%= c.getPrecio() %></strong></p>
                        <% } %>

                        <p class="text-muted small mb-3">🗓️ Vence el: <%= c.getFechaVencimiento() %></p>

                        <div class="d-flex justify-content-between">
                            <% if (puedeEditar) { %>
                            <a href="editarCatalogo.jsp?id=<%= c.getId() %>" class="btn btn-warning btn-sm">
                                <i class="bi bi-pencil-square"></i> Editar
                            </a>
                            <% } %>
                            
                            <% if (puedeCambiarEstado) { %>
                            <a href="cambiarEstadoCatalogo.jsp?id=<%= c.getId() %>"
                               class="btn btn-<%= "activo".equals(c.getEstado()) ? "danger" : "success" %> btn-sm"
                               onclick="return confirm('¿Seguro que deseas <%= "activo".equals(c.getEstado()) ? "Inactivar" : "Activar" %> este producto?');">
                               <i class="bi bi-<%= "activo".equals(c.getEstado()) ? "trash" : "arrow-repeat" %>"></i>
                               <%= "activo".equals(c.getEstado()) ? "Inactivo" : "Activo" %>
                            </a>
                            <% } %>
                        </div>

                        <!-- Botón para ajustar stock (solo usuarios con permisos) -->
                        <% if (puedeEditar) { %>
                        <div class="mt-2">
                            <a href="ajustarStock.jsp?id=<%= c.getId() %>&producto=<%= java.net.URLEncoder.encode(c.getProductos(), "UTF-8") %>" 
                               class="btn btn-outline-info btn-sm w-100">
                                <i class="bi bi-arrow-up-down"></i> Ajustar Stock
                            </a>
                        </div>
                        <% } %>

                        <% if (!c.isEnOferta() && puedePonerOferta) { %>
                            <div class="mt-2">
                                <a href="ofertaCatalogo.jsp?id=<%= c.getId() %>" class="btn btn-outline-success btn-sm w-100">
                                    <i class="bi bi-fire"></i> Poner en oferta
                                </a>
                            </div>
                        <% } else if (c.isEnOferta() && puedePonerOferta) { %>
                            <div class="mt-2">
                                <a href="quitarOferta.jsp?id=<%= c.getId() %>" class="btn btn-outline-secondary btn-sm w-100">
                                    <i class="bi bi-x-circle"></i> Quitar oferta
                                </a>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                }
            %>
        </div>
    </div>
</body>
</html>