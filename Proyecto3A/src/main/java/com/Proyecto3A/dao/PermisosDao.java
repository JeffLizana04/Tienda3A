package com.Proyecto3A.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PermisosDao {
    private Connection conexion;
    
    public PermisosDao() {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=tienda3a;user=sa;password=unpollito191912;encrypt=true;trustServerCertificate=true;";
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conexion = DriverManager.getConnection(url);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Obtener todos los permisos con estado para un rol específico
    public List<Map<String, Object>> obtenerPermisosPorRol(int rolId) throws SQLException {
        List<Map<String, Object>> permisos = new ArrayList<>();
        
        String sql = "SELECT p.*, " +
                     "CASE WHEN rp.permiso_id IS NOT NULL THEN 1 ELSE 0 END as tiene_permiso " +
                     "FROM permisos p " +
                     "LEFT JOIN rol_permisos rp ON p.id = rp.permiso_id AND rp.rol_id = ? AND rp.activo = 1 " +
                     "ORDER BY p.categoria, p.nombre";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, rolId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> permiso = new HashMap<>();
                    permiso.put("id", rs.getInt("id"));
                    permiso.put("nombre", rs.getString("nombre"));
                    permiso.put("descripcion", rs.getString("descripcion"));
                    permiso.put("codigo", rs.getString("codigo"));
                    permiso.put("categoria", rs.getString("categoria"));
                    permiso.put("tiene_permiso", rs.getInt("tiene_permiso") == 1);
                    permisos.add(permiso);
                }
            }
        }
        return permisos;
    }
    
    // Actualizar permisos de un rol
    public boolean actualizarPermisosRol(int rolId, List<Integer> permisosIds, String usuario) throws SQLException {
        conexion.setAutoCommit(false);
        
        try {
            // 1. Desactivar todos los permisos del rol
            String sqlDesactivar = "UPDATE rol_permisos SET activo = 0 WHERE rol_id = ?";
            try (PreparedStatement ps = conexion.prepareStatement(sqlDesactivar)) {
                ps.setInt(1, rolId);
                ps.executeUpdate();
            }
            
            // 2. Activar los permisos seleccionados
            if (permisosIds != null && !permisosIds.isEmpty()) {
                String sqlActivar = "MERGE INTO rol_permisos AS target " +
                                   "USING (SELECT ? as rol_id, ? as permiso_id) AS source " +
                                   "ON target.rol_id = source.rol_id AND target.permiso_id = source.permiso_id " +
                                   "WHEN MATCHED THEN UPDATE SET activo = 1 " +
                                   "WHEN NOT MATCHED THEN INSERT (rol_id, permiso_id, activo) VALUES (source.rol_id, source.permiso_id, 1);";
                
                try (PreparedStatement ps = conexion.prepareStatement(sqlActivar)) {
                    for (int permisoId : permisosIds) {
                        ps.setInt(1, rolId);
                        ps.setInt(2, permisoId);
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            }
            
            // 3. Registrar auditoría
            AuditoriaDao auditoriaDao = new AuditoriaDao();
            auditoriaDao.registrarAuditoria("roles", rolId, "UPDATE", usuario, 
                "Permisos actualizados para rol ID: " + rolId + ". Total permisos: " + 
                (permisosIds != null ? permisosIds.size() : 0));
            
            conexion.commit();
            return true;
            
        } catch (SQLException e) {
            conexion.rollback();
            throw e;
        } finally {
            conexion.setAutoCommit(true);
        }
    }
    
    // Obtener nombre del rol por ID
    public String obtenerNombreRol(int rolId) throws SQLException {
        String sql = "SELECT nombre FROM roles WHERE id = ?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, rolId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("nombre");
                }
            }
        }
        return "Rol Desconocido";
    }
}