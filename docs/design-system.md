# Design System — Poblex

> **Aviso de vigencia (2 noviembre 2026, tarde):** la identidad y sus activos están en [branding.md](branding.md). El tema compartido usa la paleta **morada** de la sección 2.2, no la terracota de las tablas de la sección 0 — ambas, coral (§0.1) y terracota (§0), son históricas, sustituidas el mismo 2 de noviembre de 2026. Ninguna de las dos debe usarse para implementar nuevos componentes. Los resultados de accesibilidad requieren verificación en dispositivos.

**Versión:** 1.0
**Fecha:** 9 de agosto de 2026
**Ámbito:** app móvil Flutter (iOS + Android). El backoffice reutiliza tokens de color y tipografía, pero tiene su propio catálogo de componentes de escritorio y no se cubre aquí.
**Documento hermano:** `docs/design-system-accessibility.md` — checklist de aceptación y tabla completa de contrastes.

---

## 0. Cambios respecto a CLAUDE.md

Esta sección existe para que `CLAUDE.md` se actualice. Hasta que se actualice, **manda este documento en materia de color**.

| Punto | CLAUDE.md (actual) | Design System (decisión nueva) | Motivo |
|---|---|---|---|
| Color primario | Verde Albufera `#1F6F5C` | **Naranja terracota, familia `#D97757`** | Decisión de producto del usuario. Cálido, cercano, se aleja del azul y del verde institucional genérico |
| Verde Albufera | Primario | **Acento secundario** (`accent`). Sigue vivo: confirmaciones, estados "resuelto", botón secundario | Aporta un segundo canal semántico útil (positivo / neutro) que el naranja solo no da |
| Terracota `#C75B39` | Acento | **Retirado del sistema.** Absorbido por la rampa primaria | Dos terracotas distintos a 0,5 de diferencia perceptual es ruido, no jerarquía |
| Uso del primario | Sin matices | **El primario se parte en tres roles con tonos distintos**: decorativo (`primary-500` = `#D97757`), gráfico (`primary-600`), y acción/texto (`primary-700`) | `#D97757` da **3,12:1 sobre blanco**. No cumple AA para texto ni para fondo de botón con texto blanco. Usarlo como color de acción sería incumplir el RD 1112/2018 |
| Colores de severidad | `#E8A33D` / `#D9772B` / `#B3261E` | **Se mantienen exactamente** como identidad de severidad, pero solo en chips sólidos. Se añaden tonos derivados oscuros/claros para texto, barras y modo oscuro | Los hexadecimales originales no alcanzan 4,5:1 sobre fondo claro (amarillo: 2,16:1). Necesitan derivados |
| Fondo hueso `#FAF7F2`, tinta `#1A1A1A` | Sin cambios | Sin cambios | Ya cumplían |
| Modo oscuro | No mencionado | **Añadido y verificado** | Android e iOS lo aplican por sistema. Sin definirlo, Material lo inventa y rompe los contrastes validados |

**Acción pendiente:** actualizar la tabla "Identidad visual" de `CLAUDE.md` y la sección 6 del PRD con la paleta de este documento.

## 0.1 Histórico: Rebranding sobre Stitch — "Modern Civic Coral" (12 agosto 2026)

**Histórico, sustituido por la paleta terracota.**

El usuario generó cuatro pantallas de referencia con Stitch (IA de diseño de Google) en
`design/stitch_poblex_civic_connect/`. Se adopta esa paleta y escala tipográfica como
nueva fuente de verdad, sustituyendo la terracota `#D97757` de la sección 0.

| Punto | Antes (§0) | Ahora (Stitch) | Motivo |
|---|---|---|---|
| Primario decorativo (`primary-500`) | `#D97757` | **`#FF7043`** (Stitch `primary-container`) | Token literal de Stitch. Sigue siendo decorativo: ~2,85:1 sobre blanco, nunca texto ni botón sólido |
| Primario gráfico (`primary-600`) | `#B6542B` | **`#641800`** (Stitch `on-primary-container`) | Token literal. 11,9:1 sobre `neutral-50` — sobra para el requisito de 3:1 |
| Primario acción (`primary-700`) | `#8A461E` | **`#AC3509`** (Stitch `primary`) | Token literal. 6,43:1 sobre blanco, 6,10:1 sobre `neutral-50` — verificado a mano, ambos ≥ 4,5:1 |
| Acento (`accent-500`) | `#1F6F5C` (Verde Albufera) | **`#006A61`** (Stitch `tertiary`) | Misma familia teal-verde, ahora tomada del esquema M3 de Stitch. 6,17:1 sobre `neutral-50` |
| Fondo (`neutral-50`) | `#FAF7F2` (hueso) | **`#F8F9FF`** (Stitch `background`/`surface`) | Cambio de temperatura de cálido a frío — decisión de Stitch, no ajuste nuestro |
| Tinta (`neutral-900`) | `#1A1A1A` | **`#0B1C30`** (Stitch `on-surface`) | Igual: contraste sigue siendo altísimo (~18:1) contra el nuevo fondo |
| Texto atenuado (`neutral-600`) | `#6A6058` | **`#59413A`** (Stitch `on-surface-variant`) | 8,90:1 sobre `neutral-50` — verificado a mano |
| Colores de severidad AEMET | `#E8A33D` / `#D9772B` / `#B3261E` | **Sin cambios, intencionadamente** | El propio mockup de Stitch para la pantalla de alertas reutiliza `primary-container` (el coral de marca) como color de la alerta naranja — exactamente la colisión marca/severidad que la regla R1 (§2.7) prohíbe. Se ignora ese punto del mockup; la paleta AEMET queda bloqueada como hasta ahora |
| Radios (`rounded-*`) | 4/8/12/16/24/999 | Sin cambios | La escala de Stitch (4/8/12/16/24/9999) ya coincidía número a número |
| Tipografía | Escala Atkinson Hyperlegible Next actual | Sin cambios de tamaño, se añade *letter-spacing* negativo en titulares grandes | Los tamaños ya coincidían casi paso a paso con la escala de Stitch (misma fuente, mismo generador M3). Solo hacía falta el tracking |

**Pendiente, no hecho en este cambio:** la tabla de contrastes exhaustiva de
`docs/design-system-accessibility.md` (~30 filas) se calculó a mano contra la paleta
`#D97757`/`#FAF7F2` antigua y **no está re-verificada fila a fila** contra los hexadecimales
nuevos. Los pares críticos de arriba sí están verificados con la fórmula de luminancia
relativa de WCAG 2.1. Antes de dar la tabla completa por buena hay que recalcularla —
idealmente con un script, no a mano, para no repetir el riesgo de error humano en un
documento que sirve de base a la declaración de accesibilidad del RD 1112/2018.

---

## 1. Filosofía

