package com.Proyecto3A.servlets;

import java.io.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;
import com.Proyecto3A.dao.PersonalDao;
import com.Proyecto3A.model.Usuario;

@WebServlet("/GestionPersonalServlet")
public class GestionPersonalServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(false);
        
        // Verificar sesión
        if (session == null || session.getAttribute("nombreUsuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String usuarioSesion = (String) session.getAttribute("nombreUsuario");
        String accion = request.getParameter("accion");
        String mensaje = "";
        String tipoMensaje = "success";
        
        try {
            PersonalDao personalDao = new PersonalDao();
            
            switch (accion) {
                case "crear":
                    mensaje = crearUsuario(request, personalDao, usuarioSesion);
                    break;
                    
                case "actualizar":
                    mensaje = actualizarUsuario(request, personalDao, usuarioSesion);
                    break;
                    
                case "cambiarEstado":
                    mensaje = cambiarEstadoUsuario(request, personalDao, usuarioSesion);
                    break;
                    
                default:
                    mensaje = "Acción no válida";
                    tipoMensaje = "danger";
                    break;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            mensaje = "Error en la base de datos: " + e.getMessage();
            tipoMensaje = "danger";
        } catch (Exception e) {
            e.printStackTrace();
            mensaje = "Error: " + e.getMessage();
            tipoMensaje = "danger";
        }
        
        // Redirigir con mensaje
        response.sendRedirect("gestionUsuarios.jsp?mensaje=" + 
                java.net.URLEncoder.encode(mensaje, "UTF-8") + 
                "&tipo=" + tipoMensaje);
    }
    
    private String crearUsuario(HttpServletRequest request, PersonalDao personalDao, String usuarioSesion) 
            throws SQLException {
        
        Usuario usuario = new Usuario();
        usuario.setNombre(request.getParameter("nombre"));
        usuario.setCorreo(request.getParameter("correo"));
        usuario.setContrasenha(request.getParameter("contrasenha"));
        usuario.setRolid(Integer.parseInt(request.getParameter("rolid")));
        usuario.setTiendaid(Integer.parseInt(request.getParameter("tiendaid")));
        usuario.setEstado(request.getParameter("estado"));
        
        // Verificar si el correo ya existe
        if (personalDao.correoExiste(usuario.getCorreo())) {
            return "Error: El correo ya está registrado";
        }
        
        boolean creado = personalDao.crearUsuario(usuario, usuarioSesion);
        
        if (creado) {
            return "Usuario creado exitosamente: " + usuario.getNombre();
        } else {
            return "Error al crear el usuario";
        }
    }
    
    private String actualizarUsuario(HttpServletRequest request, PersonalDao personalDao, String usuarioSesion) 
            throws SQLException {
        
        Usuario usuario = new Usuario();
        usuario.setId(Integer.parseInt(request.getParameter("id")));
        usuario.setNombre(request.getParameter("nombre"));
        usuario.setCorreo(request.getParameter("correo"));
        usuario.setRolid(Integer.parseInt(request.getParameter("rolid")));
        usuario.setTiendaid(Integer.parseInt(request.getParameter("tiendaid")));
        usuario.setEstado(request.getParameter("estado"));
        
        boolean actualizado = personalDao.actualizarUsuario(usuario, usuarioSesion);
        
        if (actualizado) {
            return "Usuario actualizado exitosamente: " + usuario.getNombre();
        } else {
            return "Error al actualizar el usuario";
        }
    }
    
    private String cambiarEstadoUsuario(HttpServletRequest request, PersonalDao personalDao, String usuarioSesion) 
            throws SQLException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        String nuevoEstado = request.getParameter("estado");
        
        boolean cambiado = personalDao.cambiarEstadoUsuario(id, nuevoEstado, usuarioSesion);
        
        if (cambiado) {
            return "Estado del usuario cambiado exitosamente a: " + nuevoEstado;
        } else {
            return "Error al cambiar el estado del usuario";
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirigir al formulario principal
        response.sendRedirect("gestionUsuarios.jsp");
    }
}