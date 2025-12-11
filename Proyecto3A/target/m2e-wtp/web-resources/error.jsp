<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Error - Tiendas 3A</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .error-container {
            max-width: 600px;
            margin: 100px auto;
            padding: 40px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            text-align: center;
        }
        .error-icon {
            font-size: 5rem;
            color: #dc3545;
            margin-bottom: 20px;
        }
        .error-title {
            color: #004aad;
            font-weight: 700;
            margin-bottom: 15px;
        }
        .error-message {
            color: #6c757d;
            margin-bottom: 30px;
        }
        .btn-custom {
            background: #ff6600;
            border: none;
            color: white;
            padding: 12px 30px;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }
        .btn-custom:hover {
            background: #e05500;
            color: white;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        
        <h2 class="error-title">¡Oops! Algo salió mal</h2>
        
        <% 
            String mensajeError = (String) request.getAttribute("mensajeError");
            if (mensajeError != null && !mensajeError.isEmpty()) {
        %>
            <div class="alert alert-danger">
                <%= mensajeError %>
            </div>
        <% } else { %>
            <p class="error-message">
                Ha ocurrido un error inesperado. Por favor, intenta nuevamente.
            </p>
        <% } %>
        
        <div class="mt-4">
            <a href="javascript:history.back()" class="btn btn-custom me-2">
                <i class="fas fa-arrow-left me-2"></i> Volver
            </a>
            <a href="principal.jsp" class="btn btn-custom">
                <i class="fas fa-home me-2"></i> Ir al Inicio
            </a>
        </div>
        
        <% if (exception != null) { %>
        <details class="mt-4">
            <summary class="btn btn-link">Ver detalles técnicos</summary>
            <div class="text-start mt-3" style="font-size: 0.85rem; color: #666;">
                <strong>Excepción:</strong> <%= exception.getClass().getName() %><br>
                <strong>Mensaje:</strong> <%= exception.getMessage() %>
            </div>
        </details>
        <% } %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>