Poblex no es una app de tendencia. Es infraestructura de comunicación municipal que tiene que funcionar para una persona de 78 años, con presbicia, en un móvil de 2019, a pleno sol, en la calle, mientras suena una alerta de inundación.

De ahí cinco principios que ganan a cualquier consideración estética:

1. **La legibilidad gana siempre.** Ante la duda entre elegante y legible, legible. Texto grande, contrastado y con aire.
2. **Nada se comunica solo por color.** Color, forma, icono y palabra. Siempre los cuatro cuando hay riesgo. Un daltónico y una pantalla en escala de grises tienen que entender la misma alerta.
3. **La superficie no es el mensaje.** Los colores de marca decoran; los colores de severidad informan. No se mezclan nunca en el mismo componente.
4. **Sin sorpresas.** Cero patrones ocultos, cero gestos exclusivos, cero animación que retrase información. Todo lo que se puede hacer, se ve.
5. **Todo estado se pinta.** Cargando, vacío, error y éxito son diseños, no ausencias. Sin modo offline, un fallo de red es un caso frecuente, no una excepción.

---

## 2. Color

### 2.1 Por qué `#D97757` no puede ser el color de acción

`#D97757` sobre blanco da **3,12:1**. Sobre el fondo hueso `#FAF7F2` da **2,92:1**.

- Texto normal exige 4,5:1 → **no vale para texto**.
- Elemento gráfico o borde exige 3:1 → **falla incluso ahí sobre el fondo hueso**.
- Como fondo de botón con texto blanco encima: el mismo 3,12:1 → **no vale**.

Esto no es una opinión de diseño. Es la fórmula de luminancia relativa de WCAG 2.1, y el RD 1112/2018 la convierte en obligación legal para el sector público. Así que el naranja se queda, pero repartido en tres tonos con roles distintos y verificados.

### 2.2 Rampa primaria — Morado Poblex (2 nov 2026, sustituye a la terracota)

Derivada de H=272° (violeta), fija en todos los pasos. A diferencia del terracota, **no hace falta derivar el tono hacia otro matiz en los pasos oscuros**: el morado no comparte arco de tono con ninguna alerta AEMET (ver 2.7 actualizado), así que la rampa entera mantiene H=272° y solo varía luminosidad y saturación. Valores recalculados con script (fórmula de luminancia relativa WCAG 2.1 + CIEDE2000), no a mano — ver histórico de la rampa terracota al final de esta sección.

| Token | Hex | Contraste vs blanco | vs hueso | vs fondo oscuro | Uso |
|---|---|---|---|---|---|
| `primary-50` | `#F7F1FD` | 1,11 | 1,04 | 16,97 | Fondo de sección de marca sobre blanco |
| `primary-100` | `#ECDEF7` | 1,28 | 1,20 | 14,65 | Superficie de botón tonal, indicador de navegación activo |
| `primary-200` | `#DBC4EF` | 1,60 | 1,49 | 11,78 | Bordes suaves, separadores de marca |
| `primary-300` | `#C4A0E3` | 2,21 | 2,07 | **8,49** | **Color de acción en modo oscuro** |
| `primary-400` | `#AC7CD6` | 3,18 | 2,97 | 5,92 | Estado pulsado en modo oscuro |
| `primary-500` | `#955AC8` | 4,59 | 4,30 | 4,10 | **Solo decorativo.** Ilustración, cabecera, fondo de splash. Nunca texto, nunca borde con significado |
| `primary-600` | `#6F33A3` | **7,84** | **7,34** | 2,40 | **Gráfico con significado**: iconos decorativos que informan, trazos de gráficas, indicadores de progreso |
| `primary-700` | `#55257F` | **10,73** | **10,04** | 1,75 | **Color de acción en modo claro**: fondo de botón primario (texto blanco), texto de enlace, icono de navegación activo, borde de botón contorneado |
| `primary-800` | `#411E5F` | 13,33 | 12,47 | 1,41 | Estado pulsado en modo claro, anillo de foco |
| `primary-900` | `#2A163C` | 16,43 | 15,37 | 1,14 | Titulares de marca sobre fondo claro (uso raro) |

**Regla de oro:** `primary-500` es el color que ve el vecino como "el morado de Poblex", pero **nunca lleva información encima ni por sí mismo**. Es piel, no hueso.

Nótese que `primary-500` del morado da 4,59:1 sobre blanco — más alto que el 3,12:1 del terracota en el mismo paso. Esto no incumple nada (el paso decorativo no tiene mínimo, solo máximo de uso: nunca texto, nunca botón), pero sí significa que el morado-500 lee como un tono bastante más intenso que el terracota-500 equivalente; es una diferencia estética, documentada aquí para que nadie la confunda con un error de rampa.

#### Histórico: rampa terracota (9 ago → 2 nov 2026, tarde)

**Histórico, sustituido por la rampa morada de arriba.** Conservada por trazabilidad, igual que la rampa coral quedó histórica en §0.1.

| Token | Hex | Contraste vs blanco | vs hueso | vs fondo oscuro |
|---|---|---|---|---|
| `primary-500` | `#D97757` | 3,12 | 2,92 | 6,02 |
| `primary-600` | `#B6542B` | 4,89 | 4,58 | 3,84 |
| `primary-700` | `#8A461E` | 7,06 | 6,60 | 2,66 |

### 2.3 Rampa de acento — Verde Albufera

Relegado a acento, pero no eliminado: es el segundo canal semántico del sistema (positivo, resuelto, confirmado).

| Token | Hex | vs blanco | vs hueso | vs fondo oscuro | Uso |
|---|---|---|---|---|---|
| `accent-50` | `#EDF7F5` | 1,09 | 1,02 | 17,21 | Superficie de estado "resuelto" |
| `accent-100` | `#D5ECE7` | 1,24 | 1,16 | 15,21 | Chip tonal de éxito |
| `accent-200` | `#B3DBD2` | 1,50 | 1,41 | 12,52 | Bordes |
| `accent-300` | `#80C6B6` | 1,97 | 1,84 | **9,55** | Acción de acento en modo oscuro |
| `accent-400` | `#3AA68D` | 2,99 | 2,80 | 6,28 | Decorativo |
| `accent-500` | `#1F6F5C` | **6,02** | **5,64** | 3,12 | Botón secundario (texto blanco), icono de "resuelto", texto de éxito |
| `accent-600` | `#1C6958` | 6,54 | 6,12 | 2,88 | Estado pulsado |
| `accent-700` | `#145244` | 9,05 | 8,47 | 2,08 | Texto de acento sobre superficie de acento |
| `accent-800` | `#0E3A30` | 12,60 | 11,79 | 1,49 | Titulares de acento |

### 2.4 Neutrales cálidos

Neutrales con temperatura (tono 22-35°) para que convivan con el hueso sin que aparezcan grises azulados que ensucian la paleta.

