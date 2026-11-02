# Accesibilidad — checklist de aceptación

> **Aviso de vigencia (2 noviembre 2026):** el tema compartido utiliza la paleta terracota de este documento. Los cálculos de contraste no sustituyen la comprobación de componentes y lectores de pantalla en dispositivos reales. Consulta [branding.md](branding.md) para la identidad y su implantación.

**Versión:** 1.0
**Fecha:** 9 de agosto de 2026
**Base legal:** RD 1112/2018 (accesibilidad de sitios web y aplicaciones para dispositivos móviles del sector público) → exige **WCAG 2.1 nivel AA**.
**Documento hermano:** `docs/design-system.md`.

Esto no es una guía de buenas prácticas. Es la **lista de comprobación de aceptación**: una pantalla que no pasa todos los puntos aplicables **no se da por terminada**, no se mete en la demo y no llega al alcalde. El RD 1112/2018 además obliga a publicar una **declaración de accesibilidad**, que se redacta a partir de este documento.

---

## 0. Aviso — paleta rebrandeada, tabla pendiente de re-auditoría

`docs/design-system.md` §0.1 documenta un cambio de paleta (terracota `#D97757` → coral
Stitch `#FF7043`/`#AC3509`, fondo hueso `#FAF7F2` → `#F8F9FF`, etc.), aplicado ya en
`packages/poblex_design_system/lib/src/app_colors.dart`. La tabla de contrastes de este
documento (~sección 1 y siguientes) todavía cita los hexadecimales **antiguos** y no se ha
recalculado fila a fila para los nuevos. No la uses para redactar la declaración de
accesibilidad hasta que se re-audite. Los pares más críticos (texto de acción, texto
atenuado, fondo) sí están verificados a mano en design-system.md §0.1.

## 1. Tabla de contrastes verificados

Todos los valores están **calculados** con la fórmula de luminancia relativa de WCAG 2.1:

```
L = 0,2126·R + 0,7152·G + 0,0722·B     con  C = C/255;  C ≤ 0,04045 ? C/12,92 : ((C+0,055)/1,055)^2,4
ratio = (L_claro + 0,05) / (L_oscuro + 0,05)
```

No hay ninguna estimación a ojo en esta tabla. **75 parejas, 0 fallos.**

### 1.1 Modo claro — texto y elementos de interfaz

| ID | Pareja | Primer plano | Fondo | Ratio | Mínimo | Resultado |
|---|---|---|---|---|---|---|
| L01 | Texto de cuerpo (tinta) sobre fondo hueso | `#1A1A1A` | `#FAF7F2` | **16,29:1** | 4,5:1 | PASA |
| L02 | Texto de cuerpo (tinta) sobre tarjeta blanca | `#1A1A1A` | `#FFFFFF` | **17,40:1** | 4,5:1 | PASA |
| L03 | Texto secundario `neutral-700` sobre hueso | `#4F4640` | `#FAF7F2` | **8,61:1** | 4,5:1 | PASA |
| L04 | Texto atenuado `neutral-600` sobre hueso | `#6A6058` | `#FAF7F2` | **5,73:1** | 4,5:1 | PASA |
| L05 | Texto atenuado `neutral-600` sobre blanco | `#6A6058` | `#FFFFFF` | **6,13:1** | 4,5:1 | PASA |
| L06 | Enlace / texto de marca `primary-700` sobre hueso | `#8A461E` | `#FAF7F2` | **6,60:1** | 4,5:1 | PASA |
| L07 | Enlace / texto de marca `primary-700` sobre blanco | `#8A461E` | `#FFFFFF` | **7,06:1** | 4,5:1 | PASA |
| L08 | Etiqueta blanca sobre botón primario | `#FFFFFF` | `#8A461E` | **7,06:1** | 4,5:1 | PASA |
| L09 | Etiqueta blanca sobre botón pulsado | `#FFFFFF` | `#6A3616` | **9,76:1** | 4,5:1 | PASA |
| L10 | Etiqueta `primary-700` sobre botón tonal | `#8A461E` | `#FAE3DC` | **5,74:1** | 4,5:1 | PASA |
| L11 | Borde de botón contorneado sobre blanco | `#8A461E` | `#FFFFFF` | **7,06:1** | 3:1 | PASA |
| L12 | Anillo de foco sobre hueso | `#6A3616` | `#FAF7F2` | **9,13:1** | 3:1 | PASA |
| L13 | Anillo de foco sobre blanco | `#6A3616` | `#FFFFFF` | **9,76:1** | 3:1 | PASA |
| L14 | Borde de campo de formulario sobre blanco | `#847A71` | `#FFFFFF` | **4,20:1** | 3:1 | PASA |
| L15 | Borde de campo de formulario sobre hueso | `#847A71` | `#FAF7F2` | **3,93:1** | 3:1 | PASA |
| L16 | Icono con significado `primary-600` sobre hueso | `#B6542B` | `#FAF7F2` | **4,58:1** | 3:1 | PASA |
| L17 | Icono con significado `primary-600` sobre blanco | `#B6542B` | `#FFFFFF` | **4,89:1** | 3:1 | PASA |
| L18 | Texto de acento verde sobre hueso | `#1F6F5C` | `#FAF7F2` | **5,64:1** | 4,5:1 | PASA |
| L19 | Blanco sobre botón secundario verde | `#FFFFFF` | `#1F6F5C` | **6,02:1** | 4,5:1 | PASA |
| L20 | Texto de acento sobre superficie de acento | `#1C6958` | `#EDF7F5` | **5,99:1** | 4,5:1 | PASA |
| L21 | Etiqueta deshabilitada sobre fondo deshabilitado | `#847A71` | `#E4DED8` | **3,15:1** | 3:1 | PASA |
| L22 | Icono de navegación activo sobre blanco | `#8A461E` | `#FFFFFF` | **7,06:1** | 4,5:1 | PASA |
| L23 | Icono de navegación inactivo sobre blanco | `#6A6058` | `#FFFFFF` | **6,13:1** | 4,5:1 | PASA |
| L24 | Texto de error sobre hueso | `#92161A` | `#FAF7F2` | **8,36:1** | 4,5:1 | PASA |
| L25 | Texto de error sobre blanco | `#92161A` | `#FFFFFF` | **8,93:1** | 4,5:1 | PASA |

