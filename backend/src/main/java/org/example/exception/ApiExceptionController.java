package org.example.exception;

public class ApiExceptionController extends RuntimeException {

    private final int status;
    private final String codigo;

    public ApiExceptionController(int status, String codigo, String msj){
        super(msj);
        this.status = status;
        this.codigo = codigo;
    }


    public int getStatus() {
        return status;
    }

    public String getCodigo(){
        return codigo;
    }
}
