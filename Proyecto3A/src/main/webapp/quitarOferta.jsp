<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.Proyecto3A.dao.CatalogoDao" %>
<%
    try {
        String idParam = request.getParameter("id");
        if (idParam != null) {
            int id = Integer.parseInt(idParam);
            
            // ✅ Obtener usuario de sesión CORRECTAMENTE
            String usuario = (String) session.getAttribute("nombreUsuario");
            if (usuario == null || usuario.trim().isEmpty()) {
                usuario = "Sistema";
            }
            
            CatalogoDao dao = new CatalogoDao();
            // ✅ Usar el método con auditoría
            boolean exito = dao.quitarOferta(id, usuario);
            
            if (exito) {
                response.sendRedirect("productosDescuento.jsp?mensaje=Oferta quitada correctamente");
            } else {
                response.sendRedirect("productosDescuento.jsp?error=Error al quitar oferta");
            }
        } else {
            response.sendRedirect("productosDescuento.jsp?error=ID no proporcionado");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("productosDescuento.jsp?error=Error: " + e.getMessage());
    }
%>