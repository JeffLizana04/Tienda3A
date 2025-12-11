package com.Proyecto3A.controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.*;

@WebFilter("/*")
public class SecurityFilter implements Filter {
    
    // Definir permisos por rol
    private static final Map<String, List<String>> PERMISOS_POR_ROL = new HashMap<>();
    
    static {
        
        // PERMISOS PARA REPONEDOR - SIN ACCESO A GUIAS
        PERMISOS_POR_ROL.put("reponedor", Arrays.asList(
            "/principal.jsp", "/catalogo.jsp", "/productosDescuento.jsp",
            "/home", "/logout"
        ));
        
        // PERMISOS PARA JEFE DE TIENDA - CON ACCESO COMPLETO A PRODUCTOS Y GUIAS
        PERMISOS_POR_ROL.put("jefetienda", Arrays.asList(
            // Páginas principales
            "/principal.jsp", "/catalogo.jsp", "/productosDescuento.jsp",
            
            // Gestión de ofertas
            "/ofertaCatalogo.jsp", "/quitarOferta.jsp", "/sugerirOferta.jsp",
            
            // Gestión completa de catálogo (agregar, editar, cambiar estado)
            "/editarCatalogo.jsp", "/agregarCatalogo.jsp", "/cambiarEstadoCatalogo.jsp",
            
            // Gestión de stock/inventario
            "/inventario.jsp", "/stock.jsp", "/gestionStock.jsp", "/ajustarStock.jsp",
            "/actualizarStock.jsp", "/historialStock.jsp", "/movimientosStock.jsp",
            
            // Servlets para gestión de stock
            "/StockServlet", "/InventarioServlet", "/GestionStockServlet",
            
            // GUIAS DE INGRESO
            "/guia", "/guia.jsp", "/guias/",
            "/guias/listarGuias.jsp", "/guias/formGuia.jsp", "/guias/detalleGuia.jsp",
            "/GuiaServlet",
            
            // CIERRE MENSUAL
            "/cierreMensual.jsp", "/detalleCierre.jsp", "/estadisticasCierre.jsp", "/resumenCierre.jsp",
            "/CierreMensualServlet", "/CierreMensualServlet?opcion=listar",
            "/CierreMensualServlet?opcion=ver", "/CierreMensualServlet?opcion=estadisticas",
            "/CierreMensualServlet?opcion=resumen",
            
            // Servlets para gestión de productos
            "/ProductoServlet", "/CatalogoServlet", "/GestionProductosServlet",
            
            // Otros
            "/home", "/logout"
        ));
        
        // PERMISOS PARA ADMINISTRADOR (rolid = 3) - Acceso total incluyendo gestión de personal
        PERMISOS_POR_ROL.put("administrador", Arrays.asList(
            "/*",  // Acceso total a todo
            "/principal.jsp",
            "/personal.jsp",
            "/gestionUsuarios.jsp",
            "/home",
            "/GestionPersonalServlet",
            "/GestionPermisosServlet",
            "/CargarPermisosServlet",
            "/VerificarCorreoServlet",
            "/auditoria.jsp",
            "/catalogo.jsp",
            "/productosDescuento.jsp"
        ));
        
        // También puedes definir otros roles si los necesitas
        PERMISOS_POR_ROL.put("invitado", Arrays.asList(
            "/", "/index.jsp", "/login"
        ));
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
        String queryString = httpRequest.getQueryString();
        String fullPath = path + (queryString != null ? "?" + queryString : "");
        
        System.out.println("FILTER DEBUG - Ruta accedida: " + fullPath);
        System.out.println("FILTER DEBUG - Path: " + path);
        
        // Páginas públicas (sin restricción)
        if (path.equals("/") || path.equals("/index.jsp") || path.equals("/login")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Recursos estáticos (CSS, JS, imágenes)
        if (path.startsWith("/imagenes/") || path.startsWith("/css/") || path.startsWith("/js/") ||
            path.startsWith("/assets/") || path.startsWith("/vendor/")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Verificar si está logueado
        if (session == null || session.getAttribute("rolUsuario") == null) {
            System.out.println("FILTER DEBUG - No hay sesión, redirigiendo a login");
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/index.jsp");
            return;
        }
        
        String rol = (String) session.getAttribute("rolUsuario");
        List<String> permisos = PERMISOS_POR_ROL.get(rol.toLowerCase());
        
        System.out.println("FILTER DEBUG - Usuario rol: " + rol);
        System.out.println("FILTER DEBUG - Path actual: " + path);
        
        // Si el rol no está definido, denegar acceso
        if (permisos == null) {
            System.out.println("FILTER DEBUG - Rol no válido: " + rol);
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, 
                "Rol no válido o no tiene permisos asignados");
            return;
        }
        
        // Verificar permisos
        boolean permitido = false;
        
        // 1. Si tiene acceso total (administrador)
        if (permisos.contains("/*")) {
            permitido = true;
            System.out.println("FILTER DEBUG - Acceso total permitido para administrador");
        } 
        // 2. Verificar rutas específicas
        else {
            for (String permiso : permisos) {
                // Verificar coincidencia exacta
                if (path.equals(permiso) || fullPath.equals(permiso)) {
                    permitido = true;
                    System.out.println("FILTER DEBUG - Permiso exacto encontrado: " + permiso);
                    break;
                }
                // Verificar si el path comienza con el permiso
                else if (path.startsWith(permiso) && permiso.length() > 1) {
                    permitido = true;
                    System.out.println("FILTER DEBUG - Permiso parcial encontrado: " + permiso);
                    break;
                }
                // Verificar si es una ruta de guía
                else if (path.equals("/guia") && permiso.equals("/guia")) {
                    permitido = true;
                    System.out.println("FILTER DEBUG - Permiso para /guia encontrado");
                    break;
                }
                // Verificar si está dentro de la carpeta guias
                else if (path.startsWith("/guias/") && permiso.equals("/guias/")) {
                    permitido = true;
                    System.out.println("FILTER DEBUG - Permiso para /guias/ encontrado");
                    break;
                }
                // Verificar si es el servlet de guía
                else if (path.equals("/guia") && permiso.equals("/GuiaServlet")) {
                    permitido = true;
                    System.out.println("FILTER DEBUG - Permiso para GuiaServlet encontrado");
                    break;
                }
            }
        }
        
        if (permitido) {
            System.out.println("FILTER DEBUG - Acceso PERMITIDO a: " + fullPath);
            chain.doFilter(request, response);
        } else {
            // Acceso denegado
            System.out.println("FILTER DEBUG - Acceso DENEGADO a: " + fullPath);
            System.out.println("FILTER DEBUG - Rol actual: " + rol);
            System.out.println("FILTER DEBUG - Permisos disponibles para este rol: " + permisos);
            
            // Redirigir a página de acceso denegado o a principal
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/principal.jsp?error=Acceso+denegado");
        }
    }
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("SecurityFilter inicializado");
    }
    
    @Override
    public void destroy() {
        System.out.println("SecurityFilter destruido");
    }
}