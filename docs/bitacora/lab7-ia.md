He leído la política de uso de IA de la asignatura.

# Declaración de uso de IA · Lab 7 · E058

<!--
CÓMO SE RELLENA (léelo y borra este comentario si quieres; el script de evaluación lo ignora)
- La PRIMERA línea es obligatoria y no se toca: «He leído la política de uso de IA de la asignatura.»
- Copia este archivo como docs/bitacora/lab7-ia.md (junto a lab7-respuestas.md) y pon tu código en el título.
  Cada laboratorio tiene el suyo: el del Lab 6 (lab6-ia.md) no se toca.
- Si NO has usado IA: deja solo la línea «No he usado IA.» y borra la entrada de ejemplo.
- Si la has usado: borra la línea «No he usado IA.» y escribe UNA entrada por cada uso, con los 7 campos.
  Un campo vacío es una entrada incompleta (D3: −0,5 por entrada).
- Preguntar a la IA como tutor o corregir la ortografía de un texto propio está permitido: decláralo también.
  Si no copiaste código, escribe «no aplica» en «Código recibido» y en «Evidencia de ejecución» (no cuentan como vacíos).
  Los demás campos son siempre obligatorios.
- Una entrada con TODOS los campos vacíos (la de ejemplo sin tocar) no cuenta: se ignora.
- El código copiado de una IA puntúa si lo EJECUTAS en tu contenedor, lo EXPLICAS con tus palabras,
  dices para qué lo usaste y adjuntas aquí el código y el prompt LITERAL.
-->

Lo usé tmabien para muchos fallos que me daban los comandos

## Entrada 1
- **Herramienta:** Claude
- **Prompt (literal, copiado tal cual):**
```text
Estoy resolviendo el incidente INC-605. Las estadísticas de la tabla CESTA indican 100 filas, pero la tabla tiene 208100. Al intentar recoger las estadísticas me aparece ORA-20005 porque están bloqueadas. ¿Me puedes explicar qué significa el error y qué pasos debería seguir para actualizar las estadísticas y comprobar que el plan de ejecución ha mejorado?

```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```text
EXEC DBMS_STATS.UNLOCK_TABLE_STATS('T6', 'CESTA');
EXEC DBMS_STATS.GATHER_TABLE_STATS('T6', 'CESTA');

```
- **Dónde lo usé (parte, script o pregunta):** Parte G
- **Propósito (para qué lo necesitaba):** Entender por qué fallaba la recogida de estadísticas y cómo resolver el bloqueo antes de volver a ejecutar el informe.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** UNLOCK_TABLE_STATS quita el bloqueo de las estadísticas de la tabla CESTA.
GATHER_TABLE_STATS vuelve a recoger las estadísticas para que reflejen las 208100 filas reales.
- **Evidencia de ejecución (archivo de docs/bitacora/lab7/evidencia con mi cabecera):** incidentes/20261126T175934Z_INC-605_verificar.txt
