<%@ page import="com.Proyecto3A.dao.CatalogoDao" %>
<%
    try {
        int id = Integer.parseInt(request.getParameter("id"));
        
        // ✅ Obtener usuario de sesión CORRECTAMENTE
        String usuario = (String) session.getAttribute("nombreUsuario");
        if (usuario == null || usuario.trim().isEmpty()) {
            usuario = "Sistema";
        }
        
        CatalogoDao dao = new CatalogoDao();
        // ✅ Usar el método con auditoría
        boolean exito = dao.cambiarEstado(id, usuario);
        
        if (exito) {
            response.sendRedirect("catalogo.jsp?mensaje=Estado cambiado correctamente");
        } else {
            response.sendRedirect("catalogo.jsp?error=Error al cambiar estado");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("catalogo.jsp?error=Error: " + e.getMessage());
    }
%>