> **Nota sobre L21:** WCAG exime a los controles deshabilitados del requisito de contraste. Lo cumplimos igualmente porque el público mayor necesita leer también lo que no puede pulsar.

### 1.2 Modo claro — severidad de alerta

| ID | Pareja | Primer plano | Fondo | Ratio | Mínimo | Resultado |
|---|---|---|---|---|---|---|
| S01 | Tinta sobre banner amarillo | `#1A1A1A` | `#FCF3E3` | **15,80:1** | 4,5:1 | PASA |
| S02 | Tinta sobre banner naranja | `#1A1A1A` | `#FCEBDE` | **14,98:1** | 4,5:1 | PASA |
| S03 | Tinta sobre banner rojo | `#1A1A1A` | `#FCE5E3` | **14,47:1** | 4,5:1 | PASA |
| S04 | Titular de severidad sobre banner amarillo | `#7D5003` | `#FCF3E3` | **6,31:1** | 4,5:1 | PASA |
| S05 | Titular de severidad sobre banner naranja | `#862F04` | `#FCEBDE` | **7,46:1** | 4,5:1 | PASA |
| S06 | Titular de severidad sobre banner rojo | `#92161A` | `#FCE5E3` | **7,42:1** | 4,5:1 | PASA |
| S07 | Barra lateral amarilla sobre página | `#7D5003` | `#FAF7F2` | **6,51:1** | 3:1 | PASA |
| S08 | Barra lateral naranja sobre página | `#862F04` | `#FAF7F2` | **8,11:1** | 3:1 | PASA |
| S09 | Barra lateral roja sobre página | `#92161A` | `#FAF7F2` | **8,36:1** | 3:1 | PASA |
| S10 | Tinta sobre chip amarillo sólido | `#1A1A1A` | `#E8A33D` | **8,07:1** | 4,5:1 | PASA |
| S11 | Tinta sobre chip naranja sólido | `#1A1A1A` | `#D9772B` | **5,49:1** | 4,5:1 | PASA |
| S12 | **Blanco** sobre chip rojo sólido | `#FFFFFF` | `#B3261E` | **6,54:1** | 4,5:1 | PASA |
| S13 | Borde de chip amarillo sobre blanco | `#7D5003` | `#FFFFFF` | **6,95:1** | 3:1 | PASA |
| S14 | Borde de chip naranja sobre blanco | `#862F04` | `#FFFFFF` | **8,67:1** | 3:1 | PASA |
| S15 | Borde de chip rojo sobre blanco | `#92161A` | `#FFFFFF` | **8,93:1** | 3:1 | PASA |