| Token | Hex | vs hueso | vs blanco | Uso |
|---|---|---|---|---|
| `neutral-0` | `#FFFFFF` | 1,07 | 1,00 | Superficie de tarjeta |
| `neutral-50` | `#FAF7F2` | 1,00 | 1,07 | **Fondo de página (hueso)** |
| `neutral-100` | `#F1EEE9` | 1,08 | 1,16 | Superficie hundida, campo deshabilitado |
| `neutral-200` | `#E4DED8` | 1,25 | 1,33 | Skeleton base, fondo deshabilitado |
| `neutral-300` | `#CEC7C0` | 1,57 | 1,67 | Separador (decorativo) |
| `neutral-400` | `#A79E95` | 2,47 | 2,64 | Icono deshabilitado. **Nunca texto** |
| `neutral-500` | `#847A71` | 3,93 | 4,20 | **Borde de campo de formulario**, etiqueta deshabilitada |
| `neutral-600` | `#6A6058` | **5,73** | **6,13** | Texto atenuado (fechas, metadatos), icono de navegación inactivo |
| `neutral-700` | `#4F4640` | 8,61 | 9,20 | Texto secundario |
| `neutral-800` | `#332D29` | 12,69 | 13,56 | Titulares |
| `neutral-900` | `#1A1A1A` | 16,29 | 17,40 | **Texto de cuerpo (tinta)** |

### 2.5 Superficies de modo oscuro

No es una inversión del modo claro. El fondo es un negro cálido, no puro: reduce el halo (astigmatismo) y evita el *smearing* de los OLED antiguos.

| Token | Hex | Uso | Verificación |
|---|---|---|---|
| `dark-bg` | `#14110F` | Fondo de página | — |
| `dark-surface` | `#1F1A17` | Superficie de tarjeta | 1,09 vs fondo → **exige borde visible** |
| `dark-surface-high` | `#2A241F` | Hoja modal, menú, skeleton | 1,23 vs fondo |
| `dark-outline` | `#7C716A` | Borde de tarjeta y de campo | 3,96 vs fondo · 3,63 vs superficie · 3,23 vs elevada — **cumple 3:1 en las tres** |
| `dark-outline-subtle` | `#4D4642` | Separadores decorativos | Sin requisito |
| `dark-text` | `#F5F0E9` | Texto de cuerpo | 16,59 vs fondo |
| `dark-text-muted` | `#BFB8B0` | Texto atenuado | 9,58 vs fondo |

**Importante:** en modo oscuro las tarjetas se separan del fondo con **borde de 1 dp en `dark-outline`**, no con sombra. Una sombra sobre negro no se ve. Sin borde, la tarjeta y el fondo quedan a 1,09:1 y desaparece la estructura.

### 2.6 Severidad de alerta

Los tres hexadecimales de `CLAUDE.md` se conservan como **identidad de severidad**, pero solo aparecen en un sitio: el **chip sólido de severidad**. Todo lo demás usa derivados verificados.

| Nivel | Identidad (chip) | Tint (fondo banner claro) | Oscuro (barra + titular claro) | Tint oscuro | Barra/chip modo oscuro | Texto modo oscuro |
|---|---|---|---|---|---|---|
| Amarillo | `#E8A33D` | `#FCF3E3` | `#7D5003` | `#3C3120` | `#E8AB30` | `#F6C96F` |
| Naranja | `#D9772B` | `#FCEBDE` | `#862F04` | `#3A271D` | `#EC8B3C` | `#F49E57` |
| Rojo | `#B3261E` | `#FCE5E3` | `#92161A` | `#3D1C1A` | `#EB5847` | `#F88277` |

Contrastes clave (tabla completa en el documento de accesibilidad):

| Pareja | Ratio | Mínimo |
|---|---|---|
| Tinta sobre chip amarillo `#E8A33D` | 8,07:1 | 4,5 |
| Tinta sobre chip naranja `#D9772B` | 5,49:1 | 4,5 |
| **Blanco** sobre chip rojo `#B3261E` | 6,54:1 | 4,5 |
| Titular `#7D5003` sobre banner amarillo | 6,31:1 | 4,5 |
| Titular `#862F04` sobre banner naranja | 7,46:1 | 4,5 |
| Titular `#92161A` sobre banner rojo | 7,42:1 | 4,5 |
| Barra roja `#92161A` sobre página hueso | 8,36:1 | 3,0 |

Fíjate en el detalle del rojo: **es el único de los tres que invierte el texto del chip** (blanco en vez de tinta, porque la tinta sobre `#B3261E` da 2,66:1 y no pasa). Esa inversión no es un apaño: es un canal más de diferenciación que el vecino percibe sin saber explicarlo.

### 2.7 El problema serio (histórico) y por qué el morado ya no lo tiene

**Dejo el diagnóstico antes que la solución, porque el diagnóstico es lo importante** — y porque, con el morado, el diagnóstico cambia de conclusión aunque las cinco reglas de abajo se mantengan.

Con el terracota, `#D97757` (marca) y `#D9772B` (alerta naranja de AEMET) tenían una diferencia perceptual **ΔE00 = 10,5**. Eso es "distinguibles si los pones uno al lado del otro", pero **no** "distinguibles de un vistazo, en la calle, con sol, por una persona mayor". En un sistema que avisa de inundaciones en la Ribera Baixa, confundir marca con alerta no era un fallo estético: era un fallo de seguridad.

Matriz de separación perceptual histórica con terracota (ΔE00, CIEDE2000; por debajo de 10 la confusión es plausible en condiciones reales):

| Token de marca (terracota, histórico) | amarillo id | naranja id | rojo id | amarillo osc. | naranja osc. | rojo osc. |
|---|---|---|---|---|---|---|
| `primary-500` (decorativo) | 21,7 | **10,5** | 22,0 | 28,2 | 27,7 | 28,9 |
| `primary-600` (gráfico) | 27,8 | 14,2 | 11,2 | 17,9 | 13,6 | 17,1 |
| `primary-700` (acción claro) | 35,4 | 23,3 | 13,0 | 11,1 | **6,2** | 14,1 |
| `primary-300` (acción oscuro) | 19,3 | 18,9 | 35,5 | 38,2 | 43,3 | 44,8 |

Había dos colisiones reales: `primary-500`↔naranja de alerta (10,5) y `primary-700`↔naranja oscuro de alerta (6,2). Con el terracota, el tono no se podía arreglar solo con tono: marca y severidad vivían en el mismo arco cálido por definición del encargo.

**Con el morado (H=272°), la matriz es otra:**

