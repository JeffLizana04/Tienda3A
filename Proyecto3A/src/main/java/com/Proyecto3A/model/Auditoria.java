package com.Proyecto3A.model;

import java.sql.Timestamp;

public class Auditoria {
    private int idAuditoria;
    private String tablaAfectada;
    private int idRegistro;
    private String accion;
    private String usuario;
    private Timestamp fechaAccion;
    private String valoresAnteriores;
    private String valoresNuevos;
    private String detalles;
    
    
    public Auditoria() {}
    
    // Getters y Setters
    public int getIdAuditoria() { return idAuditoria; }
    public void setIdAuditoria(int idAuditoria) { this.idAuditoria = idAuditoria; }
    
    public String getTablaAfectada() { return tablaAfectada; }
    public void setTablaAfectada(String tablaAfectada) { this.tablaAfectada = tablaAfectada; }
    
    public int getIdRegistro() { return idRegistro; }
    public void setIdRegistro(int idRegistro) { this.idRegistro = idRegistro; }
    
    public String getAccion() { return accion; }
    public void setAccion(String accion) { this.accion = accion; }
    
    public String getUsuario() { return usuario; }
    public void setUsuario(String usuario) { this.usuario = usuario; }
    
    public Timestamp getFechaAccion() { return fechaAccion; }
    public void setFechaAccion(Timestamp fechaAccion) { this.fechaAccion = fechaAccion; }
    
    public String getValoresAnteriores() { return valoresAnteriores; }
    public void setValoresAnteriores(String valoresAnteriores) { this.valoresAnteriores = valoresAnteriores; }
    
    public String getValoresNuevos() { return valoresNuevos; }
    public void setValoresNuevos(String valoresNuevos) { this.valoresNuevos = valoresNuevos; }
    
    public String getDetalles() { return detalles; }
    public void setDetalles(String detalles) { this.detalles = detalles; }
    
 }