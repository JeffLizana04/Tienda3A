package com.Proyecto3A.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.Proyecto3A.model.Usuario;

public class PersonalDao {
    private Connection conexion;
    
    public PersonalDao() {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=tienda3a;user=sa;password=unpollito191912;encrypt=true;trustServerCertificate=true;";
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conexion = DriverManager.getConnection(url);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Obtener todos los usuarios con información de roles y tiendas
    public List<Usuario> listarPersonal() throws SQLException {
        List<Usuario> lista = new ArrayList<>();
        String sql = "SELECT u.*, r.nombre as rol_nombre, t.nombre as tienda_nombre " +
                    "FROM usuario u " +
                    "INNER JOIN roles r ON u.rolid = r.id " +
                    "INNER JOIN tiendas t ON u.tiendaid = t.id " +
                    "ORDER BY u.nombre";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Usuario usuario = new Usuario();
                usuario.setId(rs.getInt("id"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setCorreo(rs.getString("correo"));
                usuario.setRolid(rs.getInt("rolid"));
                usuario.setTiendaid(rs.getInt("tiendaid"));
                usuario.setEstado(rs.getString("estado"));
                usuario.setRolNombre(rs.getString("rol_nombre"));
                lista.add(usuario);
            }
        }
        return lista;
    }
    
    // Obtener usuario por ID
    public Usuario obtenerPorId(int id) throws SQLException {
        String sql = "SELECT u.*, r.nombre as rol_nombre, t.nombre as tienda_nombre " +
                    "FROM usuario u " +
                    "INNER JOIN roles r ON u.rolid = r.id " +
                    "INNER JOIN tiendas t ON u.tiendaid = t.id " +
                    "WHERE u.id = ?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Usuario usuario = new Usuario();
                    usuario.setId(rs.getInt("id"));
                    usuario.setNombre(rs.getString("nombre"));
                    usuario.setCorreo(rs.getString("correo"));
                    usuario.setRolid(rs.getInt("rolid"));
                    usuario.setTiendaid(rs.getInt("tiendaid"));
                    usuario.setEstado(rs.getString("estado"));
                    usuario.setRolNombre(rs.getString("rol_nombre"));
                    return usuario;
                }
            }
        }
        return null;
    }
    
    // Crear nuevo usuario
    public boolean crearUsuario(Usuario usuario, String usuarioRegistrador) throws SQLException {
        String sql = "INSERT INTO usuario (nombre, correo, contrasenha, rolid, tiendaid, estado, ultimo_usuario_modifico, fecha_ultima_modificacion) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, usuario.getNombre());
            ps.setString(2, usuario.getCorreo());
            ps.setString(3, usuario.getContrasenha());
            ps.setInt(4, usuario.getRolid());
            ps.setInt(5, usuario.getTiendaid());
            ps.setString(6, usuario.getEstado());
            ps.setString(7, usuarioRegistrador);
            
            int resultado = ps.executeUpdate();
            if (resultado > 0) {
                // Registrar auditoría
                registrarAuditoria("INSERT", obtenerUltimoId(), usuarioRegistrador, 
                    "Usuario creado: " + usuario.getNombre() + " (" + usuario.getCorreo() + ")");
                return true;
            }
        }
        return false;
    }
    
    // Actualizar usuario
    public boolean actualizarUsuario(Usuario usuario, String usuarioModificador) throws SQLException {
        // Obtener usuario anterior para auditoría
        Usuario usuarioAnterior = obtenerPorId(usuario.getId());
        if (usuarioAnterior == null) return false;
        
        String sql = "UPDATE usuario SET nombre=?, correo=?, rolid=?, tiendaid=?, estado=?, " +
                    "ultimo_usuario_modifico=?, fecha_ultima_modificacion=GETDATE() WHERE id=?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, usuario.getNombre());
            ps.setString(2, usuario.getCorreo());
            ps.setInt(3, usuario.getRolid());
            ps.setInt(4, usuario.getTiendaid());
            ps.setString(5, usuario.getEstado());
            ps.setString(6, usuarioModificador);
            ps.setInt(7, usuario.getId());
            
            int resultado = ps.executeUpdate();
            if (resultado > 0) {
                // Registrar auditoría
                String detalles = generarDetallesCambios(usuarioAnterior, usuario);
                registrarAuditoria("UPDATE", usuario.getId(), usuarioModificador, detalles);
                return true;
            }
        }
        return false;
    }
    
    // Cambiar estado de usuario
    public boolean cambiarEstadoUsuario(int id, String nuevoEstado, String usuarioModificador) throws SQLException {
        Usuario usuario = obtenerPorId(id);
        if (usuario == null) return false;
        
        String sql = "UPDATE usuario SET estado=?, ultimo_usuario_modifico=?, fecha_ultima_modificacion=GETDATE() WHERE id=?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            ps.setString(2, usuarioModificador);
            ps.setInt(3, id);
            
            int resultado = ps.executeUpdate();
            if (resultado > 0) {
                String detalles = "Estado cambiado de '" + usuario.getEstado() + "' a '" + nuevoEstado + "'";
                registrarAuditoria("UPDATE", id, usuarioModificador, detalles);
                return true;
            }
        }
        return false;
    }
    
    // Obtener roles disponibles
    public List<Map<String, Object>> obtenerRoles() throws SQLException {
        List<Map<String, Object>> roles = new ArrayList<>();
        String sql = "SELECT id, nombre, descripcion FROM roles ORDER BY id";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> rol = new HashMap<>();
                rol.put("id", rs.getInt("id"));
                rol.put("nombre", rs.getString("nombre"));
                rol.put("descripcion", rs.getString("descripcion"));
                roles.add(rol);
            }
        }
        return roles;
    }
    
    // Obtener tiendas disponibles
    public List<Map<String, Object>> obtenerTiendas() throws SQLException {
        List<Map<String, Object>> tiendas = new ArrayList<>();
        String sql = "SELECT id, nombre FROM tiendas ORDER BY nombre";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> tienda = new HashMap<>();
                tienda.put("id", rs.getInt("id"));
                tienda.put("nombre", rs.getString("nombre"));
                tiendas.add(tienda);
            }
        }
        return tiendas;
    }
    
    // Verificar si correo ya existe
    public boolean correoExiste(String correo) throws SQLException {
        String sql = "SELECT COUNT(*) as total FROM usuario WHERE correo = ?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, correo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
        }
        return false;
    }
    
    // Métodos privados
    private int obtenerUltimoId() throws SQLException {
        String sql = "SELECT MAX(id) as ultimo_id FROM usuario";
        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("ultimo_id");
            }
        }
        return 0;
    }
    
    private void registrarAuditoria(String accion, int idRegistro, String usuario, String detalles) throws SQLException {
        AuditoriaDao auditoriaDao = new AuditoriaDao();
        auditoriaDao.registrarAuditoria("usuario", idRegistro, accion, usuario, detalles);
    }
    
    private String generarDetallesCambios(Usuario anterior, Usuario nuevo) {
        StringBuilder detalles = new StringBuilder();
        
        if (!anterior.getNombre().equals(nuevo.getNombre())) {
            detalles.append("Nombre: '").append(anterior.getNombre()).append("' → '").append(nuevo.getNombre()).append("'; ");
        }
        if (!anterior.getCorreo().equals(nuevo.getCorreo())) {
            detalles.append("Correo: '").append(anterior.getCorreo()).append("' → '").append(nuevo.getCorreo()).append("'; ");
        }
        if (anterior.getRolid() != nuevo.getRolid()) {
            detalles.append("Rol ID: ").append(anterior.getRolid()).append(" → ").append(nuevo.getRolid()).append("; ");
        }
        if (anterior.getTiendaid() != nuevo.getTiendaid()) {
            detalles.append("Tienda ID: ").append(anterior.getTiendaid()).append(" → ").append(nuevo.getTiendaid()).append("; ");
        }
        if (!anterior.getEstado().equals(nuevo.getEstado())) {
            detalles.append("Estado: '").append(anterior.getEstado()).append("' → '").append(nuevo.getEstado()).append("'; ");
        }
        
        if (detalles.length() == 0) {
            detalles.append("Actualización general del usuario");
        }
        
        return detalles.toString();
    }
}