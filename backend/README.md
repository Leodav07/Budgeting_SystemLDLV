# Backend

API REST en Java (Javalin 6.7.0, Java 21) que sirve de intermediario entre el frontend y la base de datos. No tiene lógica de negocio propia: cada endpoint recibe la petición, llama al procedimiento o función almacenada correspondiente en MySQL, y devuelve el resultado como JSON.

## Cómo correr

Requiere Java 21 y Maven. Antes de correr, revisar `src/main/java/org/example/config/DBConnection.java` y ajustar el usuario, contraseña y nombre de la base de datos a los de tu entorno.

```
mvn compile exec:java -Dexec.mainClass=org.example.Main
```

o ejecutar la clase `Main` directamente desde el IDE. El servidor levanta en `http://localhost:7070`.

## Estructura (`src/main/java/org/example/`)

- **`Main.java`** — punto de entrada. Levanta el servidor Javalin en el puerto 7070 y registra todas las rutas.
- **`config/DBConnection.java`** — abre la conexión JDBC hacia MySQL.
- **`routes/`** — define las URLs de cada endpoint (una clase por entidad: usuarios, categorías, subcategorías, presupuestos, detalles de presupuesto, obligaciones, transacciones, reportes, login) y las conecta con su controller.
- **`controller/`** — recibe la petición HTTP, valida y extrae los datos, llama al repository correspondiente y arma la respuesta.
- **`repository/`** — ejecuta el `CallableStatement` (llamada al procedimiento/función almacenada) contra la base de datos y mapea el `ResultSet` a objetos Java.
- **`model/`** — clases que representan las entidades del sistema (Usuario, Categoria, Subcategoria, Presupuesto, etc.).
- **`dto/`** — objetos usados para recibir el body de las peticiones o devolver respuestas con una forma distinta a la del modelo (por ejemplo, los datos de los reportes).
- **`exception/`** — manejo centralizado de errores: traduce los mensajes `SIGNAL SQLSTATE` que lanzan los procedimientos de MySQL (por ejemplo `USUARIO_NO_EXISTE`) en respuestas HTTP con el código de estado adecuado.

## Autenticación

El login usa hash de contraseña con PBKDF2 (`PasswordAuthentication.java`), no contraseñas en texto plano. El usuario se autentica por DNI.