> **Por qué S13-S15 existen:** el color de identidad amarillo `#E8A33D` sobre blanco da **2,16:1**, por debajo del 3:1 exigido a elementos gráficos (WCAG 1.4.11). El chip sólido **no puede ir sin borde**. El borde de 1,5 dp en el tono oscuro aporta el contorno que cumple. Sin él, el chip amarillo se difumina contra la tarjeta blanca.

### 1.3 Modo oscuro — texto y elementos de interfaz

| ID | Pareja | Primer plano | Fondo | Ratio | Mínimo | Resultado |
|---|---|---|---|---|---|---|
| D01 | Texto de cuerpo sobre fondo oscuro | `#F5F0E9` | `#14110F` | **16,59:1** | 4,5:1 | PASA |
| D02 | Texto de cuerpo sobre tarjeta oscura | `#F5F0E9` | `#1F1A17` | **15,20:1** | 4,5:1 | PASA |
| D03 | Texto atenuado sobre fondo oscuro | `#BFB8B0` | `#14110F` | **9,58:1** | 4,5:1 | PASA |
| D04 | Texto atenuado sobre tarjeta oscura | `#BFB8B0` | `#1F1A17` | **8,78:1** | 4,5:1 | PASA |
| D05 | Texto de marca sobre fondo oscuro | `#EBAD98` | `#14110F` | **9,82:1** | 4,5:1 | PASA |
| D06 | Texto de marca sobre tarjeta oscura | `#EBAD98` | `#1F1A17` | **9,00:1** | 4,5:1 | PASA |
| D07 | Etiqueta oscura sobre botón primario | `#14110F` | `#EBAD98` | **9,82:1** | 4,5:1 | PASA |
| D08 | Etiqueta oscura sobre botón pulsado | `#14110F` | `#E29378` | **7,77:1** | 4,5:1 | PASA |
| D09 | Texto de marca sobre superficie elevada | `#EBAD98` | `#2A241F` | **8,00:1** | 4,5:1 | PASA |
| D10 | Anillo de foco sobre fondo oscuro | `#EBAD98` | `#14110F` | **9,82:1** | 3:1 | PASA |
| D11 | Borde de tarjeta sobre fondo oscuro | `#7C716A` | `#14110F` | **3,96:1** | 3:1 | PASA |
| D12 | Borde de tarjeta sobre tarjeta oscura | `#7C716A` | `#1F1A17` | **3,63:1** | 3:1 | PASA |
| D13 | Borde de campo sobre superficie elevada | `#7C716A` | `#2A241F` | **3,23:1** | 3:1 | PASA |
| D14 | Texto de acento verde sobre fondo oscuro | `#80C6B6` | `#14110F` | **9,55:1** | 4,5:1 | PASA |
| D15 | Etiqueta oscura sobre botón de acento | `#14110F` | `#80C6B6` | **9,55:1** | 4,5:1 | PASA |
| D16 | Texto de error sobre fondo oscuro | `#F88277` | `#14110F` | **7,57:1** | 4,5:1 | PASA |

> **Aviso estructural:** la tarjeta oscura `#1F1A17` sobre el fondo `#14110F` da **1,09:1**. Es deliberado (superficies M3 muy próximas) y **por eso el borde D11-D13 es obligatorio en modo oscuro**. Una tarjeta sin borde en modo oscuro no existe visualmente: es un fallo de aceptación, no una decisión estética.

### 1.4 Modo oscuro — severidad de alerta

