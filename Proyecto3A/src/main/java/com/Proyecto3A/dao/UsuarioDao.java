package com.Proyecto3A.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.Proyecto3A.model.Usuario;

public class UsuarioDao {
    private String url;
    private Connection conexion;
    
    public UsuarioDao() {
        this.url = "jdbc:sqlserver://localhost:1433;databaseName=tienda3a;user=sa;password=unpollito191912;encrypt=true;trustServerCertificate=true;";
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            this.conexion = DriverManager.getConnection(this.url);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }   
    }
    
    public boolean validarUsuario(String correo, String contrasenha) throws SQLException {
        String query = "SELECT * FROM Usuario WHERE correo=? AND contrasenha=? AND estado='activo'";
        try (PreparedStatement ps = this.conexion.prepareStatement(query)) {
            ps.setString(1, correo);
            ps.setString(2, contrasenha);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }
    
    public Usuario obtenerUsuarioCompleto(String correo, String contrasenha) throws SQLException {
        String query = "SELECT u.*, r.nombre as rolNombre " +
                      "FROM Usuario u " +
                      "INNER JOIN roles r ON u.rolid = r.id " +
                      "WHERE u.correo=? AND u.contrasenha=? AND u.estado='activo'";
        
        try (PreparedStatement ps = this.conexion.prepareStatement(query)) {
            ps.setString(1, correo);
            ps.setString(2, contrasenha);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Usuario usuario = new Usuario();
                usuario.setId(rs.getInt("id"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setCorreo(rs.getString("correo"));
                usuario.setRolid(rs.getInt("rolid"));
                usuario.setTiendaid(rs.getInt("tiendaid"));
                usuario.setEstado(rs.getString("estado"));
                usuario.setRolNombre(rs.getString("rolNombre"));
                return usuario;
            }
        }
        return null;
    }
    
    public String obtenerNombreUsuario(String correo, String contrasenha) throws SQLException {
        String query = "SELECT nombre FROM Usuario WHERE correo=? AND contrasenha=? AND estado='activo'";
        try (PreparedStatement ps = this.conexion.prepareStatement(query)) {
            ps.setString(1, correo);
            ps.setString(2, contrasenha);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("nombre");
            }
        }
        return null;
    }
}