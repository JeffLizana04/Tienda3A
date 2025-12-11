package com.Proyecto3A.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

import com.Proyecto3A.dao.CatalogoDao;
import com.Proyecto3A.model.Catalogo;

/**
 * Servlet implementation class HomeController
 */
@WebServlet("/home")
public class HomeController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public HomeController() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	
		String opcion = request.getParameter("opcion");
		switch (opcion) {
		case "mostrarGestionUsuarios":{
				mostrarGestionUsuarios(request,response);
				break;
		}
		case "gestionPersonal":{
				mostrarGestionUsuarios(request,response);
				break;
		}

		  case "gestionProductos": {
              mostrarCatalogo(request, response);
              break;
          }
		  
	


          default: {
              // Página por defecto
              RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/index.jsp");
              dispatcher.forward(request, response);
              break;
          }
		}
	}
	
	public void mostrarGestionUsuarios(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {			  
			RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/gestionUsuarios.jsp");
			dispatcher.forward(request, response);
		}

	 private void mostrarCatalogo(HttpServletRequest request, HttpServletResponse response)
	            throws ServletException, IOException {
	        CatalogoDao dao = new CatalogoDao();
	        List<Catalogo> lista = dao.listarProductos();
	  
	        request.setAttribute("listaCatalogo", lista);

	        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/catalogo.jsp");
	        dispatcher.forward(request, response);
	    }
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}

}