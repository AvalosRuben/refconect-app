# Rediseño visual de RefConect (opción B)

## Intención
Los vendedores de mostrador consultan piezas en el celular, de pie y con prisa. Hoy la app funciona, pero se ve como una plantilla de Material: poco premium y poco estética. Queremos que se vea como un producto cuidado, sin perder rapidez de lectura. Después de esto se agregan funciones nuevas sobre esta base.

## Metas
- Identidad propia y consistente en todas las pantallas: login, splash, inicio, detalle, estados vacío y error.
- Que lo que el vendedor busca con la vista se lea primero: el número de parte y la existencia.
- Un solo sistema de tokens (color, tipografía, radios, espacios, sombras) en `app_theme.dart`. Las pantallas no llevan números mágicos.

## No metas
- Cambiar la lógica, los providers, la API o la navegación.
- Agregar funciones nuevas (eso viene después).
- Hacer un modo oscuro (se puede agregar después, porque los tokens lo permiten).

## Antimetas (sería un fracaso aunque funcione)
- Que se vea más bonito pero se lea más lento: texto más chico, poco contraste o existencia escondida.
- Que la existencia se comunique solo con color.
- Animaciones que retrasen la consulta (nada de más de 250 ms ni efectos por scroll).

## Restricciones (piso de accesibilidad, ya existente)
- Cuerpo de texto de 16 sp o más e importantes de 18 a 22 sp; contraste AA.
- Objetivos táctiles de 48 px o más.
- Existencia siempre con ícono y texto.
- Funciona sin internet (la API es local), así que las fuentes van empaquetadas como assets, sin `google_fonts` en tiempo de ejecución.
- Los textos que usan las pruebas (por ejemplo «Iniciar sesión» y «Usuario») se conservan.

## Enfoques considerados
- **A. Pulido:** cambiar colores, bordes y logo sin tocar la estructura. Descartado porque sigue viéndose de plantilla.
- **B. Rediseño con sistema propio (elegido):** tema y widgets compartidos nuevos, con la misma lógica.
- **C. Estilo de una marca (Linear, Stripe...):** descartado porque esas marcas están pensadas para web de escritorio y se pierde la identidad de RefConect.

## Diseño
**Paleta (tokens):**
- Tinta `#0F1B2D` para texto principal y superficies oscuras.
- Primario azul profundo `#1B3A5C`.
- Acento naranja `#F28C28`, solo para la acción principal y para lo destacado.
- Fondo cálido `#F6F4F0`, superficie blanca y bordes `#E6E1D9`.
- Estados con las tintas actuales (éxito, advertencia, error) y sus fondos tenues, con el contraste revisado.

**Tipografía:**
- Manrope (400, 500, 700, 800) para toda la interfaz.
- JetBrains Mono (600) para el número de parte, en tarjetas, detalle y equivalentes.

**Forma y profundidad:**
- Radios de 12, 16 y 24.
- Sombras suaves de dos capas en lugar del borde gris de la tarjeta.
- Espaciado en una escala de 4 (4, 8, 12, 16, 24, 32).

**Inicio:**
- Encabezado claro en lugar de la AppBar azul: «Hola, Nombre» grande y la cuenta de piezas debajo.
- Cerrar sesión pasa a ser un botón de ícono discreto.
- Lista de tarjetas.
- Abajo, un panel flotante redondeado con los chips de categoría y el buscador grande, siempre al alcance del pulgar.

```
 Hola, Juan                    [⎋]
 1,240 piezas en catálogo
┌──────────────────────────────────┐
│ ▌ FR-2231-A          ✓ 12 pzas  │
│   Bosch · Frenos                 │
│   Balata delantera cerámica      │
│   📍 A-03                        │
└──────────────────────────────────┘
╭──────────────────────────────────╮
│ (Todas)(Frenos)(Motor)(Eléctrico)│
│ 🔍 Número de parte, marca…       │
╰──────────────────────────────────╯
```

**Tarjeta de pieza:**
- Barra lateral de color según la existencia (refuerzo visual, no la única señal).
- Número de parte en mono grande y existencia como pastilla a la derecha.
- Marca, categoría y descripción debajo, y etiquetas de ubicación y «Tiene equivalentes».

**Detalle:**
- Cabecera oscura (tinta) con el número de parte en mono, marca y descripción.
- La existencia en número grande con su pastilla de estado, y la ubicación.
- Tarjeta del grupo con la existencia total.
- Equivalentes en lista con el mismo estilo que la tarjeta de pieza; el de mayor existencia va marcado.

**Login y splash:**
- Logo nuevo (monograma «RC» en un cuadro de tinta con un punto naranja) y fondo cálido.
- Formulario en una tarjeta elevada.
- Splash con el mismo logo.

**Estados:** vacío y error con ícono dentro de un círculo tenue, título y botón con el estilo nuevo.

**Movimiento:**
- Transición de página con desvanecimiento y deslizamiento corto (200 ms).
- Pastillas y chips con transición de color de 150 ms.
- Respeta `MediaQuery.disableAnimations`.

## Archivos que se tocan
- `pubspec.yaml`, para declarar las fuentes en `assets/fonts/`.
- `core/theme/app_theme.dart`.
- Pantallas: `login`, `splash`, `inicio` y `detalle`.
- Widgets: `logo`, `producto_card`, `existencia_chip`, `etiqueta`, `estado_vacio` y `estado_error`.

## Verificación
- Correr `flutter analyze` y `flutter test` (las pruebas actuales deben seguir pasando).
- Revisar con las reglas de accesibilidad de `web-design-guidelines` trasladadas a Flutter.
- Capturas en un ancho de celular (390) y uno de tablet.

## Decisiones que quedan al implementador
- Valores finos de sombra y espaciado dentro de la escala.
- El diseño exacto del monograma del logo.
