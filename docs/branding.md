# Identidad de marca de Poblex

**Versión:** 1.1 · **Fecha:** 2 de noviembre de 2026 · **Estado:** identidad aplicada en código y activos; pendiente de validación visual y accesibilidad en dispositivos reales.

> **Aviso de vigencia (2 de noviembre de 2026, tarde):** el primario pasa de terracota a **morado**, mismo día que el rebrand a terracota de esta mañana. Ver "Paleta de marca" más abajo — la tabla terracota queda marcada como histórica, igual que el coral quedó histórico frente al terracota. El código y `packages/poblex_design_system` ya usan los tokens morados.

## Qué es Poblex

Poblex reúne la información y los servicios municipales de un pueblo en un lugar accesible. Su cliente es el ayuntamiento; quienes lo usan son sus vecinos. Es una marca de producto compartida por municipios, no una identidad institucional que suplante a cada ayuntamiento.

**Idea central: el punto de encuentro.** La plaza es una imagen común de la vida municipal: un lugar abierto en el que las personas se informan y participan. La marca traduce esa idea a una forma sencilla y abierta que también sugiere una «p» minúscula. El punto representa a una persona y el espacio común, sin representar una ubicación exacta ni prometer una funcionalidad concreta.

**Posicionamiento:** una herramienta municipal clara y cercana que facilita el acceso a información y gestiones cotidianas. **Promesa:** hacer más fácil encontrar lo que ocurre y lo que se necesita en el municipio. **Personalidad:** cercana, clara, serena y fiable. No paternalista, alarmista ni burocrática.

**Lema propuesto:** «La vida de tu pueblo, más cerca». Es comunicación de marca, no texto de interfaz aprobado ni una afirmación de cobertura de servicios. La adaptación valenciana debe revisarse con hablantes antes de publicarse.

## Nombre y arquitectura de marca

Se escribe **Poblex** en texto corrido y puede escribirse **POBLEX** en el logotipo. No se traduce. En una aplicación común, Poblex identifica el servicio y el municipio identifica el contexto: «Poblex · Sollana». El escudo o logo municipal, si existe autorización para usarlo, debe aparecer separado y conservar sus propias normas. No se combina dentro del símbolo ni sustituye la marca Poblex. Ningún municipio modifica los colores de severidad de los avisos.

Antes de invertir en lanzamiento, comprobar disponibilidad registral del nombre y símbolo, dominios y conflictos en los mercados relevantes. Esta propuesta no es una búsqueda de marca registrada ni acredita derechos de uso.

## Logotipo

El símbolo es un trazo abierto, con una estructura vertical, un arco y un punto interior. Funciona solo en espacios pequeños; la versión horizontal es la presentación principal. El logotipo está trazado en vectores, sin depender de fuentes instaladas ni servicios externos.

- Principal: [logotipo horizontal tinta](../design/branding/poblex-horizontal.svg).
- Sobre fondo oscuro: [logotipo blanco](../design/branding/poblex-horizontal-claro.svg).
- Uso monocromo de marca: [logotipo terracota de acción](../design/branding/poblex-horizontal-terracota.svg).
- Espacios reducidos: [símbolo terracota](../design/branding/poblex-simbolo.svg) y [símbolo blanco](../design/branding/poblex-simbolo-claro.svg).
- [Lámina de identidad](../design/branding/lamina-identidad.svg): composición de referencia, no plantilla de interfaz.

**Área de respeto:** deja alrededor al menos la altura del punto interior del símbolo, medida en el tamaño reproducido. **Tamaño inicial recomendado:** logotipo horizontal desde 160 px de ancho y símbolo desde 24 px; verificar en el soporte final, especialmente impresión y tamaños de icono de tienda. No hay un tamaño mínimo certificado mediante pruebas con usuarios.

Usa tinta o terracota de acción sobre superficies claras y blanco sobre superficies oscuras con contraste suficiente. En fotografías, utiliza una zona uniforme o una superficie opaca que garantice legibilidad. No estires, inclines, cambies el grosor, añadas sombras, recompongas las letras ni metas el logo en una alerta. No uses el terracota decorativo para texto del logo sobre blanco. El símbolo por sí solo debe acompañarse de un nombre accesible cuando identifique la aplicación o sea un control; como adorno, se excluye de la lectura de pantalla.

