// Guia.java
package com.Proyecto3A.model;

import java.util.Date;
import java.util.List;

public class Guia {
    private int idGuia;
    private String numeroGuia;
    private String proveedor;
    private Date fechaEmision;
    private Date fechaRecepcion;
    private int totalProductos;
    private double totalValor;
    private int tiendaId;
    private String tiendaNombre;
    private String usuarioRegistro;
    private Date fechaRegistro;
    private String estado;
    private String ultimoUsuarioModifico;
    private Date fechaUltimaModificacion;
    private List<GuiaDetalle> detalles;

    // Constructores
    public Guia() {}

    public Guia(String numeroGuia, String proveedor, Date fechaEmision, Date fechaRecepcion, 
                int tiendaId, String usuarioRegistro) {
        this.numeroGuia = numeroGuia;
        this.proveedor = proveedor;
        this.fechaEmision = fechaEmision;
        this.fechaRecepcion = fechaRecepcion;
        this.tiendaId = tiendaId;
        this.usuarioRegistro = usuarioRegistro;
        this.estado = "pendiente";
        this.totalProductos = 0;
        this.totalValor = 0.0;
    }

    // Getters y Setters
    public int getIdGuia() { return idGuia; }
    public void setIdGuia(int idGuia) { this.idGuia = idGuia; }

    public String getNumeroGuia() { return numeroGuia; }
    public void setNumeroGuia(String numeroGuia) { this.numeroGuia = numeroGuia; }

    public String getProveedor() { return proveedor; }
    public void setProveedor(String proveedor) { this.proveedor = proveedor; }

    public Date getFechaEmision() { return fechaEmision; }
    public void setFechaEmision(Date fechaEmision) { this.fechaEmision = fechaEmision; }

    public Date getFechaRecepcion() { return fechaRecepcion; }
    public void setFechaRecepcion(Date fechaRecepcion) { this.fechaRecepcion = fechaRecepcion; }

    public int getTotalProductos() { return totalProductos; }
    public void setTotalProductos(int totalProductos) { this.totalProductos = totalProductos; }

    public double getTotalValor() { return totalValor; }
    public void setTotalValor(double totalValor) { this.totalValor = totalValor; }

    public int getTiendaId() { return tiendaId; }
    public void setTiendaId(int tiendaId) { this.tiendaId = tiendaId; }

    public String getTiendaNombre() { return tiendaNombre; }
    public void setTiendaNombre(String tiendaNombre) { this.tiendaNombre = tiendaNombre; }

    public String getUsuarioRegistro() { return usuarioRegistro; }
    public void setUsuarioRegistro(String usuarioRegistro) { this.usuarioRegistro = usuarioRegistro; }

    public Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getUltimoUsuarioModifico() { return ultimoUsuarioModifico; }
    public void setUltimoUsuarioModifico(String ultimoUsuarioModifico) { this.ultimoUsuarioModifico = ultimoUsuarioModifico; }

    public Date getFechaUltimaModificacion() { return fechaUltimaModificacion; }
    public void setFechaUltimaModificacion(Date fechaUltimaModificacion) { this.fechaUltimaModificacion = fechaUltimaModificacion; }

    public List<GuiaDetalle> getDetalles() { return detalles; }
    public void setDetalles(List<GuiaDetalle> detalles) { this.detalles = detalles; }

    public void agregarDetalle(GuiaDetalle detalle) {
        this.detalles.add(detalle);
        this.totalProductos += detalle.getCantidad();
        this.totalValor += detalle.getSubtotal();
    }
}