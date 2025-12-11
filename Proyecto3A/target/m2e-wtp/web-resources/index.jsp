<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - Tiendas 3A</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Estilos personalizados -->
    <style>
        body {
            background: linear-gradient(135deg, #004AAD 0%, #FF6600 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Poppins', sans-serif;
        }

        .card {
            border: none;
            border-radius: 1rem;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.25);
        }

        .card-header {
            background-color: transparent;
            border-bottom: none;
        }

        .logo {
            width: 100px;
            height: auto;
            margin-bottom: 10px;
        }

        .btn-primary {
            background-color: #FF6600;
            border: none;
            transition: 0.3s;
        }

        .btn-primary:hover {
            background-color: #e65c00;
        }

        .form-control:focus {
            border-color: #004AAD;
            box-shadow: 0 0 0 0.2rem rgba(0, 74, 173, 0.25);
        }

        h1 {
            font-weight: 700;
            color: #004AAD;
        }

        .text-muted {
            color: #555 !important;
        }
    </style>
</head>
<body>

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-5 col-lg-4">
                <div class="card p-4">
                    <div class="card-header text-center">
                        <!-- Logo de la tienda -->
                        <img src="imagenes/logo.png" alt="Logo Tiendas 3A" class="logo">
                        <h1>Tiendas 3A</h1>
                        <p class="text-muted">Inicia sesión para continuar</p>
                    </div>
                    <div class="card-body">
                        <form action="login" method="POST">
                            <input type="hidden" name="opcion" value="validarUsuario">

                            <div class="mb-3">
                                <label for="correo" class="form-label">Correo electrónico</label>
                                <input type="email" id="correo" name="correo" class="form-control" placeholder="Ingresa tu correo" required>
                            </div>

                            <div class="mb-3">
                                <label for="contrasenha" class="form-label">Contraseña</label>
                                <input type="password" id="contrasenha" name="contrasenha" class="form-control" placeholder="Ingresa tu contraseña" required>
                            </div>

                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary btn-lg">Ingresar</button>
                            </div>
                        </form>
                    </div>
                    <div class="card-footer text-center text-muted small">
                        &copy; 2025 Tiendas 3A — Todos los derechos reservados
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>