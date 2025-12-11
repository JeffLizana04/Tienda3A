package com.Proyecto3A.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.Proyecto3A.model.Auditoria;

public class AuditoriaDao {
    private Connection conexion;

    public AuditoriaDao() {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=tienda3a;user=sa;password=unpollito191912;encrypt=true;trustServerCertificate=true;";
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conexion = DriverManager.getConnection(url);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Registrar una acción en auditoría
    public boolean registrarAuditoria(String tablaAfectada, int idRegistro, String accion, String usuario, String detalles) {
        String sql = "INSERT INTO AuditoriaGeneral (tabla_afectada, id_registro, accion, usuario, detalles) " +
                    "VALUES (?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, tablaAfectada);
            ps.setInt(2, idRegistro);
            ps.setString(3, accion);
            ps.setString(4, usuario);
            ps.setString(5, detalles);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Obtener auditoría por tabla
    public List<Auditoria> obtenerAuditoriaPorTabla(String tabla) {
        List<Auditoria> lista = new ArrayList<>();
        String sql = "SELECT * FROM AuditoriaGeneral WHERE tabla_afectada = ? ORDER BY fecha_accion DESC";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, tabla);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapearAuditoria(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
    
    // Obtener toda la auditoría
    public List<Auditoria> obtenerTodaAuditoria() {
        List<Auditoria> lista = new ArrayList<>();
        String sql = "SELECT * FROM AuditoriaGeneral ORDER BY fecha_accion DESC";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapearAuditoria(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
    
    private Auditoria mapearAuditoria(ResultSet rs) throws SQLException {
        Auditoria a = new Auditoria();
        a.setIdAuditoria(rs.getInt("id_auditoria"));
        a.setTablaAfectada(rs.getString("tabla_afectada"));
        a.setIdRegistro(rs.getInt("id_registro"));
        a.setAccion(rs.getString("accion"));
        a.setUsuario(rs.getString("usuario"));
        a.setFechaAccion(rs.getTimestamp("fecha_accion"));
        a.setValoresAnteriores(rs.getString("valores_anteriores"));
        a.setValoresNuevos(rs.getString("valores_nuevos"));
        a.setDetalles(rs.getString("detalles"));
        return a;
    }
}