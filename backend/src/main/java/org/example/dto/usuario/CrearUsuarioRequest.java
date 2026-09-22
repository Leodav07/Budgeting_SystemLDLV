package org.example.dto.usuario;

import java.math.BigDecimal;

public record CrearUsuarioRequest (
        String dni,
        String p_nombre,
        String s_nombre,
        String p_apellido,
        String s_apellido,
        String correo_elec,
        BigDecimal psalario,
        String pcreado_por,
        String p_contrasenia
){
}
