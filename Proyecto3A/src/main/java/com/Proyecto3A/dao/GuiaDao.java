// GuiaDao.java
package com.Proyecto3A.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import com.Proyecto3A.model.Guia;
import com.Proyecto3A.model.GuiaDetalle;

public class GuiaDao {
    
    private Connection conexion;
    private CatalogoDao catalogoDao;
    
    public GuiaDao() {
        this.catalogoDao = new CatalogoDao();
        
        // Reutilizar tu conexión existente
        String url = "jdbc:sqlserver://localhost:1433;databaseName=tienda3a;user=sa;password=unpollito191912;encrypt=true;trustServerCertificate=true;";
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conexion = DriverManager.getConnection(url);
            System.out.println("GuiaDao - Conexión exitosa");
        } catch (Exception e) {
            System.err.println("GuiaDao ERROR - Error de conexión: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error conectando a la base de datos", e);
        }
    }
    
    // 🔹 LISTAR todas las guías
    public List<Guia> listarGuias() {
        List<Guia> lista = new ArrayList<>();
        String sql = "SELECT g.*, t.nombre as tienda_nombre " +
                    "FROM guias g " +
                    "LEFT JOIN tiendas t ON g.tiendaid = t.id " +
                    "ORDER BY g.fecha_recepcion DESC, g.id_guia DESC";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Guia guia = mapearGuiaDesdeResultSet(rs);
                lista.add(guia);
            }
            
        } catch (SQLException e) {
            System.err.println("GuiaDao ERROR - Error en listarGuias: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }
    
    // 🔹 OBTENER guía por ID con detalles
    public Guia obtenerGuiaConDetalles(int idGuia) {
        Guia guia = null;
        String sql = "SELECT g.*, t.nombre as tienda_nombre " +
                    "FROM guias g " +
                    "LEFT JOIN tiendas t ON g.tiendaid = t.id " +
                    "WHERE g.id_guia = ?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, idGuia);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    guia = mapearGuiaDesdeResultSet(rs);
                    
                    // Obtener detalles de la guía
                    List<GuiaDetalle> detalles = obtenerDetallesPorGuia(idGuia);
                    guia.setDetalles(detalles);
                }
            }
        } catch (SQLException e) {
            System.err.println("GuiaDao ERROR - Error en obtenerGuiaConDetalles: " + e.getMessage());
            e.printStackTrace();
        }
        return guia;
    }
    
    // 🔹 INSERTAR nueva guía (con transacción)
    public boolean insertarGuia(Guia guia, String usuario) {
        Connection conn = null;
        try {
            conn = conexion;
            conn.setAutoCommit(false);
            
            // 1. Insertar guía principal
            String sqlGuia = "INSERT INTO guias (numero_guia, proveedor, fecha_emision, fecha_recepcion, " +
                           "total_productos, total_valor, tiendaid, usuario_registro, estado) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(sqlGuia, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, guia.getNumeroGuia());
                ps.setString(2, guia.getProveedor());
                ps.setDate(3, new java.sql.Date(guia.getFechaEmision().getTime()));
                ps.setDate(4, new java.sql.Date(guia.getFechaRecepcion().getTime()));
                ps.setInt(5, guia.getTotalProductos());
                ps.setDouble(6, guia.getTotalValor());
                ps.setInt(7, guia.getTiendaId());
                ps.setString(8, usuario);
                ps.setString(9, guia.getEstado());
                
                int filas = ps.executeUpdate();
                
                if (filas > 0) {
                    try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            int idGuiaGenerada = generatedKeys.getInt(1);
                            guia.setIdGuia(idGuiaGenerada);
                            
                            // 2. Insertar detalles
                            if (guia.getDetalles() != null && !guia.getDetalles().isEmpty()) {
                                for (GuiaDetalle detalle : guia.getDetalles()) {
                                    insertarDetalle(conn, detalle, idGuiaGenerada, usuario);
                                    
                                    // 3. ACTUALIZAR STOCK en Catalogo
                                    catalogoDao.actualizarStock(detalle.getIdProducto(), 
                                                               detalle.getCantidad(), 
                                                               "entrada", 
                                                               usuario);
                                }
                            }
                            
                            conn.commit();
                            registrarAuditoria("INSERT", idGuiaGenerada, usuario, 
                                            "Nueva guía creada: " + guia.getNumeroGuia());
                            return true;
                        }
                    }
                }
                conn.rollback();
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("GuiaDao ERROR - Error en insertarGuia: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) {}
            }
        }
    }
    
    // 🔹 ACTUALIZAR guía
    public boolean actualizarGuia(Guia guia, String usuario) {
        String sql = "UPDATE guias SET numero_guia=?, proveedor=?, fecha_emision=?, fecha_recepcion=?, " +
                    "total_productos=?, total_valor=?, tiendaid=?, estado=?, " +
                    "ultimo_usuario_modifico=?, fecha_ultima_modificacion=GETDATE() " +
                    "WHERE id_guia=?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, guia.getNumeroGuia());
            ps.setString(2, guia.getProveedor());
            ps.setDate(3, new java.sql.Date(guia.getFechaEmision().getTime()));
            ps.setDate(4, new java.sql.Date(guia.getFechaRecepcion().getTime()));
            ps.setInt(5, guia.getTotalProductos());
            ps.setDouble(6, guia.getTotalValor());
            ps.setInt(7, guia.getTiendaId());
            ps.setString(8, guia.getEstado());
            ps.setString(9, usuario);
            ps.setInt(10, guia.getIdGuia());
            
            int resultado = ps.executeUpdate();
            
            if (resultado > 0) {
                registrarAuditoria("UPDATE", guia.getIdGuia(), usuario, 
                                "Guía actualizada: " + guia.getNumeroGuia());
                return true;
            }
            return false;
            
        } catch (SQLException e) {
            System.err.println("GuiaDao ERROR - Error en actualizarGuia: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 🔹 CAMBIAR estado de guía
    public boolean cambiarEstadoGuia(int idGuia, String nuevoEstado, String usuario) {
        String sql = "UPDATE guias SET estado=?, ultimo_usuario_modifico=?, fecha_ultima_modificacion=GETDATE() " +
                    "WHERE id_guia=?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setString(2, usuario);
            ps.setInt(3, idGuia);
            
            int resultado = ps.executeUpdate();
            
            if (resultado > 0) {
                registrarAuditoria("UPDATE", idGuia, usuario, 
                                "Estado cambiado a: " + nuevoEstado);
                
                // Si se marca como "procesado", registrar movimiento
                if ("procesado".equals(nuevoEstado)) {
                    registrarMovimientoGuiaProcesada(idGuia, usuario);
                }
                
                return true;
            }
            return false;
            
        } catch (SQLException e) {
            System.err.println("GuiaDao ERROR - Error en cambiarEstadoGuia: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 🔹 ELIMINAR guía (cambiar estado a anulado)
    public boolean anularGuia(int idGuia, String usuario) {
        // Primero obtener la guía para revertir stock
        Guia guia = obtenerGuiaConDetalles(idGuia);
        if (guia == null) return false;
        
        // Revertir stock de todos los productos
        if (guia.getDetalles() != null) {
            for (GuiaDetalle detalle : guia.getDetalles()) {
                catalogoDao.actualizarStock(detalle.getIdProducto(), 
                                          detalle.getCantidad(), 
                                          "salida", 
                                          usuario);
            }
        }
        
        // Cambiar estado a anulado
        return cambiarEstadoGuia(idGuia, "anulado", usuario);
    }
    
    // 🔹 OBTENER detalles por guía
    public List<GuiaDetalle> obtenerDetallesPorGuia(int idGuia) {
        List<GuiaDetalle> detalles = new ArrayList<>();
        String sql = "SELECT d.*, p.productos as producto_nombre " +
                    "FROM guia_detalles d " +
                    "LEFT JOIN catalogo p ON d.id_producto = p.id " +
                    "WHERE d.id_guia = ? ORDER BY d.id_detalle";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, idGuia);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GuiaDetalle detalle = new GuiaDetalle();
                    detalle.setIdDetalle(rs.getInt("id_detalle"));
                    detalle.setIdGuia(rs.getInt("id_guia"));
                    detalle.setIdProducto(rs.getInt("id_producto"));
                    detalle.setProductoNombre(rs.getString("producto_nombre"));
                    detalle.setCantidad(rs.getInt("cantidad"));
                    detalle.setPrecioUnitario(rs.getDouble("precio_unitario"));
                    detalle.setSubtotal(rs.getDouble("subtotal"));
                    detalle.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                    detalle.setLote(rs.getString("lote"));
                    detalle.setUbicacion(rs.getString("ubicacion"));
                    detalle.setEstado(rs.getString("estado"));
                    detalles.add(detalle);
                }
            }
        } catch (SQLException e) {
            System.err.println("GuiaDao ERROR - Error en obtenerDetallesPorGuia: " + e.getMessage());
            e.printStackTrace();
        }
        return detalles;
    }
    
    // 🔹 INSERTAR detalle individual
    private void insertarDetalle(Connection conn, GuiaDetalle detalle, int idGuia, String usuario) 
            throws SQLException {
        String sql = "INSERT INTO guia_detalles (id_guia, id_producto, producto_nombre, " +
                    "cantidad, precio_unitario, subtotal, fecha_vencimiento, lote, ubicacion, estado) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idGuia);
            ps.setInt(2, detalle.getIdProducto());
            ps.setString(3, detalle.getProductoNombre());
            ps.setInt(4, detalle.getCantidad());
            ps.setDouble(5, detalle.getPrecioUnitario());
            ps.setDouble(6, detalle.getSubtotal());
            ps.setDate(7, detalle.getFechaVencimiento() != null ? 
                        new java.sql.Date(detalle.getFechaVencimiento().getTime()) : null);
            ps.setString(8, detalle.getLote());
            ps.setString(9, detalle.getUbicacion());
            ps.setString(10, detalle.getEstado());
            ps.executeUpdate();
        }
    }
    
    // 🔹 BUSCAR guías por filtros
    public List<Guia> buscarGuias(String numeroGuia, Date fechaInicio, Date fechaFin, 
                                 String estado, Integer tiendaId) {
        List<Guia> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT g.*, t.nombre as tienda_nombre FROM guias g " +
            "LEFT JOIN tiendas t ON g.tiendaid = t.id WHERE 1=1"
        );
        
        List<Object> parametros = new ArrayList<>();
        
        if (numeroGuia != null && !numeroGuia.trim().isEmpty()) {
            sql.append(" AND g.numero_guia LIKE ?");
            parametros.add("%" + numeroGuia + "%");
        }
        if (fechaInicio != null) {
            sql.append(" AND g.fecha_recepcion >= ?");
            parametros.add(new java.sql.Date(fechaInicio.getTime()));
        }
        if (fechaFin != null) {
            sql.append(" AND g.fecha_recepcion <= ?");
            parametros.add(new java.sql.Date(fechaFin.getTime()));
        }
        if (estado != null && !estado.trim().isEmpty()) {
            sql.append(" AND g.estado = ?");
            parametros.add(estado);
        }
        if (tiendaId != null && tiendaId > 0) {
            sql.append(" AND g.tiendaid = ?");
            parametros.add(tiendaId);
        }
        
        sql.append(" ORDER BY g.fecha_recepcion DESC");
        
        try (PreparedStatement ps = conexion.prepareStatement(sql.toString())) {
            for (int i = 0; i < parametros.size(); i++) {
                ps.setObject(i + 1, parametros.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapearGuiaDesdeResultSet(rs));
                }
            }
            
        } catch (SQLException e) {
            System.err.println("GuiaDao ERROR - Error en buscarGuias: " + e.getMessage());
            e.printStackTrace();
        }
        return lista;
    }
    
    // 🔹 VERIFICAR si número de guía ya existe
    public boolean existeNumeroGuia(String numeroGuia) {
        String sql = "SELECT COUNT(*) as total FROM guias WHERE numero_guia = ?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, numeroGuia);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("GuiaDao ERROR - Error en existeNumeroGuia: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // ========== MÉTODOS PRIVADOS ==========
    
    private Guia mapearGuiaDesdeResultSet(ResultSet rs) throws SQLException {
        Guia guia = new Guia();
        guia.setIdGuia(rs.getInt("id_guia"));
        guia.setNumeroGuia(rs.getString("numero_guia"));
        guia.setProveedor(rs.getString("proveedor"));
        guia.setFechaEmision(rs.getDate("fecha_emision"));
        guia.setFechaRecepcion(rs.getDate("fecha_recepcion"));
        guia.setTotalProductos(rs.getInt("total_productos"));
        guia.setTotalValor(rs.getDouble("total_valor"));
        guia.setTiendaId(rs.getInt("tiendaid"));
        guia.setTiendaNombre(rs.getString("tienda_nombre"));
        guia.setUsuarioRegistro(rs.getString("usuario_registro"));
        guia.setFechaRegistro(rs.getDate("fecha_registro"));
        guia.setEstado(rs.getString("estado"));
        guia.setUltimoUsuarioModifico(rs.getString("ultimo_usuario_modifico"));
        guia.setFechaUltimaModificacion(rs.getDate("fecha_ultima_modificacion"));
        return guia;
    }
    
    private void registrarAuditoria(String accion, int idRegistro, String usuario, String detalles) {
        try {
            AuditoriaDao auditoriaDao = new AuditoriaDao();
            auditoriaDao.registrarAuditoria("guias", idRegistro, accion, usuario, detalles);
            System.out.println("GuiaDao - Auditoría registrada para guía ID: " + idRegistro);
        } catch (Exception e) {
            System.err.println("GuiaDao ERROR - Error al registrar auditoría: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void registrarMovimientoGuiaProcesada(int idGuia, String usuario) {
        String sql = "INSERT INTO movimientos_guia (id_guia, tipo, usuario, fecha, detalles) " +
                    "VALUES (?, 'procesado', ?, GETDATE(), 'Guía procesada completamente')";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, idGuia);
            ps.setString(2, usuario);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("GuiaDao ERROR - Error en registrarMovimientoGuiaProcesada: " + e.getMessage());
            e.printStackTrace();
        }
    }
}