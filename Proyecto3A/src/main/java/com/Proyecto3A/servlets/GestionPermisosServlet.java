package com.Proyecto3A.servlets;

import java.io.*;
import java.util.*;
import com.Proyecto3A.dao.PermisosDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/GestionPermisosServlet")
public class GestionPermisosServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String mensaje = "";
        String tipoMensaje = "success";
        
        HttpSession session = request.getSession();
        String usuarioSesion = (String) session.getAttribute("nombreUsuario");
        
        try {
            int rolId = Integer.parseInt(request.getParameter("rol_id"));
            
            // Obtener permisos seleccionados
            List<Integer> permisosSeleccionados = new ArrayList<>();
            Enumeration<String> paramNames = request.getParameterNames();
            
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                if (paramName.startsWith("permiso_")) {
                    int permisoId = Integer.parseInt(paramName.substring(8));
                    permisosSeleccionados.add(permisoId);
                }
            }
            
            // Actualizar permisos
            PermisosDao permisosDao = new PermisosDao();
            boolean actualizado = permisosDao.actualizarPermisosRol(rolId, permisosSeleccionados, usuarioSesion);
            
            if (actualizado) {
                String nombreRol = permisosDao.obtenerNombreRol(rolId);
                mensaje = "Permisos actualizados para el rol: " + nombreRol + " (" + permisosSeleccionados.size() + " permisos asignados)";
            } else {
                mensaje = "Error al actualizar permisos";
                tipoMensaje = "danger";
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            mensaje = "Error: " + e.getMessage();
            tipoMensaje = "danger";
        }
        
        // Guardar mensaje y redirigir
        session.setAttribute("mensaje", mensaje);
        session.setAttribute("tipoMensaje", tipoMensaje);
        response.sendRedirect("personal.jsp");
    }
}