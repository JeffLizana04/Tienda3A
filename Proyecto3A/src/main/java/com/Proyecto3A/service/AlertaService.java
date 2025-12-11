package com.Proyecto3A.service;

import com.Proyecto3A.dao.CatalogoDao;
import com.Proyecto3A.model.Catalogo;
import java.util.List;
import java.util.ArrayList;

public class AlertaService {
    private CatalogoDao catalogoDao;
    
    public AlertaService() {
        this.catalogoDao = new CatalogoDao();
    }
    
    /**
     * Obtiene productos que están próximos a vencer (dentro de 3 días)
     */
    public List<Catalogo> obtenerAlertasVencimiento() {
        try {
            return catalogoDao.obtenerProductosProximosAVencer(3); // 3 días antes
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>(); // Retorna lista vacía en caso de error
        }
    }
    
    /**
     * Verifica si hay productos próximos a vencer
     */
    public boolean hayProductosProximosAVencer() {
        try {
            return catalogoDao.hayProductosProximosAVencer(3); // Usa el método nuevo
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Obtiene productos que deben ir a oferta urgente (dentro de 2 días)
     */
    public List<Catalogo> obtenerProductosParaOfertaUrgente() {
        try {
            return catalogoDao.obtenerProductosProximosAVencer(2); // 2 días - más urgente
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    /**
     * Obtiene el conteo de productos próximos a vencer
     */
    public int obtenerCantidadAlertas() {
        List<Catalogo> productos = obtenerAlertasVencimiento();
        return productos != null ? productos.size() : 0;
    }
}