Los SVG son originales del proyecto, pero eso no sustituye una comprobación jurídica de anterioridades. El diseño es vectorial y editable; para imprenta hay que acordar perfil de color y obtener pruebas físicas.

## Paleta de marca

La paleta elegida conserva los colores fijados para el proyecto. Los valores de marca y de interacción son distintos porque cumplen funciones diferentes.

| Función | Color | Valor | Uso |
|---|---|---|---|
| Morado de marca | Violeta Poblex | `#955AC8` | Ilustraciones y superficies decorativas; nunca texto o botón primario. |
| Gráfico de marca | Morado profundo | `#6F33A3` | Iconos y trazos significativos donde el contraste del contexto alcance 3:1. |
| Acción clara | Morado oscuro | `#55257F` | Enlaces y botón principal con texto blanco; comprobar cada fondo. |
| Acción oscura | Morado claro | `#C4A0E3` | Acciones sobre `#14110F`, con texto oscuro. |
| Acento | Verde Albufera | `#1F6F5C` | Acento secundario y estados positivos con palabra e icono. Sin cambios. |
| Fondo | Hueso | `#FAF7F2` | Fondo de lectura. |
| Superficie | Blanco | `#FFFFFF` | Tarjetas y zonas de trabajo. |
| Texto | Tinta | `#1A1A1A` | Texto principal. |
| Fondo oscuro | Carbón cálido | `#14110F` | Fondo en modo oscuro. |

Ratios WCAG calculados para combinaciones concretas: tinta sobre hueso **16,29:1**; blanco sobre acción **10,73:1**; acción sobre hueso **10,04:1**; acción oscura sobre fondo oscuro **8,49:1**; gráfico sobre hueso **7,34:1**; verde sobre hueso **5,64:1**; marca decorativa sobre blanco **4,59:1**. El umbral ordinario de texto es 4,5:1; para elementos gráficos esenciales es 3:1 frente a los colores adyacentes. No extrapolar estos resultados a otros fondos, transparencias o estados. Calculado con script (fórmula de luminancia relativa WCAG 2.1), no a mano.

**Separación frente a severidad:** distancia perceptual (ΔE00, CIEDE2000) entre cualquier paso del morado y los tres colores de identidad de severidad AEMET (`#E8A33D`/`#D9772B`/`#B3261E`): mínimo 35,4, máximo 70,7. Muy por encima del umbral de confusión plausible (ΔE00 < 10) que motivó la regla R1 con el terracota — el morado no comparte arco de tono con las alertas, así que la separación estructural de §2.7 del design-system sigue aplicando, pero ya no hace falta la deriva de tono hacia siena que el terracota necesitaba en sus pasos oscuros.

### Histórico: paleta terracota (9 ago → 2 nov 2026, tarde)

**Histórico, sustituido por la paleta morada de arriba**, mismo día que se adoptó. Se conserva aquí para trazabilidad, no como referencia de implementación.

| Función | Color | Valor | Uso |
|---|---|---|---|
| Terracota de marca | Terracota | `#D97757` | Ilustraciones y superficies decorativas; nunca texto o botón primario. |
| Gráfico de marca | Terracota profundo | `#B6542B` | Iconos y trazos significativos donde el contraste del contexto alcance 3:1. |
| Acción clara | Tierra | `#8A461E` | Enlaces y botón principal con texto blanco; comprobar cada fondo. |
| Acción oscura | Terracota claro | `#EBAD98` | Acciones sobre `#14110F`, con texto oscuro. |

Ratios históricos: tinta sobre hueso 16,29:1; blanco sobre acción 7,06:1; acción sobre hueso 6,60:1; marca decorativa sobre blanco 3,12:1.

**Reserva de seguridad:** amarillo `#E8A33D`, naranja `#D9772B` y rojo `#B3261E` son colores de identidad de severidad, no colores de marca. Son parecidos a algunos tonos terracota: separa las alertas por contenedor, silueta, etiqueta visible y grosor de barra, además del color. Las alertas no llevan color de marca dentro. Sus combinaciones y reglas detalladas están en [accesibilidad](design-system-accessibility.md).

## Tipografía y lenguaje visual

**Atkinson Hyperlegible Next** es la familia de interfaz existente. Utilizar los pesos regular, seminegrita y negrita incluidos en el repositorio. El dibujo del logotipo es propio y no sustituye la tipografía de lectura. Tamaño base de cuerpo: 18 sp, sin impedir el escalado del sistema hasta el 200 %. Evitar mayúsculas sostenidas para párrafos, texto sobre imágenes y textos de bajo contraste.

