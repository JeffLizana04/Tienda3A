// GuiaServlet.java
package com.Proyecto3A.servlets;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.Proyecto3A.dao.CatalogoDao;
import com.Proyecto3A.model.Catalogo;
import com.Proyecto3A.model.Guia;
import com.Proyecto3A.model.GuiaDetalle;
import com.Proyecto3A.service.GuiaService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/guia")
public class GuiaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private GuiaService guiaService;
    
    @Override
    public void init() throws ServletException {
        super.init();
        guiaService = new GuiaService();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("rolUsuario") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        
        // Verificar permisos del rol
        String rol = (String) session.getAttribute("rolUsuario");
        if (!rol.equalsIgnoreCase("jefetienda") && !rol.equalsIgnoreCase("administrador")) {
            response.sendRedirect(request.getContextPath() + "/principal.jsp?error=Acceso+denegado+para+su+rol");
            return;
        }
        
        String opcion = request.getParameter("opcion");
        if (opcion == null) opcion = "listar";
        
        try {
            switch (opcion) {
                case "listar":
                    listarGuias(request, response);
                    break;
                case "nuevo":
                    mostrarFormularioNuevo(request, response);
                    break;
                case "editar":
                    mostrarFormularioEdicion(request, response);
                    break;
                case "detalle":
                    mostrarDetalle(request, response);
                    break;
                case "procesar":
                    procesarGuia(request, response);
                    break;
                case "anular":
                    anularGuia(request, response);
                    break;
                case "buscar":
                    buscarGuias(request, response);
                    break;
                default:
                    listarGuias(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("rolUsuario") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        
        // Verificar permisos del rol
        String rol = (String) session.getAttribute("rolUsuario");
        if (!rol.equalsIgnoreCase("jefetienda") && !rol.equalsIgnoreCase("administrador")) {
            response.sendRedirect(request.getContextPath() + "/principal.jsp?error=Acceso+denegado+para+su+rol");
            return;
        }
        
        String opcion = request.getParameter("opcion");
        String usuario = (String) session.getAttribute("nombreUsuario");
        
        try {
            switch (opcion) {
                case "guardar":
                    guardarGuia(request, response, usuario);
                    break;
                case "actualizar":
                    actualizarGuia(request, response, usuario);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/guia?opcion=listar");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
    
    // ========== MÉTODOS PRIVADOS ==========
    
    private void listarGuias(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Guia> guias = guiaService.obtenerTodasGuias();
        request.setAttribute("guias", guias);
        request.getRequestDispatcher("guias/listarGuias.jsp").forward(request, response);
    }
    
    private void mostrarFormularioNuevo(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            System.out.println("DEBUG: Mostrando formulario nuevo...");
            
            // Obtener productos para el selector
            System.out.println("DEBUG: Creando CatalogoDao...");
            CatalogoDao catalogoDao = new CatalogoDao();
            
            System.out.println("DEBUG: Llamando a listarProductosConStock...");
            List<Catalogo> productos = catalogoDao.listarProductosConStock();
            
            System.out.println("DEBUG: Productos obtenidos: " + (productos != null ? productos.size() : 0));
            
            if (productos != null && !productos.isEmpty()) {
                for (Catalogo p : productos) {
                    System.out.println("  - " + p.getProductos() + " (ID: " + p.getId() + ")");
                }
            }
            
            request.setAttribute("productos", productos);
            request.getRequestDispatcher("guias/formGuia.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("ERROR en mostrarFormularioNuevo: " + e.getMessage());
            e.printStackTrace();
            
            // Enviar error a la página
            request.setAttribute("error", "Error al cargar productos: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
    
    private void mostrarFormularioEdicion(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Guia guia = guiaService.obtenerGuiaPorId(id);
            
            if (guia == null) {
                request.setAttribute("error", "Guía no encontrada");
                response.sendRedirect(request.getContextPath() + "/guia?opcion=listar");
                return;
            }
            
            // Verificar que la guía sea editable
            if (!"pendiente".equals(guia.getEstado())) {
                request.getSession().setAttribute("error", "Solo las guías pendientes pueden editarse");
                response.sendRedirect(request.getContextPath() + "/guia?opcion=listar");
                return;
            }
            
            // Obtener productos para el selector
            CatalogoDao catalogoDao = new CatalogoDao();
            List<Catalogo> productos = catalogoDao.listarProductosConStock();
            
            request.setAttribute("productos", productos);
            request.setAttribute("guia", guia);
            request.getRequestDispatcher("guias/formGuia.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("ERROR en mostrarFormularioEdicion: " + e.getMessage());
            e.printStackTrace();
            
            request.setAttribute("error", "Error al cargar guía: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
    
    private void mostrarDetalle(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Guia guia = guiaService.obtenerGuiaPorId(id);
        
        if (guia != null) {
            request.setAttribute("guia", guia);
            request.getRequestDispatcher("guias/detalleGuia.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Guía no encontrada");
            response.sendRedirect(request.getContextPath() + "/guia?opcion=listar");
        }
    }
    
    private void procesarGuia(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        String usuario = (String) request.getSession().getAttribute("nombreUsuario");
        
        boolean success = guiaService.cambiarEstadoGuia(id, "procesado", usuario);
        
        if (success) {
            request.getSession().setAttribute("mensaje", "Guía procesada exitosamente");
        } else {
            request.getSession().setAttribute("error", "Error al procesar la guía");
        }
        
        response.sendRedirect(request.getContextPath() + "/guia?opcion=listar");
    }
    
    private void anularGuia(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        String usuario = (String) request.getSession().getAttribute("nombreUsuario");
        
        boolean success = guiaService.anularGuia(id, usuario);
        
        if (success) {
            request.getSession().setAttribute("mensaje", "Guía anulada exitosamente");
        } else {
            request.getSession().setAttribute("error", "Error al anular la guía");
        }
        
        response.sendRedirect(request.getContextPath() + "/guia?opcion=listar");
    }
    
    private void buscarGuias(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, ParseException {
        
        String numeroGuia = request.getParameter("numeroGuia");
        String estado = request.getParameter("estado");
        String fechaInicioStr = request.getParameter("fechaInicio");
        String fechaFinStr = request.getParameter("fechaFin");
        String tiendaIdStr = request.getParameter("tiendaId");
        
        Date fechaInicio = null;
        Date fechaFin = null;
        Integer tiendaId = null;
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        
        if (fechaInicioStr != null && !fechaInicioStr.isEmpty()) {
            fechaInicio = sdf.parse(fechaInicioStr);
        }
        if (fechaFinStr != null && !fechaFinStr.isEmpty()) {
            fechaFin = sdf.parse(fechaFinStr);
        }
        if (tiendaIdStr != null && !tiendaIdStr.isEmpty()) {
            tiendaId = Integer.parseInt(tiendaIdStr);
        }
        
        List<Guia> guias = guiaService.buscarGuias(numeroGuia, fechaInicio, fechaFin, estado, tiendaId);
        
        request.setAttribute("guias", guias);
        request.setAttribute("numeroGuia", numeroGuia);
        request.setAttribute("estado", estado);
        request.setAttribute("fechaInicio", fechaInicioStr);
        request.setAttribute("fechaFin", fechaFinStr);
        request.setAttribute("tiendaId", tiendaIdStr);
        
        request.getRequestDispatcher("guias/listarGuias.jsp").forward(request, response);
    }
    
    private void guardarGuia(HttpServletRequest request, HttpServletResponse response, String usuario) 
            throws ServletException, IOException, ParseException {
        
        Guia guia = construirGuiaDesdeRequest(request);
        String error = guiaService.validarGuia(guia);
        
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("guia", guia);
            
            // Recargar productos para el formulario
            CatalogoDao catalogoDao = new CatalogoDao();
            List<Catalogo> productos = catalogoDao.listarProductosConStock();
            request.setAttribute("productos", productos);
            
            request.getRequestDispatcher("guias/formGuia.jsp").forward(request, response);
            return;
        }
        
        boolean success = guiaService.crearGuia(guia, usuario);
        
        if (success) {
            request.getSession().setAttribute("mensaje", "Guía creada exitosamente. Stock actualizado.");
            response.sendRedirect(request.getContextPath() + "/guia?opcion=listar");
        } else {
            request.setAttribute("error", "Error al crear la guía");
            request.setAttribute("guia", guia);
            
            // Recargar productos para el formulario
            CatalogoDao catalogoDao = new CatalogoDao();
            List<Catalogo> productos = catalogoDao.listarProductosConStock();
            request.setAttribute("productos", productos);
            
            request.getRequestDispatcher("guias/formGuia.jsp").forward(request, response);
        }
    }
    
    private void actualizarGuia(HttpServletRequest request, HttpServletResponse response, String usuario) 
            throws ServletException, IOException, ParseException {
        
        int idGuia = Integer.parseInt(request.getParameter("idGuia"));
        Guia guia = construirGuiaDesdeRequest(request);
        guia.setIdGuia(idGuia);
        
        String error = guiaService.validarGuia(guia);
        
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("guia", guia);
            
            // Recargar productos para el formulario
            CatalogoDao catalogoDao = new CatalogoDao();
            List<Catalogo> productos = catalogoDao.listarProductosConStock();
            request.setAttribute("productos", productos);
            
            request.getRequestDispatcher("guias/formGuia.jsp").forward(request, response);
            return;
        }
        
        boolean success = guiaService.actualizarGuia(guia, usuario);
        
        if (success) {
            request.getSession().setAttribute("mensaje", "Guía actualizada exitosamente");
            response.sendRedirect(request.getContextPath() + "/guia?opcion=listar");
        } else {
            request.setAttribute("error", "Error al actualizar la guía");
            request.setAttribute("guia", guia);
            
            // Recargar productos para el formulario
            CatalogoDao catalogoDao = new CatalogoDao();
            List<Catalogo> productos = catalogoDao.listarProductosConStock();
            request.setAttribute("productos", productos);
            
            request.getRequestDispatcher("guias/formGuia.jsp").forward(request, response);
        }
    }
    
    private Guia construirGuiaDesdeRequest(HttpServletRequest request) throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        
        Guia guia = new Guia();
        guia.setNumeroGuia(request.getParameter("numeroGuia"));
        guia.setProveedor(request.getParameter("proveedor"));
        
        String fechaEmisionStr = request.getParameter("fechaEmision");
        String fechaRecepcionStr = request.getParameter("fechaRecepcion");
        
        if (fechaEmisionStr != null && !fechaEmisionStr.isEmpty()) {
            guia.setFechaEmision(sdf.parse(fechaEmisionStr));
        }
        
        if (fechaRecepcionStr != null && !fechaRecepcionStr.isEmpty()) {
            guia.setFechaRecepcion(sdf.parse(fechaRecepcionStr));
        }
        
        String tiendaIdStr = request.getParameter("tiendaId");
        if (tiendaIdStr != null && !tiendaIdStr.isEmpty()) {
            guia.setTiendaId(Integer.parseInt(tiendaIdStr));
        }
        
        guia.setEstado(request.getParameter("estado"));
        
        // Construir detalles
        String[] productosId = request.getParameterValues("productoId");
        String[] cantidades = request.getParameterValues("cantidad");
        String[] precios = request.getParameterValues("precioUnitario");
        String[] fechasVencimiento = request.getParameterValues("fechaVencimiento");
        
        List<GuiaDetalle> detalles = new ArrayList<>();
        
        if (productosId != null) {
            for (int i = 0; i < productosId.length; i++) {
                if (productosId[i] == null || productosId[i].isEmpty()) {
                    continue;
                }
                
                GuiaDetalle detalle = new GuiaDetalle();
                detalle.setIdProducto(Integer.parseInt(productosId[i]));
                
                // Obtener nombre del producto
                String productoNombre = request.getParameter("productoNombre_" + productosId[i]);
                if (productoNombre == null) {
                    productoNombre = "Producto " + productosId[i];
                }
                detalle.setProductoNombre(productoNombre);
                
                if (cantidades != null && i < cantidades.length && cantidades[i] != null && !cantidades[i].isEmpty()) {
                    detalle.setCantidad(Integer.parseInt(cantidades[i]));
                }
                
                if (precios != null && i < precios.length && precios[i] != null && !precios[i].isEmpty()) {
                    detalle.setPrecioUnitario(Double.parseDouble(precios[i]));
                }
                
                if (fechasVencimiento != null && i < fechasVencimiento.length && 
                    fechasVencimiento[i] != null && !fechasVencimiento[i].isEmpty()) {
                    detalle.setFechaVencimiento(sdf.parse(fechasVencimiento[i]));
                }
                
                // Calcular subtotal
                detalle.setSubtotal(detalle.getCantidad() * detalle.getPrecioUnitario());
                
                // Campos adicionales
                String loteParam = request.getParameter("lote_" + i);
                if (loteParam != null) {
                    detalle.setLote(loteParam);
                }
                
                String ubicacionParam = request.getParameter("ubicacion_" + i);
                if (ubicacionParam != null) {
                    detalle.setUbicacion(ubicacionParam);
                }
                
                detalles.add(detalle);
            }
        }
        
        guia.setDetalles(detalles);
        
        // Calcular totales
        int totalProductos = 0;
        double totalValor = 0.0;
        
        for (GuiaDetalle detalle : detalles) {
            totalProductos += detalle.getCantidad();
            totalValor += detalle.getSubtotal();
        }
        
        guia.setTotalProductos(totalProductos);
        guia.setTotalValor(totalValor);
        
        return guia;
    }
}