| Token de marca (morado, vigente) | amarillo id | naranja id | rojo id | amarillo osc. | naranja osc. | rojo osc. |
|---|---|---|---|---|---|---|
| `primary-500` (decorativo) | 58,7 | 48,8 | 38,3 | 62,9 | 51,1 | 37,6 |
| `primary-600` (gráfico) | 66,6 | 54,2 | 37,6 | 70,7 | 58,6 | 42,8 |
| `primary-700` (acción claro) | 70,4 | 55,8 | 37,7 | 74,6 | 61,5 | 45,4 |
| `primary-300` (acción oscuro) | 48,1 | 43,1 | 44,9 | 51,4 | 42,9 | 35,4 |

Mínimo de toda la matriz: **35,4** — muy por encima de cualquier par terracota, y a años luz del umbral de 10 que definía una colisión plausible. El violeta no comparte arco de tono con ningún color de severidad AEMET (los tres viven entre 35° y 60° de tono; el morado está en 272°), así que **no existe el problema que motivó esta sección con el terracota**. Aun así, las cinco reglas de abajo se mantienen sin cambios: no son un parche específico del terracota, son la política general de que marca y severidad no comparten nunca contenedor, independientemente de lo lejos que estén en el círculo de tono hoy — una paleta de marca se puede volver a tocar en el futuro, la separación estructural no debería depender de que alguien recuerde recalcular un ΔE00 cada vez.

**R1 — Separación de dominios (la regla que manda).**
Ningún color de marca aparece dentro de un componente de alerta. Ningún color de severidad aparece fuera de un componente de alerta. No hay excepciones, ni siquiera "un detallito". Un banner de alerta y un botón primario **no comparten nunca contenedor ni contexto**, así que la comparación directa que dispararía la confusión no llega a producirse.

**R2 — Relleno sólido cálido = severidad. Contorno = marca.**
Los chips de categoría de noticias son **contorneados** (fondo transparente, borde y texto en `primary-700`). Los chips de severidad son **sólidos** (relleno en el color de identidad + borde en el tono oscuro). Misma forma, tratamiento opuesto. Es una diferencia que se lee en 100 ms.

**R3 — Redundancia obligatoria en severidad: cuatro canales, no uno.**

| Nivel | Color | Icono (silueta distinta) | Palabra (siempre visible) | Barra lateral |
|---|---|---|---|---|
| Amarillo | `#E8A33D` | Triángulo **contorneado** | "Aviso amarillo · Nivel 1" | 4 dp |
| Naranja | `#D9772B` | Triángulo **relleno** | "Aviso naranja · Nivel 2" | 8 dp |
| Rojo | `#B3261E` | **Octógono** relleno | "Aviso rojo · Nivel 3" | 12 dp |

La palabra y el número no son opcionales ni se ocultan al truncar. El icono cambia de **silueta**, no solo de color: se distingue en escala de grises y con cualquier daltonismo.

**R4 — Orden de luminancia monótono.**
Los tres colores de identidad tienen luminancias claramente escalonadas (9,74 → 6,62 → 3,21 frente a negro). En escala de grises siguen ordenados de menos a más grave. Los tonos oscuros de barra sí quedan próximos entre naranja y rojo (2,42 vs 2,35), y **por eso la barra cambia de grosor**: el canal geométrico cubre lo que el canal de luminancia no cubre.

**R5 — El naranja de marca nunca es una banda horizontal a ancho completo.**
Esa geometría (banda ancha con icono a la izquierda) queda reservada a las alertas. Las superficies de marca son tarjetas con radio 16 y las alertas tienen radio 8 y barra a tope izquierdo. Forma como canal adicional.

**Lo que NO he hecho, y por qué:** no he movido los hexadecimales de severidad. Son los colores de AEMET, el vecino ya los asocia al parte meteorológico de la tele y el ayuntamiento los reconoce. Cambiarlos por comodidad de marca sería optimizar lo accesorio rompiendo lo importante.

### 2.8 Roles semánticos

Los widgets no tocan la rampa. Consumen roles.

| Rol | Modo claro | Modo oscuro |
|---|---|---|
| `background` | `neutral-50` | `dark-bg` |
| `surface` | `neutral-0` | `dark-surface` |
| `surfaceHigh` | `neutral-0` + sombra 2 | `dark-surface-high` |
| `onSurface` | `neutral-900` | `dark-text` |
| `onSurfaceMuted` | `neutral-600` | `dark-text-muted` |
| `primary` (acción) | `primary-700` | `primary-300` |
| `onPrimary` | `neutral-0` | `dark-bg` |
| `primaryPressed` | `primary-800` | `primary-400` |
| `primaryContainer` | `primary-100` | `dark-surface-high` |
| `onPrimaryContainer` | `primary-700` | `primary-300` |
| `brandDecorative` | `primary-500` | `primary-500` |
| `brandGraphic` | `primary-600` | `primary-300` |
| `secondary` (acento) | `accent-500` | `accent-300` |
| `outline` | `neutral-500` | `dark-outline` |
| `outlineVariant` | `neutral-300` | `dark-outline-subtle` |
| `error` | `#92161A` | `#F88277` |
| `focusRing` | `primary-800` | `primary-300` |
| `skeletonBase` | `neutral-200` | `dark-surface-high` |
| `skeletonHighlight` | `neutral-100` | `#37302A` |

### 2.9 Override de marca por municipio

`municipalities.primary_color` permite a cada ayuntamiento poner su color. El sistema tiene que aceptarlo **sin que nadie pueda romper el contraste desde el backoffice**. El mecanismo:

1. **El color del municipio es una semilla, no un token.** Nunca se pinta tal cual. Entra en `BrandPalette.fromSeed(seed)`.
2. **Derivación con anclaje de luminosidad.** Se convierte a HSL, se conservan tono y saturación, y se generan los pasos con las **mismas luminosidades** que la rampa Poblex. El perfil de luminancia de la rampa, que es lo que garantiza el contraste, se mantiene sea cual sea el tono.
3. **Bucle de ajuste (el que da la garantía dura).** El tono de acción se oscurece en pasos de 1 % hasta cumplir **a la vez** ≥ 4,5:1 contra el fondo de página y ≥ 4,5:1 contra el blanco (para que el texto blanco del botón funcione). En modo oscuro, el mismo bucle aclarando hasta ≥ 4,5:1 contra `dark-bg`. Es determinista: si el color entra, sale un token que cumple. No hay entrada válida que produzca una salida que incumpla.
4. **El decorativo sí es libre.** El paso 500 se toma de la semilla sin ajustar, porque no lleva información encima. Ahí es donde el ayuntamiento reconoce "su" color.
5. **La severidad es inmune.** `BrandPalette` no toca ningún token de alerta. El municipio puede poner el color que quiera: las alertas siguen siendo amarillo, naranja y rojo de AEMET. Esto es lo que hace que la regla R1 siga sosteniéndose con marca ajena.
6. **Aviso en el backoffice, no bloqueo.** Si la semilla cae en la banda de tono 0-45° (arco de las alertas), el backoffice muestra un aviso al gestor explicando que su color se parece al de los avisos meteorológicos. No se bloquea: la seguridad la garantizan las reglas estructurales, no el tono.

