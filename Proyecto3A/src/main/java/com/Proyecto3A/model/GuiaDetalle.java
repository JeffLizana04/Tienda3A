// GuiaDetalle.java
package com.Proyecto3A.model;

import java.util.Date;

public class GuiaDetalle {
    private int idDetalle;
    private int idGuia;
    private int idProducto;
    private String productoNombre;
    private int cantidad;
    private double precioUnitario;
    private double subtotal;
    private Date fechaVencimiento;
    private String lote;
    private String ubicacion;
    private String estado;

    // Constructores
    public GuiaDetalle() {
        this.estado = "pendiente";
    }

    public GuiaDetalle(int idProducto, String productoNombre, int cantidad, double precioUnitario, 
                      Date fechaVencimiento) {
        this.idProducto = idProducto;
        this.productoNombre = productoNombre;
        this.cantidad = cantidad;
        this.precioUnitario = precioUnitario;
        this.subtotal = cantidad * precioUnitario;
        this.fechaVencimiento = fechaVencimiento;
        this.estado = "pendiente";
    }

    // Getters y Setters
    public int getIdDetalle() { return idDetalle; }
    public void setIdDetalle(int idDetalle) { this.idDetalle = idDetalle; }

    public int getIdGuia() { return idGuia; }
    public void setIdGuia(int idGuia) { this.idGuia = idGuia; }

    public int getIdProducto() { return idProducto; }
    public void setIdProducto(int idProducto) { this.idProducto = idProducto; }

    public String getProductoNombre() { return productoNombre; }
    public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { 
        this.cantidad = cantidad;
        this.subtotal = this.cantidad * this.precioUnitario;
    }

    public double getPrecioUnitario() { return precioUnitario; }
    public void setPrecioUnitario(double precioUnitario) { 
        this.precioUnitario = precioUnitario;
        this.subtotal = this.cantidad * this.precioUnitario;
    }

    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }

    public Date getFechaVencimiento() { return fechaVencimiento; }
    public void setFechaVencimiento(Date fechaVencimiento) { this.fechaVencimiento = fechaVencimiento; }

    public String getLote() { return lote; }
    public void setLote(String lote) { this.lote = lote; }

    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = ubicacion; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}