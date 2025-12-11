<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Proyecto3A.model.Guia, com.Proyecto3A.model.GuiaDetalle" %>
<%@ page import="com.Proyecto3A.dao.CatalogoDao, com.Proyecto3A.model.Catalogo" %>
<%@ page import="java.util.List, java.text.SimpleDateFormat" %>
<%
    Guia guia = (Guia) request.getAttribute("guia");
    boolean esEdicion = guia != null && guia.getIdGuia() > 0;
    String titulo = esEdicion ? "Editar Guía" : "Nueva Guía";
    String action = esEdicion ? "guia?opcion=actualizar" : "guia?opcion=guardar";
    
    // Obtener productos para el selector
    CatalogoDao catalogoDao = new CatalogoDao();
    List<Catalogo> productos = catalogoDao.listarProductosConStock();
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    
    // Valores por defecto
    if (!esEdicion) {
        guia = new Guia();
    }
    
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><%= titulo %> - Tiendas 3A</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/picocss/pico.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    
    <!-- Select2 para búsqueda mejorada -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet">
    
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .header-guia {
            background: linear-gradient(135deg, #004aad 0%, #0066cc 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
            border-radius: 0 0 20px 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            margin-bottom: 1.5rem;
        }
        
        .card-header {
            background-color: #fff;
            border-bottom: 2px solid #004aad;
            font-weight: 600;
            color: #004aad;
            padding: 1rem 1.5rem;
            border-radius: 15px 15px 0 0 !important;
        }
        
        .form-section {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            border-left: 4px solid #004aad;
        }
        
        .btn-orange {
            background-color: #ff6600;
            border: none;
            color: white;
            font-weight: 500;
            padding: 0.5rem 1.5rem;
            border-radius: 8px;
            transition: all 0.3s;
        }
        
        .btn-orange:hover {
            background-color: #e05500;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(255, 102, 0, 0.3);
        }
        
        .btn-outline-orange {
            border: 2px solid #ff6600;
            color: #ff6600;
            background: white;
            font-weight: 500;
            padding: 0.5rem 1.5rem;
            border-radius: 8px;
            transition: all 0.3s;
        }
        
        .btn-outline-orange:hover {
            background-color: #ff6600;
            color: white;
        }
        
        .producto-item {
            border: 1px solid #dee2e6;
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 1rem;
            background: #f8f9fa;
            transition: all 0.3s;
        }
        
        .producto-item:hover {
            border-color: #004aad;
            background: #fff;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }
        
        .producto-item.eliminado {
            opacity: 0.6;
            background: #f8d7da;
            text-decoration: line-through;
        }
        
        .total-box {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 1.5rem;
            border-radius: 12px;
            margin-top: 1rem;
            text-align: center;
        }
        
        .total-box h3 {
            margin: 0;
            font-size: 1.8rem;
            font-weight: 700;
        }
        
        .total-box small {
            opacity: 0.9;
            font-size: 0.9rem;
        }
        
        .required::after {
            content: " *";
            color: #dc3545;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 1rem;
            border-radius: 8px;
            border-left: 4px solid #dc3545;
            margin-bottom: 1.5rem;
        }
        
        .precio-input {
            background: #e8f4ff;
            border-color: #004aad;
            font-weight: 500;
            color: #004aad;
        }
        
        .stock-info {
            font-size: 0.85rem;
            color: #6c757d;
            background: #f8f9fa;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            margin-top: 0.25rem;
        }
        
        .tabla-detalles th {
            background: #004aad;
            color: white;
            font-weight: 500;
        }
        
        .fecha-input {
            max-width: 200px;
        }
        
        /* Select2 personalizado */
        .select2-container--bootstrap5 .select2-selection {
            border: 1px solid #ced4da;
            border-radius: 0.375rem;
            height: calc(2.25rem + 2px);
            padding: 0.375rem 0.75rem;
        }
        
        .select2-container--bootstrap5 .select2-selection:focus {
            border-color: #004aad;
            box-shadow: 0 0 0 0.25rem rgba(0, 74, 173, 0.25);
        }
        
        .badge-stock {
            background: #28a745;
            color: white;
            font-size: 0.75rem;
            padding: 0.2rem 0.5rem;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header-guia">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="mb-1">
                        <i class="bi bi-clipboard-plus"></i> <%= titulo %>
                    </h1>
                    <p class="mb-0 opacity-75">
                        <%= esEdicion ? "Editando guía #" + guia.getNumeroGuia() : "Complete todos los campos para registrar una nueva guía de ingreso" %>
                    </p>
                </div>
                <a href="guia?opcion=listar" class="btn btn-outline-light">
                    <i class="bi bi-arrow-left"></i> Volver al Listado
                </a>
            </div>
        </div>
    </div>
    
    <div class="container">
        <!-- Mensaje de Error -->
        <% if (error != null) { %>
        <div class="error-message mb-4">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Error:</strong> <%= error %>
        </div>
        <% } %>
        
        <form id="formGuia" action="<%= action %>" method="post" novalidate>
            <% if (esEdicion) { %>
            <input type="hidden" name="idGuia" value="<%= guia.getIdGuia() %>">
            <% } %>
            <input type="hidden" name="opcion" value="<%= esEdicion ? "actualizar" : "guardar" %>">
            
            <!-- Información Principal -->
            <div class="card">
                <div class="card-header">
                    <i class="bi bi-info-circle me-2"></i> Información de la Guía
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <!-- Número de Guía -->
                        <div class="col-md-6">
                            <label for="numeroGuia" class="form-label required">Número de Guía</label>
                            <input type="text" class="form-control" id="numeroGuia" name="numeroGuia" 
                                   value="<%= guia.getNumeroGuia() != null ? guia.getNumeroGuia() : "" %>" 
                                   required 
                                   placeholder="Ej: GUIA-2025-001">
                            <div class="form-text">Número único de identificación de la guía</div>
                        </div>
                        
                        <!-- Proveedor -->
                        <div class="col-md-6">
                            <label for="proveedor" class="form-label required">Proveedor</label>
                            <input type="text" class="form-control" id="proveedor" name="proveedor" 
                                   value="<%= guia.getProveedor() != null ? guia.getProveedor() : "" %>" 
                                   required
                                   placeholder="Nombre del proveedor">
                        </div>
                        
                        <!-- Fechas -->
                        <div class="col-md-6">
                            <label for="fechaEmision" class="form-label required">Fecha de Emisión</label>
                            <input type="date" class="form-control fecha-input" id="fechaEmision" 
                                   name="fechaEmision" 
                                   value="<%= guia.getFechaEmision() != null ? sdf.format(guia.getFechaEmision()) : "" %>" 
                                   required>
                        </div>
                        
                        <div class="col-md-6">
                            <label for="fechaRecepcion" class="form-label required">Fecha de Recepción</label>
                            <input type="date" class="form-control fecha-input" id="fechaRecepcion" 
                                   name="fechaRecepcion" 
                                   value="<%= guia.getFechaRecepcion() != null ? sdf.format(guia.getFechaRecepcion()) : "" %>" 
                                   required>
                        </div>
                        
                        <!-- Tienda -->
                        <div class="col-md-6">
                            <label for="tiendaId" class="form-label required">Tienda Destino</label>
                            <select class="form-select" id="tiendaId" name="tiendaId" required>
                                <option value="">Seleccionar tienda...</option>
                                <option value="1" <%= guia.getTiendaId() == 1 ? "selected" : "" %>>Tienda Principal</option>
                                <option value="2" <%= guia.getTiendaId() == 2 ? "selected" : "" %>>Tienda Norte</option>
                                <option value="3" <%= guia.getTiendaId() == 3 ? "selected" : "" %>>Tienda Sur</option>
                                <option value="4" <%= guia.getTiendaId() == 4 ? "selected" : "" %>>Tienda Este</option>
                                <option value="5" <%= guia.getTiendaId() == 5 ? "selected" : "" %>>Tienda Oeste</option>
                            </select>
                        </div>
                        
                        <!-- Estado -->
                        <div class="col-md-6">
                            <label for="estado" class="form-label">Estado</label>
                            <select class="form-select" id="estado" name="estado" <%= esEdicion ? "" : "disabled" %>>
                                <option value="pendiente" <%= "pendiente".equals(guia.getEstado()) ? "selected" : "" %>>Pendiente</option>
                                <option value="procesado" <%= "procesado".equals(guia.getEstado()) ? "selected" : "" %>>Procesado</option>
                                <option value="anulado" <%= "anulado".equals(guia.getEstado()) ? "selected" : "" %>>Anulado</option>
                            </select>
                            <% if (!esEdicion) { %>
                            <input type="hidden" name="estado" value="pendiente">
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Productos -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <div>
                        <i class="bi bi-box-seam me-2"></i> Productos
                        <span class="badge bg-secondary ms-2" id="contadorProductos">0</span>
                    </div>
                    <button type="button" class="btn btn-success btn-sm" onclick="agregarProducto()">
                        <i class="bi bi-plus-circle"></i> Agregar Producto
                    </button>
                </div>
                <div class="card-body">
                    <!-- Contenedor de productos -->
                    <div id="contenedorProductos" class="mb-4">
                        <% if (esEdicion && guia.getDetalles() != null && !guia.getDetalles().isEmpty()) { 
                            int index = 0;
                            for (GuiaDetalle detalle : guia.getDetalles()) { 
                        %>
                        <div class="producto-item" id="productoItem_<%= index %>">
                            <div class="row g-3">
                                <!-- Producto -->
                                <div class="col-md-4">
                                    <label class="form-label required">Producto</label>
                                    <select class="form-select producto-select" name="productoId" required 
                                            onchange="actualizarProducto(<%= index %>, this.value)">
                                        <option value="">Seleccionar producto...</option>
                                        <% for (Catalogo p : productos) { %>
                                        <option value="<%= p.getId() %>" 
                                                data-precio="<%= p.getPrecio() %>"
                                                data-stock="<%= p.getStock() %>"
                                                <%= detalle.getIdProducto() == p.getId() ? "selected" : "" %>>
                                            <%= p.getProductos() %> (Stock: <%= p.getStock() %>)
                                        </option>
                                        <% } %>
                                    </select>
                                    <input type="hidden" name="productoNombre_<%= detalle.getIdProducto() %>" 
                                           id="productoNombre_<%= index %>" 
                                           value="<%= detalle.getProductoNombre() %>">
                                    <div class="stock-info" id="stockInfo_<%= index %>">
                                        <% if (detalle.getIdProducto() > 0) { %>
                                        Stock actual: <span class="badge-stock" id="stockActual_<%= index %>">
                                            <%= detalle.getIdProducto() > 0 ? catalogoDao.obtenerStock(detalle.getIdProducto()) : 0 %>
                                        </span>
                                        <% } %>
                                    </div>
                                </div>
                                
                                <!-- Cantidad -->
                                <div class="col-md-2">
                                    <label class="form-label required">Cantidad</label>
                                    <input type="number" class="form-control cantidad-input" 
                                           name="cantidad" 
                                           value="<%= detalle.getCantidad() %>" 
                                           min="1" 
                                           step="1" 
                                           required
                                           onchange="calcularSubtotal(<%= index %>)">
                                </div>
                                
                                <!-- Precio Unitario -->
                                <div class="col-md-2">
                                    <label class="form-label required">Precio Unitario (S/)</label>
                                    <input type="number" class="form-control precio-input precio-unitario" 
                                           name="precioUnitario" 
                                           value="<%= String.format("%.2f", detalle.getPrecioUnitario()) %>" 
                                           min="0" 
                                           step="0.01" 
                                           required
                                           onchange="calcularSubtotal(<%= index %>)">
                                </div>
                                
                                <!-- Fecha Vencimiento -->
                                <div class="col-md-2">
                                    <label class="form-label">Fecha Vencimiento</label>
                                    <input type="date" class="form-control fecha-input" 
                                           name="fechaVencimiento" 
                                           value="<%= detalle.getFechaVencimiento() != null ? sdf.format(detalle.getFechaVencimiento()) : "" %>">
                                </div>
                                
                                <!-- Subtotal -->
                                <div class="col-md-2">
                                    <label class="form-label">Subtotal (S/)</label>
                                    <input type="text" class="form-control subtotal-input" 
                                           id="subtotal_<%= index %>" 
                                           value="<%= String.format("%.2f", detalle.getSubtotal()) %>" 
                                           readonly 
                                           style="font-weight: bold; color: #004aad;">
                                </div>
                                
                                <!-- Campos adicionales -->
                                <div class="col-md-4 mt-2">
                                    <label class="form-label">Lote</label>
                                    <input type="text" class="form-control" 
                                           name="lote_<%= index %>" 
                                           value="<%= detalle.getLote() != null ? detalle.getLote() : "" %>" 
                                           placeholder="Número de lote">
                                </div>
                                
                                <div class="col-md-4 mt-2">
                                    <label class="form-label">Ubicación</label>
                                    <input type="text" class="form-control" 
                                           name="ubicacion_<%= index %>" 
                                           value="<%= detalle.getUbicacion() != null ? detalle.getUbicacion() : "" %>" 
                                           placeholder="Ubicación en almacén">
                                </div>
                                
                                <!-- Botón Eliminar -->
                                <div class="col-md-4 mt-2 d-flex align-items-end">
                                    <button type="button" class="btn btn-danger w-100" 
                                            onclick="eliminarProducto(<%= index %>)">
                                        <i class="bi bi-trash"></i> Eliminar
                                    </button>
                                </div>
                            </div>
                        </div>
                        <% 
                                index++;
                            }
                        } else { %>
                        <!-- Producto inicial vacío -->
                        <div class="text-center py-5" id="sinProductos">
                            <i class="bi bi-box-seam" style="font-size: 3rem; color: #6c757d;"></i>
                            <p class="mt-3 text-muted">No hay productos agregados</p>
                            <p class="small">Haz clic en "Agregar Producto" para comenzar</p>
                        </div>
                        <% } %>
                    </div>
                    
                    <!-- Totales -->
                    <div class="row justify-content-end">
                        <div class="col-md-4">
                            <div class="total-box">
                                <small>TOTAL GUÍA</small>
                                <h3 id="totalGuia">S/ 0.00</h3>
                                <small id="totalProductosText">0 productos</small>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Mensaje de validación -->
                    <div class="alert alert-warning mt-3" id="mensajeValidacion" style="display: none;">
                        <i class="bi bi-exclamation-triangle"></i>
                        <span id="textoValidacion"></span>
                    </div>
                </div>
            </div>
            
            <!-- Botones de Acción -->
            <div class="d-flex justify-content-between mt-4 mb-5">
                <a href="guia?opcion=listar" class="btn btn-secondary">
                    <i class="bi bi-x-circle"></i> Cancelar
                </a>
                
                <div>
                    <% if (esEdicion && "pendiente".equals(guia.getEstado())) { %>
                    <button type="button" class="btn btn-success me-2" onclick="procesarGuia()">
                        <i class="bi bi-check-circle"></i> Marcar como Procesado
                    </button>
                    <% } %>
                    
                    <button type="submit" class="btn btn-orange">
                        <i class="bi bi-save"></i> <%= esEdicion ? "Actualizar Guía" : "Guardar Guía" %>
                    </button>
                </div>
            </div>
        </form>
    </div>
    
    <!-- Modal para confirmar procesamiento -->
    <div class="modal fade" id="modalProcesar" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title">
                        <i class="bi bi-check-circle"></i> Procesar Guía
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>¿Estás seguro de marcar esta guía como <strong>PROCESADA</strong>?</p>
                    <div class="alert alert-info">
                        <i class="bi bi-info-circle"></i> Esta acción:
                        <ul class="mb-0 mt-2">
                            <li>Actualizará el estado a "procesado"</li>
                            <li>Registrará el movimiento en auditoría</li>
                            <li>No podrá editarse nuevamente</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="button" class="btn btn-success" onclick="confirmarProcesar()">
                        <i class="bi bi-check-circle"></i> Sí, Procesar
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Select2 -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    
    <script>
        // Variables globales
        let contadorProductos = <%= esEdicion && guia.getDetalles() != null ? guia.getDetalles().size() : 0 %>;
        let productosEliminados = [];
        
        // Inicializar cuando el DOM esté listo
        document.addEventListener('DOMContentLoaded', function() {
            // Inicializar Select2
            $('.producto-select').select2({
                placeholder: "Seleccionar producto...",
                allowClear: true,
                width: '100%'
            });
            
            // Inicializar valores si hay productos
            if (contadorProductos > 0) {
                for (let i = 0; i < contadorProductos; i++) {
                    inicializarProducto(i);
                }
                actualizarContadorProductos();
                calcularTotal();
            }
            
            // Validar fechas
            document.getElementById('fechaEmision').addEventListener('change', validarFechas);
            document.getElementById('fechaRecepcion').addEventListener('change', validarFechas);
            
            // Prevenir envío del formulario con Enter en campos numéricos
            document.querySelectorAll('input[type="number"]').forEach(input => {
                input.addEventListener('keydown', function(e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                    }
                });
            });
        });
        
        // Agregar nuevo producto
        function agregarProducto() {
            contadorProductos++;
            
            // Ocultar mensaje de sin productos
            document.getElementById('sinProductos')?.style.display = 'none';
            
            // HTML del nuevo producto
            const html = `
                <div class="producto-item" id="productoItem_${contadorProductos}">
                    <div class="row g-3">
                        <!-- Producto -->
                        <div class="col-md-4">
                            <label class="form-label required">Producto</label>
                            <select class="form-select producto-select" name="productoId" required 
                                    onchange="actualizarProducto(${contadorProductos}, this.value)">
                                <option value="">Seleccionar producto...</option>
                                <% for (Catalogo p : productos) { %>
                                <option value="<%= p.getId() %>" 
                                        data-precio="<%= p.getPrecio() %>"
                                        data-stock="<%= p.getStock() %>">
                                    <%= p.getProductos() %> (Stock: <%= p.getStock() %>)
                                </option>
                                <% } %>
                            </select>
                            <input type="hidden" name="productoNombre_<%= p.getId() %>" 
                                   id="productoNombre_${contadorProductos}">
                            <div class="stock-info" id="stockInfo_${contadorProductos}"></div>
                        </div>
                        
                        <!-- Cantidad -->
                        <div class="col-md-2">
                            <label class="form-label required">Cantidad</label>
                            <input type="number" class="form-control cantidad-input" 
                                   name="cantidad" 
                                   value="1" 
                                   min="1" 
                                   step="1" 
                                   required
                                   onchange="calcularSubtotal(${contadorProductos})">
                        </div>
                        
                        <!-- Precio Unitario -->
                        <div class="col-md-2">
                            <label class="form-label required">Precio Unitario (S/)</label>
                            <input type="number" class="form-control precio-input precio-unitario" 
                                   name="precioUnitario" 
                                   value="0.00" 
                                   min="0" 
                                   step="0.01" 
                                   required
                                   onchange="calcularSubtotal(${contadorProductos})">
                        </div>
                        
                        <!-- Fecha Vencimiento -->
                        <div class="col-md-2">
                            <label class="form-label">Fecha Vencimiento</label>
                            <input type="date" class="form-control fecha-input" 
                                   name="fechaVencimiento">
                        </div>
                        
                        <!-- Subtotal -->
                        <div class="col-md-2">
                            <label class="form-label">Subtotal (S/)</label>
                            <input type="text" class="form-control subtotal-input" 
                                   id="subtotal_${contadorProductos}" 
                                   value="0.00" 
                                   readonly 
                                   style="font-weight: bold; color: #004aad;">
                        </div>
                        
                        <!-- Campos adicionales -->
                        <div class="col-md-4 mt-2">
                            <label class="form-label">Lote</label>
                            <input type="text" class="form-control" 
                                   name="lote_${contadorProductos}" 
                                   placeholder="Número de lote">
                        </div>
                        
                        <div class="col-md-4 mt-2">
                            <label class="form-label">Ubicación</label>
                            <input type="text" class="form-control" 
                                   name="ubicacion_${contadorProductos}" 
                                   placeholder="Ubicación en almacén">
                        </div>
                        
                        <!-- Botón Eliminar -->
                        <div class="col-md-4 mt-2 d-flex align-items-end">
                            <button type="button" class="btn btn-danger w-100" 
                                    onclick="eliminarProducto(${contadorProductos})">
                                <i class="bi bi-trash"></i> Eliminar
                            </button>
                        </div>
                    </div>
                </div>
            `;
            
            // Agregar al contenedor
            document.getElementById('contenedorProductos').insertAdjacentHTML('beforeend', html);
            
            // Inicializar Select2 para el nuevo select
            $(`#productoItem_${contadorProductos} .producto-select`).select2({
                placeholder: "Seleccionar producto...",
                allowClear: true,
                width: '100%'
            });
            
            // Actualizar contador
            actualizarContadorProductos();
        }
        
        // Eliminar producto
        function eliminarProducto(index) {
            const productoItem = document.getElementById(`productoItem_${index}`);
            if (!productoItem) return;
            
            // Marcar como eliminado visualmente
            productoItem.classList.add('eliminado');
            productoItem.style.display = 'none';
            
            // Guardar índice para no enviarlo
            productosEliminados.push(index);
            
            // Calcular total sin este producto
            calcularTotal();
            actualizarContadorProductos();
            
            // Mostrar mensaje si no quedan productos visibles
            const productosVisibles = document.querySelectorAll('.producto-item:not(.eliminado)');
            if (productosVisibles.length === 0) {
                document.getElementById('sinProductos').style.display = 'block';
            }
        }
        
        // Actualizar información del producto seleccionado
        function actualizarProducto(index, productoId) {
            const select = document.querySelector(`#productoItem_${index} .producto-select`);
            const selectedOption = select.selectedOptions[0];
            const precioInput = document.querySelector(`#productoItem_${index} .precio-unitario`);
            const stockInfo = document.getElementById(`stockInfo_${index}`);
            
            if (selectedOption && productoId) {
                // Obtener precio y stock del atributo data
                const precio = selectedOption.getAttribute('data-precio');
                const stock = selectedOption.getAttribute('data-stock');
                
                // Actualizar precio
                if (precio) {
                    precioInput.value = parseFloat(precio).toFixed(2);
                }
                
                // Actualizar información de stock
                if (stock) {
                    stockInfo.innerHTML = `Stock actual: <span class="badge-stock">${stock}</span>`;
                }
                
                // Guardar nombre del producto
                const nombreInput = document.getElementById(`productoNombre_${index}`);
                if (nombreInput) {
                    nombreInput.value = selectedOption.text.split(' (Stock:')[0].trim();
                }
                
                // Calcular subtotal
                calcularSubtotal(index);
            }
        }
        
        // Calcular subtotal de un producto
        function calcularSubtotal(index) {
            const cantidadInput = document.querySelector(`#productoItem_${index} .cantidad-input`);
            const precioInput = document.querySelector(`#productoItem_${index} .precio-unitario`);
            const subtotalInput = document.getElementById(`subtotal_${index}`);
            
            if (cantidadInput && precioInput && subtotalInput) {
                const cantidad = parseFloat(cantidadInput.value) || 0;
                const precio = parseFloat(precioInput.value) || 0;
                const subtotal = cantidad * precio;
                
                subtotalInput.value = subtotal.toFixed(2);
                
                // Actualizar total general
                calcularTotal();
            }
        }
        
        // Calcular total de la guía
        function calcularTotal() {
            let total = 0;
            let totalProductos = 0;
            
            // Sumar solo productos no eliminados
            document.querySelectorAll('.producto-item:not(.eliminado)').forEach(item => {
                const subtotalInput = item.querySelector('.subtotal-input');
                const cantidadInput = item.querySelector('.cantidad-input');
                
                if (subtotalInput) {
                    total += parseFloat(subtotalInput.value) || 0;
                }
                if (cantidadInput) {
                    totalProductos += parseInt(cantidadInput.value) || 0;
                }
            });
            
            // Actualizar UI
            document.getElementById('totalGuia').textContent = `S/ ${total.toFixed(2)}`;
            document.getElementById('totalProductosText').textContent = `${totalProductos} producto${totalProductos !== 1 ? 's' : ''}`;
            
            // Si es edición, actualizar campos ocultos para el total
            if (<%= esEdicion %>) {
                document.getElementById('totalProductosHidden').value = totalProductos;
                document.getElementById('totalValorHidden').value = total.toFixed(2);
            }
        }
        
        // Actualizar contador de productos
        function actualizarContadorProductos() {
            const productosVisibles = document.querySelectorAll('.producto-item:not(.eliminado)').length;
            document.getElementById('contadorProductos').textContent = productosVisibles;
        }
        
        // Validar fechas
        function validarFechas() {
            const fechaEmision = new Date(document.getElementById('fechaEmision').value);
            const fechaRecepcion = new Date(document.getElementById('fechaRecepcion').value);
            const mensajeValidacion = document.getElementById('mensajeValidacion');
            const textoValidacion = document.getElementById('textoValidacion');
            
            if (fechaRecepcion < fechaEmision) {
                textoValidacion.textContent = 'La fecha de recepción no puede ser anterior a la fecha de emisión.';
                mensajeValidacion.style.display = 'block';
                return false;
            } else {
                mensajeValidacion.style.display = 'none';
            }
            
            return true;
        }
        
        // Procesar guía
        function procesarGuia() {
            const modal = new bootstrap.Modal(document.getElementById('modalProcesar'));
            modal.show();
        }
        
        // Confirmar procesamiento
        function confirmarProcesar() {
            window.location.href = 'guia?opcion=procesar&id=<%= guia.getIdGuia() %>';
        }
        
        // Inicializar producto existente
        function inicializarProducto(index) {
            // Ya está inicializado en el servidor
            calcularSubtotal(index);
        }
        
        // Validar formulario antes de enviar
        document.getElementById('formGuia').addEventListener('submit', function(e) {
            // Validar fechas
            if (!validarFechas()) {
                e.preventDefault();
                return;
            }
            
            // Validar que haya al menos un producto
            const productosVisibles = document.querySelectorAll('.producto-item:not(.eliminado)');
            if (productosVisibles.length === 0) {
                e.preventDefault();
                alert('Debe agregar al menos un producto a la guía.');
                return;
            }
            
            // Validar que todos los productos tengan cantidad y precio válidos
            let productosValidos = true;
            productosVisibles.forEach(item => {
                const cantidad = item.querySelector('.cantidad-input').value;
                const precio = item.querySelector('.precio-unitario').value;
                
                if (!cantidad || parseFloat(cantidad) <= 0 || !precio || parseFloat(precio) < 0) {
                    productosValidos = false;
                }
            });
            
            if (!productosValidos) {
                e.preventDefault();
                alert('Todos los productos deben tener una cantidad válida (mayor a 0) y precio válido (mayor o igual a 0).');
                return;
            }
            
            // Mostrar mensaje de confirmación
            if (!confirm('¿Está seguro de guardar la guía? El stock se actualizará automáticamente.')) {
                e.preventDefault();
            }
        });
        
        // Función para formatear números como moneda
        function formatCurrency(value) {
            return new Intl.NumberFormat('es-PE', {
                style: 'currency',
                currency: 'PEN'
            }).format(value);
        }
    </script>
</body>
</html>