Simulación del bucle con semillas reales (calculada, no estimada):

| Semilla | Acción modo claro | vs fondo | Acción modo oscuro | vs fondo |
|---|---|---|---|---|
| `#D97757` (Poblex) | `#BD4F2B` | 4,55:1 | `#D0572F` | 4,55:1 |
| `#1F6F5C` (verde) | `#237E68` | 4,62:1 | `#2D9F84` | 5,73:1 |
| `#FFD400` (amarillo saturado) | `#877000` | 4,52:1 | `#CCAA00` | 8,34:1 |
| `#0057B7` (azul institucional) | `#006DE6` | 4,54:1 | `#0078FC` | 4,56:1 |
| `#B3261E` (rojo, caso peor) | `#D82E24` | 4,53:1 | `#DF473F` | 4,58:1 |
| `#7B2D8E` (morado) | `#AA43C3` | 4,57:1 | `#B255C9` | 4,51:1 |

Incluso un amarillo puro, que es el caso más hostil, sale como token válido. La paleta Poblex por defecto **no** pasa por el bucle: sus tokens están afinados a mano y dan 7,06:1, muy por encima del mínimo que produce la derivación automática.

---

## 3. Tipografía

**Familia: Atkinson Hyperlegible.** Diseñada por el Braille Institute para baja visión, con formas de letra deliberadamente diferenciadas donde otras tipografías confunden (`I` / `l` / `1`, `O` / `0`, `rn` / `m`). Licencia libre. Es la fuente por defecto y no hay fuente secundaria: una segunda familia solo añadiría carga y riesgo de fallback.

**Base 18 sp**, no 16. Es una decisión de producto para un público mayoritariamente mayor, y arrastra toda la escala hacia arriba.

| Estilo | Tamaño | Altura de línea | Peso | Uso |
|---|---|---|---|---|
| `displaySmall` | 36 sp | 1,22 | 700 | Nombre del municipio en el selector, splash |
| `headlineLarge` | 32 sp | 1,25 | 700 | Título de pantalla de detalle |
| `headlineMedium` | 28 sp | 1,29 | 700 | Titular de noticia en detalle |
| `headlineSmall` | 24 sp | 1,33 | 700 | Cabecera de sección |
| `titleLarge` | 22 sp | 1,36 | 700 | Título de tarjeta de noticia, título de alerta |
| `titleMedium` | 20 sp | 1,40 | 600 | Título de tarjeta de evento, encabezado de lista |
| `titleSmall` | 18 sp | 1,44 | 600 | Subtítulo, etiqueta de campo de formulario |
| `bodyLarge` | **18 sp** | 1,56 | 400 | **Cuerpo por defecto.** Texto de noticia, descripción, cuerpo de alerta |
| `bodyMedium` | **18 sp** | 1,56 | 400 | Texto por defecto de Material y texto secundario dentro de tarjeta |
| `bodySmall` | 15 sp | 1,47 | 400 | Mínimo absoluto de texto corrido. Solo pies de foto y textos legales |
| `labelLarge` | 18 sp | 1,33 | 600 | **Etiqueta de botón** |
| `labelMedium` | 16 sp | 1,25 | 600 | Etiqueta de chip, pestaña |
| `labelSmall` | 14 sp | 1,43 | 600 | Metadato (fecha, contador). **Nunca texto corrido** |

### Reglas de tipografía

- **`height` siempre como multiplicador**, jamás como píxeles fijos. Con `textScaler` al 200 % la altura de línea tiene que crecer con el tamaño.
- **Prohibido `SizedBox` de altura fija alrededor de texto.** Contenedores que crecen: `IntrinsicHeight`, `Wrap`, `Flexible`, o simplemente altura nula.
- **Prohibido `maxLines` sin `overflow` y sin acceso al texto completo.** Si un titular se trunca en la tarjeta, el detalle lo muestra entero. Nunca se pierde información por truncado.
- **`textScaler` no se limita por arriba hasta 2,0.** Si una pantalla se rompe al 200 %, se arregla la pantalla, no se capa el escalado. Por encima de 2,0 sí se puede aplicar `clamp` a 2,0 para no dejar la interfaz inservible.
- **Sin mayúsculas forzadas.** `TEXTO EN CAJA ALTA` reduce la velocidad de lectura y los lectores de pantalla lo deletrean. Los botones llevan capitalización de frase.
- **Sin justificado.** `TextAlign.start` siempre; el justificado abre ríos que dificultan la lectura con dislexia.
- **Ancho de columna ≤ 640 dp** en tabletas, para no pasar de ~75 caracteres por línea.

### Bilingüismo y longitud

El valenciano es de media **un 10-20 % más largo** que el castellano, y en etiquetas de interfaz llega a más ("Ajustes" → "Configuració"). Reglas:

- **Ningún componente con ancho fijo dimensionado sobre el texto en castellano.** Botones, chips y pestañas se dimensionan por contenido con mínimo 48 dp de alto.
- **Todo botón con etiqueta larga se envuelve, no se trunca.** Botones de ancho completo en formularios y acciones principales.
- **La barra de navegación inferior usa etiquetas de una palabra en ambos idiomas.** Si en valenciano no cabe, se cambia la palabra, no el tamaño de letra.
- **Regla de prueba:** toda pantalla se revisa con el idioma valenciano y `textScaler` a 2,0 **a la vez**. Es el caso peor y es el que hay que soportar.
- **Fallback de idioma:** si falta la traducción del contenido, se muestra el idioma disponible con un chip discreto (`labelSmall`, `neutral-600`) indicando el idioma original. Nunca un hueco, nunca "null".

---

## 4. Espaciado y layout

Escala de base 4, con nombres, no números sueltos.

| Token | Valor | Uso |
|---|---|---|
| `xxs` | 4 dp | Separación icono-texto dentro de un chip |
| `xs` | 8 dp | Separación entre elementos muy relacionados |
| `sm` | 12 dp | Espaciado interno vertical de campos |
| `md` | 16 dp | **Margen de pantalla por defecto**, espaciado interno de tarjeta |
| `lg` | 20 dp | Espaciado interno de tarjeta destacada |
| `xl` | 24 dp | Separación entre bloques |
| `xxl` | 32 dp | Separación entre secciones |
| `xxxl` | 40 dp | Espacio antes del pie de página |
| `huge` | 48 dp | Espaciado de estado vacío |
| `giant` | 64 dp | Espaciado de pantalla de bienvenida |

**Tamaños obligatorios:**

- Área táctil mínima: **48 × 48 dp**. Incluye la parte transparente. Un icono de 24 dp lleva 12 dp de relleno por lado.
- Área táctil cómoda (acciones principales): **56 dp** de alto.
- Separación mínima entre dos áreas táctiles: **8 dp**, para evitar pulsaciones erróneas con temblor.
- Ancho máximo de contenido de lectura: **640 dp**.
- Altura de la barra de navegación inferior: **80 dp** (permite icono 28 + etiqueta 14 con escalado).