| ID | Pareja | Primer plano | Fondo | Ratio | Mínimo | Resultado |
|---|---|---|---|---|---|---|
| DS1 | Texto claro sobre banner amarillo oscuro | `#F5F0E9` | `#3C3120` | **11,21:1** | 4,5:1 | PASA |
| DS2 | Texto claro sobre banner naranja oscuro | `#F5F0E9` | `#3A271D` | **12,45:1** | 4,5:1 | PASA |
| DS3 | Texto claro sobre banner rojo oscuro | `#F5F0E9` | `#3D1C1A` | **13,43:1** | 4,5:1 | PASA |
| DS4 | Titular amarillo sobre su tint oscuro | `#F6C96F` | `#3C3120` | **8,17:1** | 4,5:1 | PASA |
| DS5 | Titular naranja sobre su tint oscuro | `#F49E57` | `#3A271D` | **6,64:1** | 4,5:1 | PASA |
| DS6 | Titular rojo sobre su tint oscuro | `#F88277` | `#3D1C1A` | **6,13:1** | 4,5:1 | PASA |
| DS7 | Barra amarilla sobre fondo oscuro | `#E8AB30` | `#14110F` | **9,22:1** | 3:1 | PASA |
| DS8 | Barra naranja sobre fondo oscuro | `#EC8B3C` | `#14110F` | **7,45:1** | 3:1 | PASA |
| DS9 | Barra roja sobre fondo oscuro | `#EB5847` | `#14110F` | **5,39:1** | 3:1 | PASA |
| DSA | Tinta sobre chip amarillo (modo oscuro) | `#1A1A1A` | `#E8AB30` | **8,54:1** | 4,5:1 | PASA |
| DSB | Tinta sobre chip naranja (modo oscuro) | `#1A1A1A` | `#EC8B3C` | **6,90:1** | 4,5:1 | PASA |
| DSC | Tinta sobre chip rojo (modo oscuro) | `#1A1A1A` | `#EB5847` | **4,99:1** | 4,5:1 | PASA |

### 1.5 Separación perceptual marca ↔ severidad (ΔE00, CIEDE2000)

El contraste no basta: dos colores pueden cumplir contraste contra el fondo y aun así confundirse **entre sí**. Esta tabla mide la diferencia perceptual. Referencia: < 2,3 imperceptible; < 5 difícil; < 10 confundible en condiciones reales (sol, prisa, baja visión); > 15 claramente distintos.

| Token de marca | amarillo `#E8A33D` | naranja `#D9772B` | rojo `#B3261E` | amarillo osc. | naranja osc. | rojo osc. |
|---|---|---|---|---|---|---|
| `primary-500` (decorativo) | 21,7 | **10,5** ⚠ | 22,0 | 28,2 | 27,7 | 28,9 |
| `primary-600` (gráfico) | 27,8 | 14,2 | 11,2 | 17,9 | 13,6 | 17,1 |
| `primary-700` (acción claro) | 35,4 | 23,3 | 13,0 | 11,1 | **6,2** ⚠ | 14,1 |
| `primary-300` (acción oscuro) | 19,3 | 18,9 | 35,5 | 38,2 | 43,3 | 44,8 |

**Separación entre niveles de severidad** (esto es lo que de verdad protege al vecino):

| Pareja | ΔE00 |
|---|---|
| amarillo ↔ naranja (identidad) | 14,6 |
| naranja ↔ rojo (identidad) | 25,8 |
| amarillo ↔ rojo (identidad) | 40,2 |
| amarillo ↔ naranja (tono oscuro) | 15,5 |
| naranja ↔ rojo (tono oscuro) | 10,5 |

**Luminancia relativa de los colores de identidad** (orden monótono = la escala se lee también en blanco y negro):

| Nivel | Ratio frente a negro |
|---|---|
| Amarillo `#E8A33D` | 9,74 |
| Naranja `#D9772B` | 6,62 |
| Rojo `#B3261E` | 3,21 |

Los dos ⚠ están mitigados por las cinco reglas estructurales de `design-system.md` §2.7. **La mitigación es obligatoria, no recomendada**, y sus puntos son verificables en la sección 3 de este documento.

---

## 2. Checklist de aceptación por pantalla

Se aplica a **toda pantalla nueva o modificada**. Cada punto es verificable por otra persona en menos de un minuto.

### 2.1 Color y contraste

- [ ] **A-01** Todo texto normal alcanza ≥ 4,5:1 contra su fondo real (WCAG 1.4.3).
- [ ] **A-02** Todo texto ≥ 24 sp o ≥ 18,66 sp en negrita alcanza ≥ 3:1.
- [ ] **A-03** Todo borde, icono o indicador que transmite información alcanza ≥ 3:1 (WCAG 1.4.11).
- [ ] **A-04** No se usa `primary-500` (`#D97757`) para texto, borde con significado ni fondo de botón. Solo decoración.
- [ ] **A-05** Ninguna información depende solo del color (WCAG 1.4.1): hay icono, texto o forma que la duplique.
- [ ] **A-06** La pantalla se ha revisado en **captura en escala de grises** y sigue siendo comprensible.
- [ ] **A-07** La pantalla cumple A-01 a A-06 **también en modo oscuro**.
- [ ] **A-08** En modo oscuro, toda tarjeta o campo tiene borde visible (≥ 3:1); ninguna superficie se apoya solo en la sombra.
- [ ] **A-09** Ningún color de severidad aparece fuera de un componente de alerta, y ningún color de marca aparece dentro de uno.

