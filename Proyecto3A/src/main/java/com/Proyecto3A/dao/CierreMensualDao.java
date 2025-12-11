// Archivo: com/Proyecto3A/dao/CierreMensualDao.java
package com.Proyecto3A.dao;

import com.Proyecto3A.model.CierreMensual;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CierreMensualDao {
    private Connection conexion;
    
    public CierreMensualDao() {
    	 String url = "jdbc:sqlserver://localhost:1433;databaseName=tienda3a;user=sa;password=unpollito191912;encrypt=true;trustServerCertificate=true;";
         try {
             Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
             conexion = DriverManager.getConnection(url);
         } catch (ClassNotFoundException | SQLException e) {
             e.printStackTrace();
         }
    }
    
    // Método para obtener todos los cierres mensuales
    public List<CierreMensual> listarCierresMensuales() {
        List<CierreMensual> cierres = new ArrayList<>();
        String sql = "SELECT c.*, t.nombre as nombre_tienda " +
                     "FROM cierre_mensual c " +
                     "LEFT JOIN tiendas t ON c.tiendaid = t.id " +
                     "ORDER BY c.anio DESC, c.mes DESC";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                CierreMensual cierre = mapearCierre(rs);
                cierres.add(cierre);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en listarCierresMensuales: " + e.getMessage());
        }
        return cierres;
    }
    
    // Método para obtener cierres por tienda
    public List<CierreMensual> listarCierresPorTienda(int tiendaId) {
        List<CierreMensual> cierres = new ArrayList<>();
        String sql = "SELECT * FROM cierre_mensual WHERE tiendaid = ? ORDER BY anio DESC, mes DESC";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, tiendaId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                CierreMensual cierre = mapearCierre(rs);
                cierres.add(cierre);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en listarCierresPorTienda: " + e.getMessage());
        }
        return cierres;
    }
    
    // Método para obtener un cierre por ID
    public CierreMensual obtenerCierrePorId(int id) {
        CierreMensual cierre = null;
        String sql = "SELECT * FROM cierre_mensual WHERE id = ?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                cierre = mapearCierre(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en obtenerCierrePorId: " + e.getMessage());
        }
        return cierre;
    }
    
    // Método para insertar un nuevo cierre mensual
    public boolean insertarCierreMensual(CierreMensual cierre) {
        String sql = "INSERT INTO cierre_mensual (tiendaid, anio, mes, totalventas, totalcostos, estado) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, cierre.getTiendaid());
            ps.setInt(2, cierre.getAnio());
            ps.setInt(3, cierre.getMes());
            ps.setDouble(4, cierre.getTotalventas());
            ps.setDouble(5, cierre.getTotalcostos());
            ps.setString(6, cierre.getEstado());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en insertarCierreMensual: " + e.getMessage());
            return false;
        }
    }
    
    // Método para actualizar el estado de un cierre
    public boolean actualizarEstadoCierre(int id, String estado) {
        String sql = "UPDATE cierre_mensual SET estado = ? WHERE id = ?";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setString(1, estado);
            ps.setInt(2, id);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en actualizarEstadoCierre: " + e.getMessage());
            return false;
        }
    }
    
    // Método para obtener estadísticas anuales
    public List<CierreMensual> obtenerEstadisticasAnuales(int anio) {
        List<CierreMensual> cierres = new ArrayList<>();
        String sql = "SELECT * FROM cierre_mensual WHERE anio = ? ORDER BY mes";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, anio);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                CierreMensual cierre = mapearCierre(rs);
                cierres.add(cierre);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en obtenerEstadisticasAnuales: " + e.getMessage());
        }
        return cierres;
    }
    
    // Método para obtener resumen por año
    public List<Object[]> obtenerResumenAnual(int anio) {
        List<Object[]> resumen = new ArrayList<>();
        String sql = "SELECT " +
                     "  c.mes, " +
                     "  SUM(c.totalventas) as ventas_totales, " +
                     "  SUM(c.totalcostos) as costos_totales, " +
                     "  AVG((c.totalventas - c.totalcostos) / c.totalventas * 100) as margen_promedio " +
                     "FROM cierre_mensual c " +
                     "WHERE c.anio = ? AND c.estado = 'cerrado' " +
                     "GROUP BY c.mes " +
                     "ORDER BY c.mes";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, anio);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Object[] fila = new Object[4];
                fila[0] = rs.getInt("mes");
                fila[1] = rs.getDouble("ventas_totales");
                fila[2] = rs.getDouble("costos_totales");
                fila[3] = rs.getDouble("margen_promedio");
                resumen.add(fila);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en obtenerResumenAnual: " + e.getMessage());
        }
        return resumen;
    }
    
    // Método auxiliar para mapear ResultSet a objeto CierreMensual
    private CierreMensual mapearCierre(ResultSet rs) throws SQLException {
        CierreMensual cierre = new CierreMensual();
        cierre.setId(rs.getInt("id"));
        cierre.setTiendaid(rs.getInt("tiendaid"));
        cierre.setAnio(rs.getInt("anio"));
        cierre.setMes(rs.getInt("mes"));
        cierre.setTotalventas(rs.getDouble("totalventas"));
        cierre.setTotalcostos(rs.getDouble("totalcostos"));
        cierre.setEstado(rs.getString("estado"));
        return cierre;
    }
    
    // Método para obtener años disponibles
    public List<Integer> obtenerAniosDisponibles() {
        List<Integer> anios = new ArrayList<>();
        String sql = "SELECT DISTINCT anio FROM cierre_mensual ORDER BY anio DESC";
        
        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                anios.add(rs.getInt("anio"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en obtenerAniosDisponibles: " + e.getMessage());
        }
        return anios;
    }
}