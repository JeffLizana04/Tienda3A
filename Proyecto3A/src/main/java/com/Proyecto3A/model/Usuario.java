package com.Proyecto3A.model;

public class Usuario {
    private int id;
    private String nombre;
    private String correo;
    private String contrasenha;
    private int rolid;
    private int tiendaid;
    private String estado;
    private String rolNombre; // Para mostrar el nombre del rol
    
    // Constructores
    public Usuario() {}
    
    public Usuario(int id, String nombre, String correo, String contrasenha, 
                   int rolid, int tiendaid, String estado) {
        this.id = id;
        this.nombre = nombre;
        this.correo = correo;
        this.contrasenha = contrasenha;
        this.rolid = rolid;
        this.tiendaid = tiendaid;
        this.estado = estado;
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
    
    public String getContrasenha() { return contrasenha; }
    public void setContrasenha(String contrasenha) { this.contrasenha = contrasenha; }
    
    public int getRolid() { return rolid; }
    public void setRolid(int rolid) { this.rolid = rolid; }
    
    public int getTiendaid() { return tiendaid; }
    public void setTiendaid(int tiendaid) { this.tiendaid = tiendaid; }
    
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    
    public String getRolNombre() { return rolNombre; }
    public void setRolNombre(String rolNombre) { this.rolNombre = rolNombre; }
}