package com.Proyecto3A.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

import com.Proyecto3A.dao.UsuarioDao;
import com.Proyecto3A.model.Usuario;

@WebServlet("/login")
public class LoginController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public LoginController() {
        super();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String opcion = request.getParameter("opcion");

        if ("validarUsuario".equals(opcion)) {
            try {
                validarUsuario(request, response);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void validarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String correo = request.getParameter("correo");
        String contrasenha = request.getParameter("contrasenha");

        UsuarioDao usuarioDao = new UsuarioDao();
        Usuario usuario = usuarioDao.obtenerUsuarioCompleto(correo, contrasenha);

        if (usuario != null) {
            // Guardar usuario completo en sesión
            HttpSession sesion = request.getSession();
            sesion.setAttribute("usuario", usuario); // Objeto completo
            sesion.setAttribute("nombreUsuario", usuario.getNombre());
            sesion.setAttribute("rolUsuario", usuario.getRolNombre());
            sesion.setAttribute("rolId", usuario.getRolid());

            RequestDispatcher dispatcher = request.getServletContext().getRequestDispatcher("/principal.jsp");
            dispatcher.forward(request, response);

        } else {
            request.setAttribute("mensajeError", "Correo o contraseña incorrectos");
            RequestDispatcher dispatcher = request.getServletContext().getRequestDispatcher("/index.jsp");
            dispatcher.forward(request, response);
        }
    }
}