### 2.2 Tipografía y escalado

- [ ] **A-10** El texto de cuerpo es `bodyLarge` (18 sp). Nada por debajo de 15 sp para texto corrido; 14 sp solo para metadatos.
- [ ] **A-11** No hay ningún tamaño de fuente escrito a mano; todo sale del `TextTheme`.
- [ ] **A-12** No hay `SizedBox`, `Container` ni `ConstrainedBox` con **altura fija alrededor de texto**.
- [ ] **A-13** La pantalla se ha probado con `textScaler` a **1,0 / 1,5 / 2,0** sin desbordes, sin recortes y sin texto solapado.
- [ ] **A-14** La misma prueba de 2,0 se ha hecho **en valenciano**, que es el caso peor de longitud.
- [ ] **A-15** Ningún texto usa mayúsculas forzadas ni justificado.
- [ ] **A-16** Si un texto se trunca en una lista, existe una vista de detalle que lo muestra completo.
- [ ] **A-17** El escalado no se limita por debajo de 2,0.

### 2.3 Interacción táctil

- [ ] **A-18** Toda área táctil mide ≥ 48 × 48 dp, contando el relleno transparente (WCAG 2.5.5).
- [ ] **A-19** Las acciones principales miden ≥ 56 dp de alto.
- [ ] **A-20** Hay ≥ 8 dp de separación entre áreas táctiles contiguas.
- [ ] **A-21** **Ninguna acción se ejecuta solo con un gesto.** Todo deslizamiento, pulsación larga o gesto multitáctil tiene botón visible equivalente (WCAG 2.5.1 y regla de `CLAUDE.md`).
- [ ] **A-22** Ninguna acción destructiva se dispara sin confirmación explícita.
- [ ] **A-23** El foco físico (teclado o conmutador) es visible: anillo de 3 dp con ≥ 3:1 y separación de 2 dp.
- [ ] **A-24** El orden de recorrido del foco sigue el orden visual de lectura.

### 2.4 Semántica y lectores de pantalla

- [ ] **A-25** Todo control tiene `Semantics.label` **descriptivo**: "Enviar incidencia", no "Botón".
- [ ] **A-26** Toda imagen con contenido tiene descripción; las decorativas van con `ExcludeSemantics`.
- [ ] **A-27** Las tarjetas agrupan su semántica en un solo nodo (`MergeSemantics`), en vez de anunciar seis fragmentos sueltos.
- [ ] **A-28** Los estados se anuncian: `selected`, `enabled`, `checked`, `inMutuallyExclusiveGroup` según corresponda.
- [ ] **A-29** Errores y cambios de estado asíncronos usan `liveRegion: true`.
- [ ] **A-30** Las **alertas rojas** usan `liveRegion` con prioridad asertiva y se anuncian al entrar en la pantalla.
- [ ] **A-31** Los skeletons no se enumeran: el contenedor anuncia "Cargando…" y los bloques van excluidos.
- [ ] **A-32** Los encabezados de sección se marcan como cabecera (`header: true`) para poder navegar por encabezados.

### 2.5 Estructura y navegación

- [ ] **A-33** El destino está a **dos niveles como máximo** desde el inicio.
- [ ] **A-34** Hay una forma clara de volver, y el gesto de retroceso del sistema funciona.
- [ ] **A-35** El título de la pantalla es visible y coincide con el que anuncia el lector.
- [ ] **A-36** El *deep link* de la notificación abre la **pantalla de detalle**, no el inicio.

### 2.6 Estados de datos

- [ ] **A-37** La pantalla implementa los cuatro estados: cargando, con contenido, vacío y error.
- [ ] **A-38** El estado de error muestra causa en lenguaje llano y **botón "Reintentar" visible**, de ancho completo.
- [ ] **A-39** No existe ningún camino que deje pantalla en blanco ni spinner indefinido. Tope: 15 s.
- [ ] **A-40** El estado vacío explica qué falta y qué se puede hacer; distingue "vacío" de "vacío por filtro".
- [ ] **A-41** En alertas, un fallo de carga **conserva el histórico ya cargado** en pantalla.
- [ ] **A-42** Todos los mensajes de error existen en castellano y en valenciano, en el mismo commit.