La identidad se expresa con superficies claras, tinta y un acento contenido; no depende de degradados ni ornamentos. Usar fotografías reales del municipio cuando se tenga permiso, con personas y lugares representados con dignidad y sin insinuar que una escena es de Sollana si no lo es. Ilustraciones sencillas y geométricas pueden complementar información, nunca reemplazar etiquetas de acciones o avisos.

**Nota (2 de noviembre de 2026): dos niveles de imagen, no confundir.** Esta mañana se retiraron las fotos de stock genéricas del seed de noticias (`7edf792`) precisamente para no mostrar fotografía de archivo sin relación con el municipio como si fuera contenido real. Esa regla sigue en pie para el **contenido de un municipio** (noticia, evento, instalación): foto real del ayuntamiento o, si no hay, sin imagen — nunca una foto de stock haciendo de sustituta. Pero el **grid de categorías de Inicio** (Noticias, Alertas, Eventos...) no es contenido de ningún municipio: es la iconografía de la funcionalidad misma, igual en Sollana que en cualquier otro pueblo que use Poblex. Para esas nueve imágenes de categoría sí se usa fotografía de stock, con una condición no negociable: **solo licencia CC0 o dominio público**, nunca CC-BY/CC-BY-SA (exigirían mostrar atribución en la app, una superficie que no existe y no se improvisa aquí). Ninguna de esas nueve fotos lleva pie de foto ni insinúa que sea "de" ningún municipio concreto — ver el componente "Mosaico de categoría" en `docs/design-system.md` §8.14.

## Voz y contenido

Hablar con claridad, de tú, y explicar qué ocurre y qué puede hacer la persona. Priorizar palabras comunes, fechas y lugares concretos. Dar instrucciones directas sin prometer una actuación que el sistema no realiza. No disfrazar una encuesta consultiva de votación vinculante. No dar a entender que las incidencias son públicas.

Ejemplo: «No se han podido cargar las noticias. Comprueba tu conexión y vuelve a intentarlo.» Acción: «Reintentar». El contenido real de interfaz se mantiene en los dos archivos ARB y debe revisarse en castellano y valenciano; este ejemplo es una guía, no una cadena integrada.

## Sistema de diseño y estado de implantación

La especificación detallada de componentes, tamaños, estados y alertas está en [design-system.md](design-system.md), con controles de aceptación en [design-system-accessibility.md](design-system-accessibility.md). El paquete compartido `packages/poblex_design_system` contiene la paleta y el símbolo utilizados por las dos aplicaciones. La entrada y el menú de la app, y el acceso y la navegación del backoffice muestran el símbolo. La personalización de cada municipio continúa utilizando su propia semilla y no modifica la severidad.

Los iconos nativos de Android e iOS y los iconos web del backoffice se han generado a partir de [poblex-icono-app.svg](../design/branding/poblex-icono-app.svg), con fondo hueso opaco y margen de seguridad. Los SVG del manual siguen siendo los originales para otros soportes — **todavía en terracota**: el símbolo vectorial (`poblex-horizontal-terracota.svg`, `poblex-simbolo.svg`, `lamina-identidad.svg`) no se ha regenerado en morado en este cambio, solo los tokens de color del tema en `packages/poblex_design_system` y los `theme-color` del backoffice web. Pendiente explícito, no un olvido: regenerar los SVG de marca (o renombrarlos) antes de dar la identidad morada por completamente aplicada. La antigua paleta coral sigue histórica frente al terracota, que a su vez queda histórico frente al morado de hoy; el código usa ahora los tokens morados de este manual.

## Aplicación y validación pendientes

1. Revisar la marca a 24 px, en escala de grises, sobre fondos reales y con personas mayores; ajustar antes de fijarla definitivamente.
2. Comprobar nombre y distintivo, licencias de tipografía y derechos de imágenes antes de difusión pública.
3. Comprobar los iconos generados en dispositivos reales y en las herramientas de publicación de cada plataforma.
4. Revisar componentes y estados, escala de texto, contraste efectivo, TalkBack y VoiceOver; ensayar avisos de severidad sin depender del color.
5. Preparar una versión valenciana revisada del material de comunicación y de cualquier cadena nueva de interfaz.
