package com.Proyecto3A.servlets;

import java.io.*;
import com.Proyecto3A.dao.PersonalDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/VerificarCorreoServlet")
public class VerificarCorreoServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String correo = request.getParameter("correo");
        
        if (correo != null && !correo.trim().isEmpty()) {
            try {
                PersonalDao personalDao = new PersonalDao();
                boolean existe = personalDao.correoExiste(correo);
                out.print(existe ? "true" : "false");
            } catch (Exception e) {
                e.printStackTrace();
                out.print("error");
            }
        } else {
            out.print("false");
        }
    }
}