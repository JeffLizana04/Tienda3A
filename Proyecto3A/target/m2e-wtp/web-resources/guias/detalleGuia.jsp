<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.Proyecto3A.model.Guia, com.Proyecto3A.model.GuiaDetalle" %>
<%@ page import="java.text.SimpleDateFormat, java.text.NumberFormat" %>
<%
    Guia guia = (Guia) request.getAttribute("guia");
    if (guia == null) {
        response.sendRedirect("guia?opcion=listar");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat sdfHora = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    NumberFormat nf = NumberFormat.getCurrencyInstance();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Detalle de Guía - Tiendas 3A</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .header-detalle {
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
            overflow: hidden;
        }
        
        .card-header {
            background-color: #fff;
            border-bottom: 2px solid #004aad;
            font-weight: 600;
            color: #004aad;
            padding: 1rem 1.5rem;
            border-radius: 15px 15px 0 0 !important;
        }
        
        .info-box {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            margin-bottom: 1rem;
            border-left: 4px solid #004aad;
        }
        
        .badge-estado {
            font-size: 0.9rem;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 500;
        }
        
        .badge-pendiente { background-color: #ffc107; color: #000; }
        .badge-procesado { background-color: #28a745; color: white; }
        .badge-anulado { background-color: #dc3545; color: white; }
        
        .total-box {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 1.5rem;
            border-radius: 12px;
            text-align: center;
        }
        
        .total-box h3 {
            margin: 0;
            font-size: 2rem;
            font-weight: 700;
        }
        
        .table-detalles th {
            background-color: #004aad;
            color: white;
            font-weight: 500;
            border: none;
        }
        
        .table-detalles td {
            vertical-align: middle;
        }
        
        .producto-row:hover {
            background-color: rgba(0, 74, 173, 0.05);
        }
        
        .btn-imprimir {
            background: linear-gradient(135deg, #ff6600 0%, #ff8c42 100%);
            border: none;
            color: white;
            font-weight: 500;
            padding: 0.5rem 1.5rem;
            border-radius: 8px;
            transition: all 0.3s;
        }
        
        .btn-imprimir:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(255, 102, 0, 0.3);
        }
        
        .timeline {
            position: relative;
            padding-left: 2rem;
        }
        
        .timeline::before {
            content: '';
            position: absolute;
            left: 10px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #004aad;
        }
        
        .timeline-item {
            position: relative;
            margin-bottom: 1.5rem;
        }
        
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -1.95rem;
            top: 5px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: #004aad;
            border: 2px solid white;
            box-shadow: 0 0 0 3px rgba(0, 74, 173, 0.2);
        }
        
        .qr-code {
            width: 120px;
            height: 120px;
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: #6c757d;
        }
        
        .subtotal {
            font-weight: 600;
            color: #004aad;
        }
        
        .fecha-text {
            color: #6c757d;
            font-size: 0.9rem;
        }
        
        .info-label {
            font-weight: 600;
            color: #495057;
            margin-bottom: 0.25rem;
        }
        
        .info-value {
            color: #212529;
            font-size: 1.1rem;
        }
        
        @media print {
            .no-print {
                display: none !important;
            }
            
            .card {
                box-shadow: none;
                border: 1px solid #dee2e6;
            }
            
            .header-detalle {
                background: #004aad !important;
                -webkit-print-color-adjust: exact;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header-detalle">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h1 class="mb-1">
                        <i class="bi bi-clipboard-data"></i> Detalle de Guía
                    </h1>
                    <p class="mb-0 opacity-75">
                        <strong><%= guia.getNumeroGuia() %></strong> • 
                        <%= sdf.format(guia.getFechaRecepcion()) %> • 
                        <%= guia.getProveedor() %>
                    </p>
                </div>
                <div class="d-flex gap-2">
                    <a href="guia?opcion=listar" class="btn btn-outline-light no-print">
                        <i class="bi bi-arrow-left"></i> Volver
                    </a>
                    <button onclick="window.print()" class="btn btn-imprimir no-print">
                        <i class="bi bi-printer"></i> Imprimir
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <div class="container">
        <div class="row">
            <!-- Columna izquierda: Información principal -->
            <div class="col-lg-8">
                <!-- Resumen -->
                <div class="card mb-4">
                    <div class="card-header">
                        <i class="bi bi-info-circle me-2"></i> Información General
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <div class="info-label">Número de Guía</div>
                                <div class="info-value h5 text-primary"><%= guia.getNumeroGuia() %></div>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <div class="info-label">Estado</div>
                                <div>
                                    <% 
                                        String badgeClass = "";
                                        if ("pendiente".equals(guia.getEstado())) badgeClass = "badge-pendiente";
                                        else if ("procesado".equals(guia.getEstado())) badgeClass = "badge-procesado";
                                        else if ("anulado".equals(guia.getEstado())) badgeClass = "badge-anulado";
                                    %>
                                    <span class="badge-estado <%= badgeClass %>">
                                        <i class="bi bi-circle-fill" style="font-size: 0.6rem;"></i>
                                        <%= guia.getEstado().toUpperCase() %>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <div class="info-label">Proveedor</div>
                                <div class="info-value"><%= guia.getProveedor() %></div>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <div class="info-label">Tienda Destino</div>
                                <div class="info-value">
                                    <%= guia.getTiendaNombre() != null ? guia.getTiendaNombre() : "Tienda #" + guia.getTiendaId() %>
                                </div>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <div class="info-label">Fecha de Emisión</div>
                                <div class="info-value"><%= sdf.format(guia.getFechaEmision()) %></div>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <div class="info-label">Fecha de Recepción</div>
                                <div class="info-value"><%= sdf.format(guia.getFechaRecepcion()) %></div>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <div class="info-label">Registrado por</div>
                                <div class="info-value">
                                    <i class="bi bi-person-circle me-1"></i>
                                    <%= guia.getUsuarioRegistro() %>
                                </div>
                                <div class="fecha-text">
                                    <%= guia.getFechaRegistro() != null ? sdfHora.format(guia.getFechaRegistro()) : "" %>
                                </div>
                            </div>
                            
                            <% if (guia.getUltimoUsuarioModifico() != null) { %>
                            <div class="col-md-6 mb-3">
                                <div class="info-label">Última modificación</div>
                                <div class="info-value">
                                    <i class="bi bi-pencil-square me-1"></i>
                                    <%= guia.getUltimoUsuarioModifico() %>
                                </div>
                                <div class="fecha-text">
                                    <%= guia.getFechaUltimaModificacion() != null ? sdfHora.format(guia.getFechaUltimaModificacion()) : "" %>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
                
                <!-- Productos -->
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <div>
                            <i class="bi bi-box-seam me-2"></i> Productos
                            <span class="badge bg-secondary"><%= guia.getTotalProductos() %></span>
                        </div>
                        <div class="total-box" style="padding: 0.5rem 1rem; min-width: 180px;">
                            <small>TOTAL</small>
                            <h3 style="font-size: 1.5rem; margin: 0;"><%= nf.format(guia.getTotalValor()) %></h3>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover table-detalles mb-0">
                                <thead>
                                    <tr>
                                        <th width="5%">#</th>
                                        <th width="40%">Producto</th>
                                        <th width="10%" class="text-center">Cantidad</th>
                                        <th width="15%" class="text-end">Precio Unit.</th>
                                        <th width="15%" class="text-end">Subtotal</th>
                                        <th width="15%">Detalles</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                        if (guia.getDetalles() != null && !guia.getDetalles().isEmpty()) {
                                            int contador = 1;
                                            for (GuiaDetalle detalle : guia.getDetalles()) { 
                                    %>
                                    <tr class="producto-row">
                                        <td><strong><%= contador %></strong></td>
                                        <td>
                                            <strong><%= detalle.getProductoNombre() %></strong><br>
                                            <small class="text-muted">ID: <%= detalle.getIdProducto() %></small>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-primary" style="font-size: 1rem;">
                                                <%= detalle.getCantidad() %>
                                            </span>
                                        </td>
                                        <td class="text-end"><%= nf.format(detalle.getPrecioUnitario()) %></td>
                                        <td class="text-end subtotal"><%= nf.format(detalle.getSubtotal()) %></td>
                                        <td>
                                            <% if (detalle.getFechaVencimiento() != null) { %>
                                            <small class="d-block">
                                                <i class="bi bi-calendar-check"></i> 
                                                <%= sdf.format(detalle.getFechaVencimiento()) %>
                                            </small>
                                            <% } %>
                                            <% if (detalle.getLote() != null && !detalle.getLote().isEmpty()) { %>
                                            <small class="d-block">
                                                <i class="bi bi-tag"></i> Lote: <%= detalle.getLote() %>
                                            </small>
                                            <% } %>
                                            <% if (detalle.getUbicacion() != null && !detalle.getUbicacion().isEmpty()) { %>
                                            <small class="d-block">
                                                <i class="bi bi-geo-alt"></i> <%= detalle.getUbicacion() %>
                                            </small>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <% 
                                                contador++;
                                            }
                                        } else { 
                                    %>
                                    <tr>
                                        <td colspan="6" class="text-center py-4 text-muted">
                                            <i class="bi bi-inbox" style="font-size: 2rem;"></i><br>
                                            No hay productos en esta guía
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <td colspan="4" class="text-end"><strong>TOTAL:</strong></td>
                                        <td class="text-end">
                                            <h5 class="mb-0 text-success"><%= nf.format(guia.getTotalValor()) %></h5>
                                        </td>
                                        <td></td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Columna derecha: Acciones y timeline -->
            <div class="col-lg-4">
                <!-- Acciones -->
                <% if ("pendiente".equals(guia.getEstado())) { %>
                <div class="card mb-4 no-print">
                    <div class="card-header">
                        <i class="bi bi-lightning-charge me-2"></i> Acciones Rápidas
                    </div>
                    <div class="card-body">
                        <div class="d-grid gap-2">
                            <a href="guia?opcion=editar&id=<%= guia.getIdGuia() %>" 
                               class="btn btn-primary">
                                <i class="bi bi-pencil-square"></i> Editar Guía
                            </a>
                            
                            <a href="guia?opcion=procesar&id=<%= guia.getIdGuia() %>" 
                               class="btn btn-success"
                               onclick="return confirm('¿Marcar esta guía como procesada?')">
                                <i class="bi bi-check-circle"></i> Marcar como Procesado
                            </a>
                            
                            <a href="guia?opcion=anular&id=<%= guia.getIdGuia() %>" 
                               class="btn btn-danger"
                               onclick="return confirm('¿Anular esta guía? Se revertirá el stock.')">
                                <i class="bi bi-x-circle"></i> Anular Guía
                            </a>
                        </div>
                    </div>
                </div>
                <% } %>
                
                <!-- Resumen numérico -->
                <div class="card mb-4">
                    <div class="card-header">
                        <i class="bi bi-calculator me-2"></i> Resumen
                    </div>
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col-6 mb-3">
                                <div class="info-label">Productos</div>
                                <div class="info-value h3"><%= guia.getTotalProductos() %></div>
                                <small class="fecha-text">unidades</small>
                            </div>
                            <div class="col-6 mb-3">
                                <div class="info-label">Valor Total</div>
                                <div class="info-value h3 text-success"><%= nf.format(guia.getTotalValor()) %></div>
                                <small class="fecha-text">Soles</small>
                            </div>
                            <div class="col-6">
                                <div class="info-label">Items</div>
                                <div class="info-value h4">
                                    <%= guia.getDetalles() != null ? guia.getDetalles().size() : 0 %>
                                </div>
                                <small class="fecha-text">productos diferentes</small>
                            </div>
                            <div class="col-6">
                                <div class="info-label">Promedio</div>
                                <div class="info-value h4">
                                    <% 
                                        double promedio = 0;
                                        if (guia.getTotalProductos() > 0 && guia.getTotalValor() > 0) {
                                            promedio = guia.getTotalValor() / guia.getTotalProductos();
                                        }
                                    %>
                                    <%= String.format("S/ %.2f", promedio) %>
                                </div>
                                <small class="fecha-text">por unidad</small>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Timeline -->
                <div class="card">
                    <div class="card-header">
                        <i class="bi bi-clock-history me-2"></i> Historial
                    </div>
                    <div class="card-body">
                        <div class="timeline">
                            <!-- Creación -->
                            <div class="timeline-item">
                                <div class="info-label">Guía Creada</div>
                                <div class="info-value">
                                    <i class="bi bi-person-circle me-1"></i>
                                    <%= guia.getUsuarioRegistro() %>
                                </div>
                                <div class="fecha-text">
                                    <%= guia.getFechaRegistro() != null ? sdfHora.format(guia.getFechaRegistro()) : "" %>
                                </div>
                            </div>
                            
                            <!-- Última modificación -->
                            <% if (guia.getUltimoUsuarioModifico() != null) { %>
                            <div class="timeline-item">
                                <div class="info-label">Última Modificación</div>
                                <div class="info-value">
                                    <i class="bi bi-pencil-square me-1"></i>
                                    <%= guia.getUltimoUsuarioModifico() %>
                                </div>
                                <div class="fecha-text">
                                    <%= guia.getFechaUltimaModificacion() != null ? sdfHora.format(guia.getFechaUltimaModificacion()) : "" %>
                                </div>
                            </div>
                            <% } %>
                            
                            <!-- Estado actual -->
                            <div class="timeline-item">
                                <div class="info-label">Estado Actual</div>
                                <div class="info-value">
                                    <span class="badge-estado <%= badgeClass %>">
                                        <%= guia.getEstado().toUpperCase() %>
                                    </span>
                                </div>
                                <div class="fecha-text">
                                    Actualizado 
                                    <%= guia.getFechaUltimaModificacion() != null ? 
                                        sdf.format(guia.getFechaUltimaModificacion()) : 
                                        guia.getFechaRegistro() != null ? 
                                            sdf.format(guia.getFechaRegistro()) : "" %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- QR Code (placeholder) -->
                <div class="card mt-4 no-print">
                    <div class="card-header">
                        <i class="bi bi-qr-code me-2"></i> Código QR
                    </div>
                    <div class="card-body text-center">
                        <div class="qr-code mx-auto mb-3">
                            <i class="bi bi-qr-code-scan"></i>
                        </div>
                        <small class="text-muted d-block">
                            Escanee para ver detalles en el móvil
                        </small>
                        <small class="text-muted">
                            ID: <%= guia.getIdGuia() %>
                        </small>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Nota para impresión -->
        <div class="row mt-4 d-print-block" style="display: none;">
            <div class="col-12">
                <div class="alert alert-light border">
                    <small>
                        <strong>Documento generado:</strong> <%= new java.util.Date() %><br>
                        <strong>Sistema:</strong> Tiendas 3A - Gestión de Inventario<br>
                        <strong>Usuario:</strong> <%= session.getAttribute("nombreUsuario") != null ? session.getAttribute("nombreUsuario") : "Sistema" %>
                    </small>
                </div>
            </div>
        </div>
        
        <!-- Footer con botones -->
        <div class="d-flex justify-content-between mt-4 mb-5 no-print">
            <a href="guia?opcion=listar" class="btn btn-secondary">
                <i class="bi bi-arrow-left"></i> Volver al Listado
            </a>
            
            <div class="btn-group">
                <button onclick="window.print()" class="btn btn-outline-primary">
                    <i class="bi bi-printer"></i> Imprimir
                </button>
                <a href="#" class="btn btn-outline-success" onclick="alert('Función de exportar a PDF en desarrollo')">
                    <i class="bi bi-file-earmark-pdf"></i> Exportar PDF
                </a>
                <a href="#" class="btn btn-outline-dark" onclick="alert('Función de exportar a Excel en desarrollo')">
                    <i class="bi bi-file-earmark-excel"></i> Excel
                </a>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Función para imprimir solo la sección específica
        function printGuia() {
            window.print();
        }
        
        // Confirmar acciones
        function confirmarAccion(accion, mensaje) {
            return confirm(mensaje || `¿Está seguro de ${accion} esta guía?`);
        }
        
        // Agregar clase de impresión a elementos específicos
        document.addEventListener('DOMContentLoaded', function() {
            // Agregar evento para imprimir
            const printBtn = document.querySelector('[onclick="window.print()"]');
            if (printBtn) {
                printBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    window.print();
                });
            }
        });
    </script>
</body>
</html>