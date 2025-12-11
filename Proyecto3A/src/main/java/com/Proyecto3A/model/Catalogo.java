package com.Proyecto3A.model;

import java.sql.Date;

public class Catalogo {
    private int id;
    private String productos;
    private double precio;
    private String oferta;
    private double precioFinal;
    private String foto;
    private Date fechaVencimiento;
    private boolean enOferta;
    private Double descuentoPorcentaje;
    private String estado = "activo";
    private String ultimoUsuarioModifico;
    private java.sql.Timestamp fechaUltimaModificacion;
    private int stock; // NUEVO: Campo para el stock

    // Constructor vacío
    public Catalogo() {}

    // Constructor completo
    public Catalogo(int id, String productos, double precio, String oferta, double precioFinal,
                    String foto, Date fechaVencimiento, boolean enOferta,
                    Double descuentoPorcentaje, String estado, int stock) {
        this.id = id;
        this.productos = productos;
        this.precio = precio;
        this.oferta = oferta;
        this.precioFinal = precioFinal;
        this.foto = foto;
        this.fechaVencimiento = fechaVencimiento;
        this.enOferta = enOferta;
        this.descuentoPorcentaje = descuentoPorcentaje;
        this.estado = estado;
        this.stock = stock;
    }

    // --- Getters y Setters ---
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getProductos() { return productos; }
    public void setProductos(String productos) { this.productos = productos; }

    public double getPrecio() { return precio; }
    public void setPrecio(double precio) { this.precio = precio; }

    public String getOferta() { return oferta; }
    public void setOferta(String oferta) { this.oferta = oferta; }

    public double getPrecioFinal() { return precioFinal; }
    public void setPrecioFinal(double precioFinal) { this.precioFinal = precioFinal; }

    public String getFoto() { return foto; }
    public void setFoto(String foto) { this.foto = foto; }

    public Date getFechaVencimiento() { return fechaVencimiento; }
    public void setFechaVencimiento(Date fechaVencimiento) { this.fechaVencimiento = fechaVencimiento; }

    public boolean isEnOferta() { return enOferta; }
    public void setEnOferta(boolean enOferta) { this.enOferta = enOferta; }

    public Double getDescuentoPorcentaje() { return descuentoPorcentaje; }
    public void setDescuentoPorcentaje(Double descuentoPorcentaje) { this.descuentoPorcentaje = descuentoPorcentaje; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    
    public String getUltimoUsuarioModifico() { return ultimoUsuarioModifico; }
    public void setUltimoUsuarioModifico(String ultimoUsuarioModifico) { this.ultimoUsuarioModifico = ultimoUsuarioModifico; }

    public java.sql.Timestamp getFechaUltimaModificacion() { return fechaUltimaModificacion; }
    public void setFechaUltimaModificacion(java.sql.Timestamp fechaUltimaModificacion) { this.fechaUltimaModificacion = fechaUltimaModificacion; }
    
    // NUEVO: Getter y Setter para stock
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
}