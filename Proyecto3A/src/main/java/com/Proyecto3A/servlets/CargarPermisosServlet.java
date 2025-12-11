package com.Proyecto3A.servlets;

import java.io.*;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import com.Proyecto3A.dao.PermisosDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/CargarPermisosServlet")
public class CargarPermisosServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            int rolId = Integer.parseInt(request.getParameter("rol_id"));
            PermisosDao permisosDao = new PermisosDao();
            List<Map<String, Object>> permisos = permisosDao.obtenerPermisosPorRol(rolId);
            
            // Agrupar permisos por categoría
            String categoriaActual = "";
            boolean primeraCategoria = true;
            
            for (Map<String, Object> permiso : permisos) {
                String categoria = (String) permiso.get("categoria");
                
                if (!categoria.equals(categoriaActual)) {
                    if (!primeraCategoria) {
                        out.println("</div></div>");
                    }
                    out.println("<div class='card mb-3'>");
                    out.println("<div class='card-header bg-light'>");
                    out.println("<h6 class='mb-0'><i class='bi bi-folder me-2'></i>" + categoria + "</h6>");
                    out.println("</div>");
                    out.println("<div class='card-body'>");
                    out.println("<div class='row'>");
                    categoriaActual = categoria;
                    primeraCategoria = false;
                }
                
                int permisoId = (Integer) permiso.get("id");
                String nombre = (String) permiso.get("nombre");
                String descripcion = (String) permiso.get("descripcion");
                boolean tienePermiso = (Boolean) permiso.get("tiene_permiso");
                
                out.println("<div class='col-md-4 mb-3'>");
                out.println("<div class='form-check'>");
                out.println("<input class='form-check-input' type='checkbox' " +
                           "name='permiso_" + permisoId + "' " +
                           "id='permiso_" + permisoId + "' " +
                           (tienePermiso ? "checked" : "") + " value='1'>");
                out.println("<label class='form-check-label' for='permiso_" + permisoId + "'>");
                out.println("<strong>" + nombre + "</strong><br>");
                out.println("<small class='text-muted'>" + descripcion + "</small>");
                out.println("</label>");
                out.println("</div>");
                out.println("</div>");
            }
            
            if (!primeraCategoria) {
                out.println("</div></div></div>");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<div class='alert alert-danger'>Error al cargar permisos: " + e.getMessage() + "</div>");
        } catch (NumberFormatException e) {
            out.println("<div class='alert alert-danger'>ID de rol inválido</div>");
        }
    }
}