---

## 5. Radios y elevación

| Token | Valor | Uso |
|---|---|---|
| `radius-xs` | 4 dp | Skeleton de línea de texto |
| `radius-sm` | 8 dp | **Banner de alerta**, campo de formulario |
| `radius-md` | 12 dp | Botones |
| `radius-lg` | 16 dp | **Tarjetas** (noticia, evento, encuesta) |
| `radius-xl` | 24 dp | Hoja modal inferior |
| `radius-pill` | 999 dp | Chips, indicador de navegación |

El radio es un canal semántico: **8 dp = información de severidad, 16 dp = contenido**. No se intercambian.

Elevación: se usa lo mínimo. Las sombras en pantallas de mucho texto ensucian y no aportan.

| Nivel | Modo claro | Modo oscuro |
|---|---|---|
| 0 | Sin sombra | Sin sombra |
| 1 | Sombra `y=1, blur=3, #1A1A1A al 8 %` — tarjetas | **Borde 1 dp `dark-outline`**, sin sombra |
| 2 | Sombra `y=4, blur=12, #1A1A1A al 12 %` — hoja modal, menú | `dark-surface-high` + borde 1 dp |
| 3 | Sombra `y=8, blur=24, #1A1A1A al 16 %` — diálogo | `dark-surface-high` + borde 1 dp |

---

## 6. Iconografía

- **Material Symbols Rounded**, relleno variable. Coherente con Flutter y sin dependencia extra.
- Tamaños: 20 dp (en línea con texto), **24 dp por defecto**, 28 dp (navegación inferior), 32 dp (estado vacío), 48 dp (ilustración de error).
- **Grosor de trazo mínimo 2 dp.** Los iconos finos desaparecen para quien tiene poca visión.
- **Nunca un icono solo como único indicador de una acción.** Todo icono accionable lleva etiqueta de texto visible o, cuando no cabe, `tooltip` + `Semantics.label` descriptivo. "Botón" no es una etiqueta; "Añadir recordatorio del evento" sí.
- Iconos de severidad: **silueta distinta por nivel** (ver R3), nunca el mismo icono en tres colores.
- Los iconos decorativos van con `ExcludeSemantics`, para que el lector de pantalla no los enumere.

---

## 7. Motion

Poblex tiene poca animación a propósito. La animación retrasa la información y marea a parte del público.

| Token | Duración | Curva | Uso |
|---|---|---|---|
| `instant` | 0 ms | — | Cambio de estado de selección |
| `fast` | 120 ms | `easeOut` | Pulsación, foco, ripple |
| `normal` | 200 ms | `easeOutCubic` | Aparición de tarjeta, expansión |
| `slow` | 320 ms | `easeOutCubic` | Transición de pantalla |

**Reglas:**

- **Respetar reduce-motion sin excepción.** Si `MediaQuery.disableAnimationsOf(context)` es `true`, todas las duraciones pasan a `Duration.zero` y las transiciones de página a `FadeUpwardsPageTransitionsBuilder` sin desplazamiento. El sistema expone un único punto (`AppMotion.duration(context, ...)`) y ningún widget escribe una duración a mano.
- **Nada parpadea.** Prohibido cualquier destello entre 2 y 55 Hz (WCAG 2.3.1). El skeleton de carga usa un barrido suave de 1200 ms, y con reduce-motion se queda estático.
- **La animación nunca retiene contenido.** El contenido se pinta y luego se anima la opacidad, no al revés.
- Sin *parallax*, sin rebote, sin animaciones de entrada escalonadas en listas.

---

## 8. Catálogo de componentes

Cada componente lista: anatomía, tokens, estados y reglas de accesibilidad. Todos con `Semantics` explícito, todos con área táctil ≥ 48 dp, todos probados en valenciano al 200 %.

### 8.1 Botones

Cuatro variantes, jerarquía estricta. **Una sola acción primaria por pantalla.**

| Variante | Relleno | Texto | Borde | Uso |
|---|---|---|---|---|
| **Primario** (`FilledButton`) | `primary-700` / oscuro: `primary-300` | blanco / oscuro: `dark-bg` | — | Acción principal: "Enviar incidencia", "Votar" |
| **Secundario** (`FilledButton.tonal`) | `primary-100` / oscuro: `dark-surface-high` | `primary-700` / `primary-300` | — | Acción alternativa: "Añadir recordatorio" |
| **Contorneado** (`OutlinedButton`) | transparente | `primary-700` / `primary-300` | 2 dp mismo color | Acción destructiva suave, "Cancelar" |
| **De texto** (`TextButton`) | transparente | `primary-700` / `primary-300` | — | Terciaria, dentro de tarjeta: "Ver más" |

- Alto mínimo **56 dp** para las acciones principales, 48 dp para el resto.
- Radio `md` (12 dp). Etiqueta `labelLarge` (18 sp, peso 600), capitalización de frase.
- **Ancho completo en formularios y en la parte inferior de las pantallas de detalle.** En valenciano, una etiqueta larga envuelve a dos líneas y el botón crece.
- Estados: reposo, **foco** (anillo de 3 dp en `focusRing` con separación de 2 dp), pulsado (`primary-800` / `primary-400`), cargando (indicador de 20 dp sustituyendo al icono, etiqueta intacta, botón deshabilitado, `Semantics.label` pasa a "Enviando…"), deshabilitado (`neutral-200` con etiqueta `neutral-500`, 3,15:1).
- **Un botón deshabilitado siempre explica por qué**, con un texto debajo. Un botón muerto sin explicación es un callejón sin salida.

### 8.2 Campos de formulario

- Anatomía: etiqueta encima (`titleSmall`, **nunca placeholder como etiqueta**) → campo → texto de ayuda o error debajo.
- Borde 2 dp `neutral-500` (4,20:1 sobre blanco); en foco 2 dp `primary-700` + anillo; en error 2 dp `error` (`#92161A`).
- Alto mínimo 56 dp, radio `sm`, texto `bodyLarge` (18 sp).
- **El error no se comunica solo por color:** icono de error + texto explícito debajo, en `error` (8,36:1 sobre hueso). El texto dice qué falla y cómo arreglarlo, no "campo inválido".
- El error se anuncia por lector de pantalla con región `liveRegion`.
- Campo obligatorio: la palabra "obligatorio" en la etiqueta, no un asterisco suelto.
- Contador de caracteres visible cuando hay límite, con aviso al llegar al 90 %.

### 8.3 Tarjeta de noticia

