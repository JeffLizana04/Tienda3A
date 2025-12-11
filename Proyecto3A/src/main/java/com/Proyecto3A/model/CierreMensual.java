// Archivo: com/Proyecto3A/model/CierreMensual.java
package com.Proyecto3A.model;

public class CierreMensual {
    private int id;
    private int tiendaid;
    private int anio;
    private int mes;
    private double totalventas;
    private double totalcostos;
    private String estado;
    
    // Constructor vacío
    public CierreMensual() {}
    
    // Constructor con parámetros
    public CierreMensual(int id, int tiendaid, int anio, int mes, 
                        double totalventas, double totalcostos, String estado) {
        this.id = id;
        this.tiendaid = tiendaid;
        this.anio = anio;
        this.mes = mes;
        this.totalventas = totalventas;
        this.totalcostos = totalcostos;
        this.estado = estado;
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getTiendaid() { return tiendaid; }
    public void setTiendaid(int tiendaid) { this.tiendaid = tiendaid; }
    
    public int getAnio() { return anio; }
    public void setAnio(int anio) { this.anio = anio; }
    
    public int getMes() { return mes; }
    public void setMes(int mes) { this.mes = mes; }
    
    public double getTotalventas() { return totalventas; }
    public void setTotalventas(double totalventas) { this.totalventas = totalventas; }
    
    public double getTotalcostos() { return totalcostos; }
    public void setTotalcostos(double totalcostos) { this.totalcostos = totalcostos; }
    
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    
    // Métodos útiles
    public double getGanancia() {
        return totalventas - totalcostos;
    }
    
    public double getMargenGanancia() {
        if (totalventas == 0) return 0;
        return ((totalventas - totalcostos) / totalventas) * 100;
    }
    
    public String getMesNombre() {
        String[] meses = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                         "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"};
        if (mes >= 1 && mes <= 12) {
            return meses[mes - 1];
        }
        return "Desconocido";
    }
}