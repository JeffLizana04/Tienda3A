package com.Proyecto3A.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.Proyecto3A.model.Catalogo;

public class CatalogoDao {

    private Connection conexion;

    public CatalogoDao() {
        System.out.println("=== CONSTRUCTOR CatalogoDao ===");
        String url = "jdbc:sqlserver://localhost:1433;databaseName=tienda3a;user=sa;password=unpollito191912;encrypt=true;trustServerCertificate=true;";
        try {
            System.out.println("DAO DEBUG - Cargando driver JDBC...");
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("DAO DEBUG - Driver cargado exitosamente");
            
            System.out.println("DAO DEBUG - Conectando a: " + url);
            conexion = DriverManager.getConnection(url);
            System.out.println("DAO DEBUG - Conexión exitosa a SQL Server");
            
            // Verificar conexión con una consulta simple
            try (Statement stmt = conexion.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT 1 as test")) {
                if (rs.next()) {
                    System.out.println("DAO DEBUG - Test de conexión: OK");
                }
            }
            
        } catch (ClassNotFoundException e) {
            System.err.println("DAO ERROR - No se encontró el driver JDBC: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Driver JDBC no encontrado", e);
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error de conexión SQL: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error conectando a la base de datos", e);
        }
    }

    // 🔹 Listar todos los productos (INCLUYE STOCK)
    public List<Catalogo> listarProductos() {
        System.out.println("DAO DEBUG - Iniciando listarProductos()");
        List<Catalogo> lista = new ArrayList<>();
        String sql = "SELECT * FROM catalogo ORDER BY productos";
        
        System.out.println("DAO DEBUG - SQL: " + sql);

        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            System.out.println("DAO DEBUG - Statement preparado");
            
            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("DAO DEBUG - Query ejecutado");
                int contador = 0;
                
                while (rs.next()) {
                    contador++;
                    Catalogo c = new Catalogo();
                    c.setId(rs.getInt("id"));
                    c.setProductos(rs.getString("productos"));
                    c.setPrecio(rs.getDouble("precio"));
                    c.setOferta(rs.getString("oferta"));
                    c.setPrecioFinal(rs.getDouble("preciofinal"));
                    c.setFoto(rs.getString("foto"));
                    c.setFechaVencimiento(rs.getDate("fechavencimiento"));
                    c.setEnOferta(rs.getBoolean("en_oferta"));
                    
                    // Manejar descuento (puede ser null)
                    Object descObj = rs.getObject("descuento_porcentaje");
                    if (descObj != null) {
                        c.setDescuentoPorcentaje(rs.getDouble("descuento_porcentaje"));
                    } else {
                        c.setDescuentoPorcentaje(null);
                    }
                    
                    c.setEstado(rs.getString("estado"));
                    c.setStock(rs.getInt("stock"));
                    c.setUltimoUsuarioModifico(rs.getString("ultimo_usuario_modifico"));
                    c.setFechaUltimaModificacion(rs.getTimestamp("fecha_ultima_modificacion"));
                    
                    lista.add(c);
                    
                    // Log del primer producto para debug
                    if (contador == 1) {
                        System.out.println("DAO DEBUG - Primer producto: " + c.getProductos() + 
                                          ", ID: " + c.getId() + 
                                          ", Stock: " + c.getStock());
                    }
                }
                
                System.out.println("DAO DEBUG - Total productos encontrados: " + contador);
            }
            
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en listarProductos: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error al listar productos: " + e.getMessage(), e);
        } catch (Exception e) {
            System.err.println("DAO ERROR - Error inesperado en listarProductos: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error inesperado", e);
        }
        
        return lista;
    }

    // 🔹 Listar productos activos con stock positivo
    public List<Catalogo> listarProductosConStock() {
        System.out.println("DAO DEBUG - Iniciando listarProductosConStock()");
        List<Catalogo> lista = new ArrayList<>();
        String sql = "SELECT * FROM catalogo WHERE estado = 'activo' AND stock > 0 ORDER BY productos";

        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            int contador = 0;
            while (rs.next()) {
                contador++;
                Catalogo c = new Catalogo();
                c.setId(rs.getInt("id"));
                c.setProductos(rs.getString("productos"));
                c.setPrecio(rs.getDouble("precio"));
                c.setOferta(rs.getString("oferta"));
                c.setPrecioFinal(rs.getDouble("preciofinal"));
                c.setFoto(rs.getString("foto"));
                c.setFechaVencimiento(rs.getDate("fechavencimiento"));
                c.setEnOferta(rs.getBoolean("en_oferta"));
                
                Object descObj = rs.getObject("descuento_porcentaje");
                if (descObj != null) {
                    c.setDescuentoPorcentaje(rs.getDouble("descuento_porcentaje"));
                }
                
                c.setEstado(rs.getString("estado"));
                c.setStock(rs.getInt("stock"));
                c.setUltimoUsuarioModifico(rs.getString("ultimo_usuario_modifico"));
                c.setFechaUltimaModificacion(rs.getTimestamp("fecha_ultima_modificacion"));
                lista.add(c);
            }
            
            System.out.println("DAO DEBUG - Productos activos con stock: " + contador);
            
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en listarProductosConStock: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error al listar productos con stock", e);
        }
        return lista;
    }

    // Resto de métodos se mantienen igual...
    // Solo copia el resto de tus métodos como estaban
    
    // ➕ Agregar producto CON AUDITORÍA (INCLUYE STOCK)
    public boolean agregarProducto(Catalogo c, String usuario) {
        String sql = "INSERT INTO catalogo (productos, precio, oferta, preciofinal, foto, fechavencimiento, " +
                    "en_oferta, descuento_porcentaje, estado, stock, ultimo_usuario_modifico, fecha_ultima_modificacion) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, c.getProductos());
            ps.setDouble(2, c.getPrecio());
            ps.setString(3, c.getOferta());
            ps.setDouble(4, c.getPrecioFinal());
            ps.setString(5, c.getFoto());
            ps.setDate(6, c.getFechaVencimiento());
            ps.setBoolean(7, c.isEnOferta());
            
            if (c.getDescuentoPorcentaje() != null)
                ps.setDouble(8, c.getDescuentoPorcentaje());
            else
                ps.setNull(8, Types.DECIMAL);
                
            ps.setString(9, c.getEstado());
            ps.setInt(10, c.getStock()); // Stock inicial
            ps.setString(11, usuario); // Auditoría
            
            int resultado = ps.executeUpdate();
            
            // Obtener el ID generado y registrar auditoría
            if (resultado > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int idGenerado = generatedKeys.getInt(1);
                        registrarAuditoria("INSERT", idGenerado, usuario, 
                            "Nuevo producto creado: " + c.getProductos() + 
                            " (Stock inicial: " + c.getStock() + ")");
                    }
                }
                return true;
            }
            return false;

        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en agregarProducto: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ✏️ Actualizar producto CON AUDITORÍA (INCLUYE STOCK)
    public boolean actualizarProducto(Catalogo c, String usuario) {
        // Primero obtener el producto anterior para comparar cambios
        Catalogo productoAnterior = obtenerPorId(c.getId());
        if (productoAnterior == null) return false;
        
        String sql = "UPDATE catalogo SET productos=?, precio=?, oferta=?, preciofinal=?, " +
                    "foto=?, fechavencimiento=?, en_oferta=?, descuento_porcentaje=?, " +
                    "estado=?, stock=?, ultimo_usuario_modifico=?, fecha_ultima_modificacion=GETDATE() WHERE id=?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, c.getProductos());
            ps.setDouble(2, c.getPrecio());
            ps.setString(3, c.getOferta());
            ps.setDouble(4, c.getPrecioFinal());
            ps.setString(5, c.getFoto());
            ps.setDate(6, c.getFechaVencimiento());
            ps.setBoolean(7, c.isEnOferta());

            if (c.getDescuentoPorcentaje() != null)
                ps.setDouble(8, c.getDescuentoPorcentaje());
            else
                ps.setNull(8, Types.DECIMAL);

            ps.setString(9, c.getEstado());
            ps.setInt(10, c.getStock()); // Stock
            ps.setString(11, usuario); // Auditoría
            ps.setInt(12, c.getId());
            
            int resultado = ps.executeUpdate();
            
            // Registrar auditoría si se actualizó
            if (resultado > 0) {
                String detalles = generarDetallesCambios(productoAnterior, c);
                registrarAuditoria("UPDATE", c.getId(), usuario, detalles);
                return true;
            }
            return false;

        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en actualizarProducto: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 🗑️ Cambiar estado CON AUDITORÍA
    public boolean cambiarEstado(int id, String usuario) {
        // Obtener producto actual para auditoría
        Catalogo producto = obtenerPorId(id);
        if (producto == null) return false;
        
        String nuevoEstado = "activo".equals(producto.getEstado()) ? "inactivo" : "activo";
        String sql = "UPDATE catalogo SET estado=?, ultimo_usuario_modifico=?, fecha_ultima_modificacion=GETDATE() WHERE id=?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setString(2, usuario);
            ps.setInt(3, id);
            
            int resultado = ps.executeUpdate();
            
            // Registrar auditoría
            if (resultado > 0) {
                String detalles = "Estado cambiado de '" + producto.getEstado() + "' a '" + nuevoEstado + "'";
                registrarAuditoria("UPDATE", id, usuario, detalles);
                return true;
            }
            return false;
            
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en cambiarEstado: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ⭐ Poner producto en oferta CON AUDITORÍA
    public boolean ponerEnOferta(int id, double descuentoPorcentaje, String usuario) {
        // Obtener producto actual
        Catalogo producto = obtenerPorId(id);
        if (producto == null) return false;
        
        double precioFinal = producto.getPrecio() * (1 - descuentoPorcentaje / 100);
        String oferta = descuentoPorcentaje + "%";
        
        String sql = "UPDATE catalogo SET en_oferta=1, descuento_porcentaje=?, oferta=?, preciofinal=?, ultimo_usuario_modifico=?, fecha_ultima_modificacion=GETDATE() WHERE id=?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setDouble(1, descuentoPorcentaje);
            ps.setString(2, oferta);
            ps.setDouble(3, precioFinal);
            ps.setString(4, usuario);
            ps.setInt(5, id);
            
            int resultado = ps.executeUpdate();
            
            // Registrar auditoría
            if (resultado > 0) {
                String detalles = "Producto puesto en oferta con " + descuentoPorcentaje + "% de descuento. Precio final: S/ " + precioFinal;
                registrarAuditoria("UPDATE", id, usuario, detalles);
                return true;
            }
            return false;
            
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en ponerEnOferta: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ❌ Quitar oferta CON AUDITORÍA
    public boolean quitarOferta(int id, String usuario) {
        // Obtener producto actual
        Catalogo producto = obtenerPorId(id);
        if (producto == null) return false;
        
        String sql = "UPDATE catalogo SET en_oferta=0, descuento_porcentaje=NULL, oferta=NULL, preciofinal=precio, ultimo_usuario_modifico=?, fecha_ultima_modificacion=GETDATE() WHERE id=?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, usuario);
            ps.setInt(2, id);
            
            int resultado = ps.executeUpdate();
            
            // Registrar auditoría
            if (resultado > 0) {
                registrarAuditoria("UPDATE", id, usuario, "Oferta quitada del producto. Precio restaurado a S/ " + producto.getPrecio());
                return true;
            }
            return false;
            
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en quitarOferta: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 🔎 Obtener producto por ID (INCLUYE STOCK)
    public Catalogo obtenerPorId(int id) {
        System.out.println("DAO DEBUG - Buscando producto ID: " + id);
        Catalogo c = null;
        String sql = "SELECT * FROM catalogo WHERE id=?";
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    c = new Catalogo();
                    c.setId(rs.getInt("id"));
                    c.setProductos(rs.getString("productos"));
                    c.setPrecio(rs.getDouble("precio"));
                    c.setOferta(rs.getString("oferta"));
                    c.setPrecioFinal(rs.getDouble("preciofinal"));
                    c.setFoto(rs.getString("foto"));
                    c.setFechaVencimiento(rs.getDate("fechavencimiento"));
                    c.setEnOferta(rs.getBoolean("en_oferta"));
                    
                    Object descObj = rs.getObject("descuento_porcentaje");
                    if (descObj != null) {
                        c.setDescuentoPorcentaje(rs.getDouble("descuento_porcentaje"));
                    }
                    
                    c.setEstado(rs.getString("estado"));
                    c.setStock(rs.getInt("stock")); // Stock
                    c.setUltimoUsuarioModifico(rs.getString("ultimo_usuario_modifico"));
                    c.setFechaUltimaModificacion(rs.getTimestamp("fecha_ultima_modificacion"));
                    
                    System.out.println("DAO DEBUG - Producto encontrado: " + c.getProductos());
                } else {
                    System.out.println("DAO DEBUG - Producto ID " + id + " no encontrado");
                }
            }
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en obtenerPorId: " + e.getMessage());
            e.printStackTrace();
        }
        return c;
    }

    // 🔧 Método para actualizar stock directamente
    public boolean actualizarStock(int idProducto, int cantidad, String tipoMovimiento, String usuario) {
        String sql = "UPDATE catalogo SET stock = stock + ?, " +
                    "ultimo_usuario_modifico = ?, fecha_ultima_modificacion = GETDATE() " +
                    "WHERE id = ?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            int ajuste = tipoMovimiento.equals("entrada") ? cantidad : -cantidad;
            ps.setInt(1, ajuste);
            ps.setString(2, usuario);
            ps.setInt(3, idProducto);
            
            int resultado = ps.executeUpdate();
            
            if (resultado > 0) {
                String movimiento = tipoMovimiento.equals("entrada") ? "entrada" : "salida";
                String detalles = "Stock " + movimiento + " de " + cantidad + " unidades";
                registrarAuditoria("UPDATE", idProducto, usuario, detalles);
                
                // Registrar movimiento en tabla movimientos_inventario
                registrarMovimientoInventario(idProducto, cantidad, tipoMovimiento, usuario);
                
                return true;
            }
            return false;
            
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en actualizarStock: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // 📊 Obtener stock actual de un producto
    public int obtenerStock(int idProducto) {
        String sql = "SELECT stock FROM catalogo WHERE id = ?";
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, idProducto);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("stock");
                }
            }
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en obtenerStock: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    // ✅ Validar si hay stock suficiente
    public boolean validarStockSuficiente(int idProducto, int cantidadRequerida) {
        int stockActual = obtenerStock(idProducto);
        return stockActual >= cantidadRequerida;
    }

    // 📅 Obtener productos próximos a vencer
    public List<Catalogo> obtenerProductosProximosAVencer(int diasAntes) {
        List<Catalogo> lista = new ArrayList<>();
        
        String sql = "SELECT * FROM catalogo WHERE estado = 'activo' " +
                    "AND fechavencimiento IS NOT NULL " +
                    "AND fechavencimiento >= CAST(GETDATE() AS DATE) " +
                    "AND fechavencimiento <= DATEADD(DAY, ?, CAST(GETDATE() AS DATE)) " +
                    "AND en_oferta = 0 " +
                    "ORDER BY fechavencimiento ASC";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, diasAntes);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Catalogo c = new Catalogo();
                    c.setId(rs.getInt("id"));
                    c.setProductos(rs.getString("productos"));
                    c.setPrecio(rs.getDouble("precio"));
                    c.setOferta(rs.getString("oferta"));
                    c.setPrecioFinal(rs.getDouble("preciofinal"));
                    c.setFoto(rs.getString("foto"));
                    c.setFechaVencimiento(rs.getDate("fechavencimiento"));
                    c.setEnOferta(rs.getBoolean("en_oferta"));
                    
                    Object descObj = rs.getObject("descuento_porcentaje");
                    if (descObj != null) {
                        c.setDescuentoPorcentaje(rs.getDouble("descuento_porcentaje"));
                    }
                    
                    c.setEstado(rs.getString("estado"));
                    c.setStock(rs.getInt("stock"));
                    c.setUltimoUsuarioModifico(rs.getString("ultimo_usuario_modifico"));
                    c.setFechaUltimaModificacion(rs.getTimestamp("fecha_ultima_modificacion"));
                    lista.add(c);
                }
            }
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en obtenerProductosProximosAVencer: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }

    // 🔔 Verificar si hay productos próximos a vencer
    public boolean hayProductosProximosAVencer(int diasAntes) {
        String sql = "SELECT COUNT(*) as total FROM catalogo WHERE estado = 'activo' " +
                    "AND fechavencimiento IS NOT NULL " +
                    "AND fechavencimiento >= CAST(GETDATE() AS DATE) " +
                    "AND fechavencimiento <= DATEADD(DAY, ?, CAST(GETDATE() AS DATE)) " +
                    "AND en_oferta = 0";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, diasAntes);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en hayProductosProximosAVencer: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 📊 Obtener productos para alerta de oferta
    public List<Catalogo> obtenerProductosParaAlertaOferta(int diasAntes) {
        List<Catalogo> lista = new ArrayList<>();
        String sql = "SELECT * FROM catalogo WHERE estado = 'activo' " +
                    "AND fechavencimiento IS NOT NULL " +
                    "AND fechavencimiento >= CAST(GETDATE() AS DATE) " +
                    "AND fechavencimiento <= DATEADD(DAY, ?, CAST(GETDATE() AS DATE)) " +
                    "AND en_oferta = 0 " +
                    "ORDER BY fechavencimiento ASC";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, diasAntes);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Catalogo c = new Catalogo();
                    c.setId(rs.getInt("id"));
                    c.setProductos(rs.getString("productos"));
                    c.setPrecio(rs.getDouble("precio"));
                    c.setOferta(rs.getString("oferta"));
                    c.setPrecioFinal(rs.getDouble("preciofinal"));
                    c.setFoto(rs.getString("foto"));
                    c.setFechaVencimiento(rs.getDate("fechavencimiento"));
                    c.setEnOferta(rs.getBoolean("en_oferta"));
                    
                    Object descObj = rs.getObject("descuento_porcentaje");
                    if (descObj != null) {
                        c.setDescuentoPorcentaje(rs.getDouble("descuento_porcentaje"));
                    }
                    
                    c.setEstado(rs.getString("estado"));
                    c.setStock(rs.getInt("stock"));
                    c.setUltimoUsuarioModifico(rs.getString("ultimo_usuario_modifico"));
                    c.setFechaUltimaModificacion(rs.getTimestamp("fecha_ultima_modificacion"));
                    lista.add(c);
                }
            }
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en obtenerProductosParaAlertaOferta: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }

    // ========== MÉTODOS PRIVADOS PARA AUDITORÍA Y MOVIMIENTOS ==========
    
    private void registrarAuditoria(String accion, int idRegistro, String usuario, String detalles) {
        try {
            AuditoriaDao auditoriaDao = new AuditoriaDao();
            auditoriaDao.registrarAuditoria("catalogo", idRegistro, accion, usuario, detalles);
            System.out.println("DAO DEBUG - Auditoría registrada para producto ID: " + idRegistro);
        } catch (Exception e) {
            System.err.println("DAO ERROR - Error al registrar auditoría: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void registrarMovimientoInventario(int idProducto, int cantidad, String tipo, String usuario) {
        String sql = "INSERT INTO movimientos_inventario (productoid, tipo, cantidad, fecha) " +
                    "VALUES (?, ?, ?, GETDATE())";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, idProducto);
            ps.setString(2, tipo);
            ps.setInt(3, cantidad);
            ps.executeUpdate();
            System.out.println("DAO DEBUG - Movimiento registrado: " + tipo + " " + cantidad + " unidades para producto " + idProducto);
        } catch (SQLException e) {
            System.err.println("DAO ERROR - Error en registrarMovimientoInventario: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private String generarDetallesCambios(Catalogo anterior, Catalogo nuevo) {
        StringBuilder detalles = new StringBuilder();
        
        if (anterior != null && nuevo != null) {
            if (!anterior.getProductos().equals(nuevo.getProductos())) {
                detalles.append("Nombre: '").append(anterior.getProductos()).append("' → '").append(nuevo.getProductos()).append("'; ");
            }
            if (anterior.getPrecio() != nuevo.getPrecio()) {
                detalles.append("Precio: S/ ").append(anterior.getPrecio()).append(" → S/ ").append(nuevo.getPrecio()).append("; ");
            }
            if (anterior.isEnOferta() != nuevo.isEnOferta()) {
                detalles.append(nuevo.isEnOferta() ? "Puesto en oferta" : "Oferta quitada").append("; ");
            }
            if (!anterior.getEstado().equals(nuevo.getEstado())) {
                detalles.append("Estado: '").append(anterior.getEstado()).append("' → '").append(nuevo.getEstado()).append("'; ");
            }
            if (anterior.getDescuentoPorcentaje() != nuevo.getDescuentoPorcentaje()) {
                detalles.append("Descuento: ").append(anterior.getDescuentoPorcentaje()).append("% → ").append(nuevo.getDescuentoPorcentaje()).append("%; ");
            }
            if (anterior.getStock() != nuevo.getStock()) {
                detalles.append("Stock: ").append(anterior.getStock()).append(" → ").append(nuevo.getStock()).append("; ");
            }
        }
        
        // Si no hay cambios específicos, poner mensaje genérico
        if (detalles.length() == 0) {
            detalles.append("Actualización general del producto");
        }
        
        return detalles.toString();
    }
    
    // 🔹 Métodos originales (sin auditoría) mantenidos para compatibilidad
    public boolean agregarProducto(Catalogo c) {
        return agregarProducto(c, "Sistema");
    }
    
    public boolean actualizarProducto(Catalogo c) {
        return actualizarProducto(c, "Sistema");
    }
    
    public boolean cambiarEstado(int id) {
        return cambiarEstado(id, "Sistema");
    }
    
    public boolean ponerEnOferta(int id, double descuentoPorcentaje) {
        return ponerEnOferta(id, descuentoPorcentaje, "Sistema");
    }
    
    public boolean quitarOferta(int id) {
        return quitarOferta(id, "Sistema");
    }
}