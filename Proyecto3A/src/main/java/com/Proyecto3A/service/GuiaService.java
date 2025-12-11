// GuiaService.java
package com.Proyecto3A.service;

import java.util.Date;
import java.util.List;
import com.Proyecto3A.dao.GuiaDao;
import com.Proyecto3A.model.Guia;
import com.Proyecto3A.model.GuiaDetalle;

public class GuiaService {
    
    private GuiaDao guiaDao;
    
    public GuiaService() {
        this.guiaDao = new GuiaDao();
    }
    
    // 🔹 Obtener todas las guías
    public List<Guia> obtenerTodasGuias() {
        return guiaDao.listarGuias();
    }
    
    // 🔹 Obtener guía por ID
    public Guia obtenerGuiaPorId(int id) {
        return guiaDao.obtenerGuiaConDetalles(id);
    }
    
    // 🔹 Crear nueva guía
    public boolean crearGuia(Guia guia, String usuario) {
        // Validar que el número de guía no exista
        if (guiaDao.existeNumeroGuia(guia.getNumeroGuia())) {
            throw new RuntimeException("El número de guía ya existe");
        }
        
        // Calcular totales
        calcularTotales(guia);
        
        return guiaDao.insertarGuia(guia, usuario);
    }
    
    // 🔹 Actualizar guía
    public boolean actualizarGuia(Guia guia, String usuario) {
        calcularTotales(guia);
        return guiaDao.actualizarGuia(guia, usuario);
    }
    
    // 🔹 Cambiar estado de guía
    public boolean cambiarEstadoGuia(int idGuia, String nuevoEstado, String usuario) {
        return guiaDao.cambiarEstadoGuia(idGuia, nuevoEstado, usuario);
    }
    
    // 🔹 Anular guía
    public boolean anularGuia(int idGuia, String usuario) {
        return guiaDao.anularGuia(idGuia, usuario);
    }
    
    // 🔹 Buscar guías con filtros
    public List<Guia> buscarGuias(String numeroGuia, Date fechaInicio, Date fechaFin, 
                                 String estado, Integer tiendaId) {
        return guiaDao.buscarGuias(numeroGuia, fechaInicio, fechaFin, estado, tiendaId);
    }
    
    // 🔹 Validar guía antes de guardar
    public String validarGuia(Guia guia) {
        if (guia.getNumeroGuia() == null || guia.getNumeroGuia().trim().isEmpty()) {
            return "El número de guía es obligatorio";
        }
        if (guia.getProveedor() == null || guia.getProveedor().trim().isEmpty()) {
            return "El proveedor es obligatorio";
        }
        if (guia.getFechaEmision() == null) {
            return "La fecha de emisión es obligatoria";
        }
        if (guia.getFechaRecepcion() == null) {
            return "La fecha de recepción es obligatoria";
        }
        if (guia.getTiendaId() <= 0) {
            return "Debe seleccionar una tienda";
        }
        if (guia.getDetalles() == null || guia.getDetalles().isEmpty()) {
            return "Debe agregar al menos un producto a la guía";
        }
        
        // Validar fechas
        if (guia.getFechaRecepcion().before(guia.getFechaEmision())) {
            return "La fecha de recepción no puede ser anterior a la fecha de emisión";
        }
        
        return null; // Sin errores
    }
    
    // 🔹 Calcular totales de la guía
    private void calcularTotales(Guia guia) {
        if (guia.getDetalles() != null) {
            int totalProductos = 0;
            double totalValor = 0.0;
            
            for (GuiaDetalle detalle : guia.getDetalles()) {
                totalProductos += detalle.getCantidad();
                totalValor += detalle.getSubtotal();
            }
            
            guia.setTotalProductos(totalProductos);
            guia.setTotalValor(totalValor);
        }
    }
}