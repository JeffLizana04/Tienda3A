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
    boolean puedeQuitarOferta = rolId == 1 || rolId == 3;
    
    CatalogoDao dao = new CatalogoDao();
    List<Catalogo> lista = dao.listarProductos();
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Productos en Oferta</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <!-- 🔔 SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

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
            height: 200px;
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
    </style>
</head>
<body>

    <div class="top-header">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <span><i class="bi bi-fire"></i> PRODUCTOS EN OFERTA - 3A</span>
                <span class="badge-rol">
                    <i class="bi bi-person-badge"></i> <%= rol %>
                </span>
            </div>
        </div>
    </div>

    <div class="container">
        <h2 class="text-center mb-4">🔥 Productos en Oferta</h2>

        <div class="text-end mb-3">
            <a href="catalogo.jsp" class="btn btn-secondary">⬅️ Volver al Catálogo</a>
        </div>

        <div class="row">
            <%
                boolean hayOfertas = false;
                for (Catalogo c : lista) {
                    if (c.isEnOferta()) {
                        hayOfertas = true;
            %>
            <div class="col-md-4 mb-4">
                <div class="card">
                    <img src="<%= c.getFoto() %>" class="card-img-top" alt="Imagen del producto">
                    <div class="card-body">
                        <h5 class="card-title d-flex justify-content-between">
                            <%= c.getProductos() %>
                            <span class="badge-oferta">Oferta <%= c.getDescuentoPorcentaje() %>%</span>
                        </h5>
                        <p class="price-old">Antes: S/ <%= c.getPrecio() %></p>
                        <p class="price-new">Ahora: S/ <%= c.getPrecioFinal() %></p>
                        <p class="text-muted">🗓️ Vence el: <%= c.getFechaVencimiento() %></p>

                        <!-- 🔧 ACCIONES - Solo visibles para jefetienda y admin -->
                        <% if (puedeEditar || puedeQuitarOferta) { %>
                        <div class="d-flex justify-content-between">
                            <% if (puedeEditar) { %>
                            <a href="editarCatalogo.jsp?id=<%= c.getId() %>" class="btn btn-warning btn-sm">✏️ Editar</a>
                            <% } %>
                            
                            <% if (puedeQuitarOferta) { %>
                            <a href="#" 
                               class="btn btn-outline-danger btn-sm" 
                               onclick="confirmarQuitar('<%= c.getId() %>'); return false;">❌ Quitar oferta</a>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                    }
                }
                if (!hayOfertas) {
            %>
            <div class="col-12 text-center mt-4">
                <div class="alert alert-info">🚫 No hay productos en oferta actualmente.</div>
            </div>
            <% } %>
        </div>
    </div>

    <!-- 💡 Script para confirmación moderna -->
    <script>
        function confirmarQuitar(id) {
            Swal.fire({
                title: '¿Quitar esta oferta?',
                text: 'Esta acción eliminará la oferta del producto.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Sí, quitar oferta',
                cancelButtonText: 'Cancelar',
                background: '#fefefe',
                backdrop: `rgba(0,0,0,0.4)`
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = 'quitarOferta.jsp?id=' + id;
                }
            });
        }
    </script>

</body>
</html>