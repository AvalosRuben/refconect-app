# refconect_app

App móvil (Flutter) para consultar piezas, existencias y equivalencias del catálogo de RefConect.

## Correr en local

1. Levanta la API de prueba (datos ficticios, sin dependencias extra):

   ```
   dart run tool/mock_api.dart
   ```

   Escucha en `http://localhost:3000/v1`. Usa `PORT=4000 dart run tool/mock_api.dart` para cambiar el puerto.

2. En otra terminal, corre la app:

   ```
   flutter run
   ```

   - Simulador de iOS: usa `http://localhost:3000` automáticamente.
   - Emulador de Android: usa `http://10.0.2.2:3000` automáticamente.
   - Teléfono físico: `flutter run --dart-define=API_BASE_URL=http://<IP-de-tu-laptop>:3000`

### Usuarios de prueba

| Usuario     | Contraseña       | Rol           |
|-------------|------------------|---------------|
| `empleado1` | `Refconect2026!` | empleado      |
| `admin`     | `Admin2026!`     | administrador |

Las sesiones viven en memoria: si reinicias la API, la app te pedirá iniciar sesión otra vez.

### Datos de prueba

30 piezas en 6 categorías (filtros, frenos, encendido, suspensión, distribución y eléctrico), con 7 grupos de equivalencias. Algunas piezas tienen existencia 0 o no tienen ubicación, para probar esos estados. Los datos están al inicio de [tool/mock_api.dart](tool/mock_api.dart).

Búsquedas útiles: `gp321` (número de parte sin guion), `bujia`, `aveo`, `filtro nissan`.

## Pruebas

```
flutter test
```
