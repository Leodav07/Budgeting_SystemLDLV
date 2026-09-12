package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record Usuario (
    String usuario_dni,
    String primer_nombre,
    String segundo_nombre,
    String primer_apellido,
    String segundo_apellido,
    String email,
    LocalDateTime fecha_registro,
    BigDecimal salario,
    boolean estado
)
{
}