**Imagen de contenido, no de categoría** (ver nota en `docs/branding.md` "dos niveles de imagen"): si la noticia tiene foto, es la del municipio, subida por el gestor. Sin foto real, la tarjeta no lleva imagen — nunca una foto de stock haciendo de sustituta. Esto es distinto del mosaico de categoría de Inicio (§8.14), que sí usa fotografía CC0/dominio público porque no representa a ningún municipio en concreto.

Anatomía: imagen (16:9, opcional) → chip de categoría (contorneado) → titular (`titleLarge`, máx. 3 líneas) → resumen (`bodyMedium`, máx. 2 líneas) → fecha (`labelSmall`, `neutral-600`) + indicador de adjunto.

- Superficie `neutral-0` / `dark-surface`, radio `lg`, espaciado interno `md`, elevación 1 (borde en modo oscuro).
- **Destacada** (`pinned`): borde izquierdo de 4 dp en `primary-600` + icono de chincheta + texto "Destacada". Nunca solo el borde de color.
- Toda la tarjeta es táctil (≥ 48 dp de alto sobrado) con `Semantics` que agrupa: "Noticia. {titular}. {categoría}. Publicada el {fecha}. Con {n} adjuntos."
- La imagen lleva `Semantics.label` con su descripción; si no la hay, `ExcludeSemantics` y no se anuncia como "imagen".
- Fallback de idioma: chip `labelSmall` "en castellano" / "en valencià" cuando el contenido no está en el idioma activo.

### 8.4 Tarjeta de evento

Anatomía: bloque de fecha a la izquierda (día en `headlineSmall`, mes en `labelMedium`, sobre `accent-50` / superficie elevada) → título (`titleMedium`) → hora y lugar con iconos → botón de recordatorio.

- **El botón de recordatorio es un botón visible**, no un icono suelto ni un gesto. Estados: "Avisarme" / "Aviso activado" con icono de campana rellena + cambio de texto.
- Evento pasado: opacidad no; **etiqueta "Finalizado"** en un chip `neutral-200`. La opacidad rebajada rompe el contraste.
- Semántica: "Evento. {título}. {día} de {mes}, {hora}. En {lugar}. {Recordatorio activado o no}."

### 8.5 Banner de alerta por severidad

El componente más importante del sistema. Anatomía fija:

```
┌─┬──────────────────────────────────────────┐
│ │ [icono]  AVISO NARANJA · NIVEL 2         │   ← chip sólido, siempre visible
│ │                                          │
│ │ Lluvias intensas en la Ribera Baixa      │   ← titleLarge, color oscuro de severidad
│ │                                          │
│ │ Cuerpo del aviso en bodyLarge, tinta     │   ← ink sobre tint: ≥ 14,47:1
│ │ sobre el tint de severidad.              │
│ │                                          │
│ │ Vigencia: 9 ago 14:00 – 10 ago 08:00     │   ← labelSmall
│ │ Fuente: AEMET                            │
│ │ [ Ver detalle ]  [ Escuchar aviso ]      │   ← botones visibles
└─┴──────────────────────────────────────────┘
 ↑ barra lateral: 4 / 8 / 12 dp según nivel
```

- Radio `sm` (8 dp) — distinto de las tarjetas de contenido a propósito (R5).
- Fondo: tint de severidad. Texto de cuerpo en tinta (14,47-15,80:1). Titular en el tono oscuro de severidad (6,31-7,46:1).
- Chip de severidad **sólido** con el color de identidad, borde 1,5 dp en el tono oscuro (el borde aporta el 3:1 de contorno que el amarillo por sí solo no da: `#E8A33D` sobre blanco es 2,16:1).
- **Alerta roja:** además, `liveRegion: true` con `assertive`, para que TalkBack y VoiceOver la lean al entrar en la pantalla sin que el usuario la busque. Botón "Escuchar aviso" que lee el cuerpo en voz alta (requisito del PRD §5).
- **Ninguna alerta se descarta deslizando.** Si es descartable, botón "Entendido" visible.
- En modo oscuro: tint oscuro de severidad, texto `dark-text` (11,21-13,43:1), titular en el tono claro (6,13-8,17:1), barra en el tono de barra (5,39-9,22:1 sobre el fondo).

### 8.6 Chip de categoría

- **Contorneado** (R2): fondo transparente, borde 1,5 dp `primary-700`, texto `labelMedium` en `primary-700` (7,06:1).
- Seleccionado: relleno `primary-100`, borde `primary-700`, **icono de comprobación**. La selección no se comunica solo por relleno.
- Alto 40 dp con área táctil de 48 dp (relleno vertical transparente).
- En una fila de filtros: `Wrap`, nunca desplazamiento horizontal con contenido oculto. El valenciano necesita más ancho y no puede quedar fuera de pantalla.
- Semántica: `Semantics(button: true, selected: ..., label: "Filtrar por {categoría}")`.

### 8.7 Estado vacío

Anatomía: icono 48 dp `neutral-400` → título (`titleMedium`) → explicación (`bodyMedium`, `neutral-600`) → acción si la hay.

- El texto dice **qué falta y qué se puede hacer**: "Todavía no hay eventos publicados. El ayuntamiento los irá añadiendo." No "Sin resultados".
- Distinguir vacío real de vacío por filtro: si hay filtros activos, ofrecer "Quitar filtros" como botón.
- Nunca ilustración compleja: peso y ruido visual sin aportar.

### 8.8 Estado de error con reintentar

Obligatorio en toda pantalla que carga datos. Sin modo offline, este componente se ve mucho.

Anatomía: icono 48 dp en `error` → título (`titleMedium`) → causa en lenguaje llano (`bodyLarge`) → **botón "Reintentar" primario, ancho completo, 56 dp** → acción secundaria si procede.

- Mensajes por tipo de error, en ambos idiomas, sin jerga ni códigos:
  - Red: "No hay conexión a internet. Comprueba los datos móviles o el wifi y vuelve a intentarlo."
  - Servidor: "El servicio no responde ahora mismo. Inténtalo de nuevo en unos minutos."
  - No encontrado: "Este contenido ya no está disponible."
- **Nunca un spinner infinito y nunca una pantalla en blanco.** Tiempo máximo antes de mostrar error: 15 s.
- Caso especial de alertas: si falla la carga, se **mantiene visible el histórico ya cargado** y el error aparece como banda superior con reintentar, sin vaciar la lista.
- Semántica: `liveRegion: true` para que el error se anuncie al aparecer. El botón declara `Semantics.label` "Reintentar cargar las noticias".

### 8.9 Skeleton de carga

- Bloques `neutral-200` / `dark-surface-high`, radio `xs` para líneas de texto y `lg` para bloques de imagen, con la **misma geometría que el contenido real** para que no salte al cargar.
- Barrido de 1200 ms de `skeletonBase` a `skeletonHighlight`. **Con reduce-motion se queda estático.**
- `Semantics(label: "Cargando noticias", liveRegion: true)` en el contenedor, y `ExcludeSemantics` en cada bloque. Un lector de pantalla no debe enumerar seis rectángulos.
- Se usa solo en la primera carga. En una recarga se mantiene el contenido anterior con un indicador de progreso arriba.