### 2.7 Movimiento

- [ ] **A-43** Con reduce-motion activo (`MediaQuery.disableAnimationsOf`), todas las duraciones pasan a cero y el skeleton se queda estático (WCAG 2.3.3).
- [ ] **A-44** Ningún elemento parpadea entre 2 y 55 Hz (WCAG 2.3.1).
- [ ] **A-45** Ninguna animación retrasa la aparición del contenido.
- [ ] **A-46** No hay contenido en movimiento automático sin control para pararlo (WCAG 2.2.2).

### 2.8 Formularios

- [ ] **A-47** Todo campo tiene etiqueta **visible encima**. El texto de marcador de posición nunca hace de etiqueta (WCAG 3.3.2).
- [ ] **A-48** Los campos obligatorios lo dicen con la palabra "obligatorio", no con un asterisco solo.
- [ ] **A-49** El error de validación se indica con **icono + texto**, no solo con borde rojo (WCAG 3.3.1).
- [ ] **A-50** El mensaje de error dice cómo corregirlo, no solo que hay un fallo (WCAG 3.3.3).
- [ ] **A-51** El teclado que se abre corresponde al tipo de dato (`keyboardType`, `textInputAction`).
- [ ] **A-52** El envío no se pierde si el teclado tapa el botón: el formulario se desplaza.

### 2.9 Bilingüismo

- [ ] **A-53** Ninguna cadena está escrita a mano en el widget; todas vienen de ARB.
- [ ] **A-54** Toda cadena nueva se ha añadido a los **dos** ficheros ARB (`es`, `ca-ES-valencia`) en el mismo commit.
- [ ] **A-55** El contenido sin traducción muestra el idioma disponible con indicación discreta. Nunca hueco ni "null".
- [ ] **A-56** El cambio de idioma resuscribe los topics de FCM: desuscripción del anterior antes de la suscripción al nuevo.
- [ ] **A-57** El atributo de idioma del texto es correcto, para que el lector de pantalla lo pronuncie bien (WCAG 3.1.2).

---

## 3. Verificación específica del riesgo marca ↔ alerta

Estos puntos se verifican en **cada pantalla que muestre alertas** y en cada revisión de la paleta de marca de un municipio nuevo.

- [ ] **R-01** El banner de alerta lleva **barra lateral** con el grosor de su nivel: 4 dp amarillo, 8 dp naranja, 12 dp rojo.
- [ ] **R-02** El icono de severidad tiene **silueta distinta** por nivel (triángulo contorneado / triángulo relleno / octógono), no el mismo icono en tres colores.
- [ ] **R-03** El chip de severidad muestra **siempre** la palabra y el número: "Aviso naranja · Nivel 2". No se oculta al truncar ni al escalar el texto.
- [ ] **R-04** El chip de severidad es **sólido con borde**; los chips de categoría de contenido son **contorneados**. Nunca al revés.
- [ ] **R-05** El banner de alerta usa radio 8 dp; las tarjetas de contenido usan 16 dp.
- [ ] **R-06** No hay ningún color de marca dentro del banner de alerta (ni botón, ni enlace, ni icono).
- [ ] **R-07** No hay ninguna banda horizontal a ancho completo con color de marca en toda la app.
- [ ] **R-08** Captura en escala de grises: los tres niveles de alerta siguen siendo distinguibles por barra, icono y texto.
- [ ] **R-09** Simulación de protanopia y deuteranopia: los tres niveles siguen siendo distinguibles.
- [ ] **R-10** Con la paleta de marca de un municipio nuevo, se repiten R-06 a R-09.

---

## 4. Procedimiento de verificación con lector de pantalla

**No se da por terminada ninguna pantalla sin este recorrido.** Diez minutos por pantalla. Se documenta en el PR con el resultado.

### 4.1 Android — TalkBack

**Activar:** Ajustes → Accesibilidad → TalkBack. Atajo recomendado: mantener pulsados los dos botones de volumen 3 segundos.

**Gestos mínimos:** deslizar a la derecha (siguiente elemento), a la izquierda (anterior), doble toque (activar), dos dedos hacia arriba (leer desde arriba), deslizar arriba y luego derecha (menú de navegación por encabezados).

1. **Recorrido lineal completo.** Desde el primer elemento hasta el último, deslizando a la derecha. Comprobar:
   - Todo control se anuncia con **etiqueta descriptiva**, no "Botón" ni "Imagen".
   - No se anuncia nada invisible ni decorativo.
   - El orden coincide con el orden visual.
   - Las tarjetas se anuncian como **una unidad**, no en seis trozos.