### 8.10 Barra de navegación inferior

Cinco destinos máximo: Inicio, Noticias, Eventos, Alertas, Más. Es el nivel 1 de la jerarquía; **desde cualquiera de ellos se llega al detalle en un solo paso**, cumpliendo el máximo de dos niveles.

- Alto 80 dp. Cada destino: icono 28 dp + etiqueta `labelSmall` **siempre visible** (nunca solo el activo).
- Activo: icono relleno + `primary-700` (7,06:1) + indicador píldora `primary-100`. Inactivo: icono contorneado + `neutral-600` (6,13:1).
- La diferencia activo/inactivo la marcan **relleno del icono + color + indicador**: tres canales.
- **Insignia de alertas:** punto `#92161A` con el número de alertas activas y `Semantics` "Alertas, 2 avisos activos". El punto sin número no se ve bien y no dice nada.
- En modo oscuro, superficie `dark-surface` con borde superior de 1 dp `dark-outline`.

### 8.11 Selector de idioma

- Vive en Ajustes y en el primer arranque. **Dos opciones grandes en lista, no un desplegable**: "Castellano" y "Valencià", cada una escrita en su propio idioma.
- Fila de 64 dp con radio de opción a la izquierda, nombre del idioma en `bodyLarge` y comprobación a la derecha en la seleccionada.
- Al cambiar: la interfaz se recarga inmediatamente y la app **se desuscribe de los topics de FCM del idioma anterior y se suscribe a los del nuevo** (`m_{id}_news_es` → `m_{id}_news_va`, y equivalentes). El cambio muestra confirmación breve.
- Semántica: `Semantics(inMutuallyExclusiveGroup: true, selected: ..., label: "Valencià")`.

### 8.12 Selector de municipio

- Primera pantalla del primer arranque y accesible desde Ajustes. Lista de municipios con logo 40 dp, nombre en `titleMedium` y provincia en `bodySmall`.
- Buscador arriba si hay más de 10 municipios, con campo de 56 dp.
- **Cambiar de municipio muestra confirmación explícita**, porque implica dejar de recibir los avisos del anterior: "Vas a seguir a {municipio}. Dejarás de recibir avisos de {anterior}." con "Cancelar" y "Cambiar".
- Al confirmar: `PATCH /v1/devices/{id}`, **desuscripción de todos los topics del municipio anterior** y suscripción a los nuevos, en ese orden. Si falla, no se cambia nada y se muestra el estado de error con reintentar.
- El logo del municipio lleva `Semantics.label` "Escudo de {municipio}", nunca "logo".

### 8.13 Encuesta

- Pregunta en `titleLarge`, opciones como filas táctiles de 56 dp con radio de opción, botón "Votar" primario de ancho completo.
- **Etiqueta "Consulta no vinculante"** siempre visible como chip `neutral-200` junto a la pregunta. Es un requisito legal del PRD §9.5, no un detalle.
- Ya votada: barras de resultado con porcentaje **en número además de en longitud de barra**, y la opción propia marcada con comprobación y texto "Tu voto".
- Cerrada: chip "Cerrada" y botón deshabilitado con explicación debajo.

### 8.14 Mosaico de categoría (grid de Inicio)

**Nuevo (2 nov 2026).** Sustituye a la fila de texto plano que usaba Inicio hasta hoy ("solo texto + flecha, para no parecer un catálogo de iconos" — decisión anterior, ver historial de `home_screen.dart`). El mosaico ahora es imagen-primero: la foto identifica la categoría de un vistazo, igual que pide el PRD para una app visual y moderna.

Anatomía:

```
┌───────────────────┐
│                    │
│   [foto 4:3,       │  ← CC0/dominio público, nunca contenido de
│    BoxFit.cover]   │    municipio (ver §8.3 y branding.md)
│                    │
├────────────────────┤  ← degradado: la foto funde con la barra
│ Noticias           │  ← barra sólida, SIEMPRE el mismo color
└────────────────────┘    (`AppPalette.darkBackground`, 16,59:1 con
                           texto blanco) en claro Y oscuro — el texto
                           nunca se apoya solo en el contraste de la
                           foto, que no controlamos
```

- La franja de texto es una **barra sólida de color fijo**, no texto superpuesto directamente sobre la foto sin más: así el contraste de la etiqueta no depende del contenido de cada foto concreta, que cambia. El degradado entre foto y barra es puramente estético (continuidad visual), no es lo que garantiza la legibilidad.
- Igual que cualquier icono (§6), **la foto nunca es el único indicador**: la etiqueta de texto siempre está visible en la barra, y `Semantics(button: true, label: ..., hint: ...)` lleva el mismo texto que antes llevaba la fila de solo-texto. La foto es decorativa a efectos de accesibilidad — `ExcludeSemantics` sobre la imagen.
- Proporción 4:3 fija para la foto; la barra de texto **no** tiene altura fija, crece con el contenido — necesario para que una etiqueta valenciana al 200 % de escala no se recorte (A-12).
- Tarjeta de categoría destacada (Incidencias, Farmacias): mismo criterio pero en fila horizontal, imagen a la izquierda ocupando todo el alto de la tarjeta, texto (título + descripción) a la derecha sobre la superficie normal de la tarjeta — ahí no hace falta barra de contraste fija porque el texto nunca se apoya sobre la foto.
- Las nueve fotos (siete tiles + dos tarjetas destacadas) viven en `app/assets/images/home_sections/`, empaquetadas con la app — no son una llamada de red, así que no dependen de conexión ni cuentan como "contenido" a efectos de la regla de "sin persistencia offline" (esa regla es sobre datos de municipio, no sobre los propios assets de la app).

---

## 9. Contrato con la arquitectura

- Los tokens viven en `app/lib/core/theme/`. **Ningún widget de `features/` escribe un `Color(0x...)`, un tamaño de fuente ni un número de espaciado a mano.** Todo sale de `Theme.of(context)` o de las clases de token.
- Los colores semánticos que Material no cubre (severidad, skeleton, marca decorativa) viajan en un `ThemeExtension` (`AppSemanticColors`), no en variables globales.
- **Sin generación de código.** Los tokens son `const` escritos a mano. No hay `build_runner` ni ningún generador de temas.
- El tema es un detalle de presentación: `domain/` no sabe que existen los colores. La severidad en el dominio es un value object `Severity`; el mapeo severidad → color ocurre en `presentation/`.
- El color del municipio llega como dato del backend, se convierte en `BrandPalette` en la capa de presentación y se inyecta al `MaterialApp` mediante el tema. Ninguna pantalla lo lee por su cuenta.