2. **Estados.** Comprobar que se dicen: "seleccionado", "activado", "no disponible", "casilla marcada".
3. **Carga.** Entrar con la red lenta: se anuncia "Cargando noticias" una sola vez, sin repetirse en bucle.
4. **Error.** Activar el modo avión y recargar: el error **se anuncia solo** al aparecer (`liveRegion`) y el botón "Reintentar" es alcanzable y descriptivo.
5. **Alerta roja.** Entrar en Alertas con una alerta roja activa: **se anuncia sin buscarla**. Probar el botón "Escuchar aviso".
6. **Escalado.** Tamaño de fuente al máximo del sistema **más** `textScaler` 2,0: recorrer de nuevo. Ningún control queda fuera de pantalla ni deja de ser alcanzable.
7. **Formulario.** Recorrer un formulario con un campo inválido: la etiqueta, el estado de obligatorio y el mensaje de error se anuncian **juntos** al enfocar el campo.
8. **Navegación por encabezados.** Con el menú de navegación en "Encabezados", recorrer la pantalla: los títulos de sección aparecen.

### 4.2 iOS — VoiceOver

**Activar:** Ajustes → Accesibilidad → VoiceOver. Atajo recomendado: triple clic en el botón lateral.

**Gestos mínimos:** deslizar a la derecha/izquierda (siguiente/anterior), doble toque (activar), dos dedos hacia arriba (leer todo), rotor (girar dos dedos) para navegar por encabezados.

1. Repetir los ocho puntos del recorrido de TalkBack.
2. **Rotor.** Girar dos dedos y seleccionar "Encabezados": comprobar que la pantalla es navegable por secciones.
3. **Texto más grande.** Ajustes → Accesibilidad → Pantalla y tamaño de texto → Texto más grande, al máximo con "Tamaños más grandes" activado. Recorrer de nuevo.
4. **Reducir movimiento.** Ajustes → Accesibilidad → Movimiento → Reducir movimiento. Comprobar que **las transiciones desaparecen** y el skeleton deja de moverse.
5. **Aumentar contraste.** Ajustes → Accesibilidad → Pantalla y tamaño de texto → Aumentar contraste. Comprobar que no se rompe ningún componente.

### 4.3 Comprobaciones automáticas en CI

No sustituyen al recorrido manual, pero atrapan las regresiones baratas. Se incluyen en los widget tests de las pantallas del core:

```dart
testWidgets('cumple las pautas de accesibilidad', (tester) async {
  final handle = tester.ensureSemantics();
  await tester.pumpWidget(const NewsScreenHarness());

  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

  handle.dispose();
});
```

Y una prueba de escalado por pantalla:

```dart
for (final scale in <double>[1.0, 1.5, 2.0]) {
  testWidgets('sin desbordes con textScaler $scale', (tester) async {
    tester.view.physicalSize = const Size(360, 640) * 3.0;
    tester.view.devicePixelRatio = 3.0;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: const NewsScreenHarness(locale: Locale('ca', 'ES')),
      ),
    );
    expect(tester.takeException(), isNull); // RenderFlex overflow lanza excepción
  });
}
```

> **Aviso sobre `textContrastGuideline`:** solo evalúa texto sobre fondos que puede resolver. **No sustituye** a la tabla de la sección 1, que es la fuente de verdad del contraste de tokens.

---

## 5. Declaración de accesibilidad (RD 1112/2018)

Obligatoria antes de abrir la app a vecinos. Se publica en la app (Ajustes → Accesibilidad) y en las fichas de las tiendas. Contenido mínimo:

1. Grado de cumplimiento: **conforme / parcialmente conforme / no conforme** con WCAG 2.1 AA.
2. Contenido no accesible, si lo hay, con el motivo y la alternativa disponible.
3. Fecha de la declaración y método de evaluación (autoevaluación con esta lista o auditoría externa).
4. Mecanismo de comunicación para que cualquier persona notifique un problema de accesibilidad, y plazo de respuesta.
5. Procedimiento de reclamación ante el ayuntamiento como responsable.

**Punto pendiente para el equipo:** la declaración la firma el ayuntamiento, que es el sujeto obligado. Se le entrega redactada, pero el titular del cumplimiento es el municipio, no el proveedor. Va en el contrato.
