# Laboratorio 7 · Respuestas · E058

## Parte B · C01 · Más sesiones no es más rendimiento

### 1. ¿Cuántas llamadas por segundo y qué p95 tuviste con 1, 2 y 8 sesiones? ¿Qué número de sesiones recomiendas y por qué?

- Con 1 sesión: 4,7 llamadas/s y p95 de 210 ms.
- Con 2 sesiones: 9,1 llamadas/s y p95 de 254 ms.
- Con 8 sesiones: 8,6 llamadas/s y p95 de 1.340 ms.
- Recomendaría 2 sesiones: con 8 no aumentan las llamadas y el tiempo de respuesta empeora mucho. La base de datos tiene 2 CPU.

**Evidencia:** `casos/20261126T173814Z_C01_entender.txt` y `casos/20261126T173905Z_C01_validar.txt`.

### 2. ¿Qué evento domina con 8 sesiones y qué significa en Oracle Free?

El evento principal es `resmgr:cpu quantum`, con el 76,9 % de las muestras. Oracle Free limita la instancia a 2 CPU, así que las sesiones que no consiguen CPU tienen que esperar su turno. Hubo 246 muestras de espera y 74 en CPU.

**Evidencia:** `casos/20261126T173815Z_C01_diagnosticar.txt`.

### 3. Comprueba la ley de Little (N = X · R) con tus tres medidas.

- 1 sesión: 4,7 × 0,2054 = 0,97, aproximadamente 1.
- 2 sesiones: 9,1 × 0,2176 = 1,98, aproximadamente 2.
- 8 sesiones: 8,6 × 0,9083 = 7,8, aproximadamente 8.

Los resultados se acercan al número de sesiones usado en cada prueba.

**Evidencia:** `casos/20261126T173906Z_C01_observar.txt` y `casos/20261126T173904Z_C01_solucionar.txt`.

## Parte C · C03 · Literales y análisis completos

### 4. Análisis completos y tiempo con literales, con variables de enlace y con CURSOR_SHARING = FORCE.

En las tres pruebas se hicieron 5.000 llamadas:

- Literales: 5.050 análisis completos y 6.260 ms.
- `FORCE`: 28 análisis completos y 390 ms.
- Variables de enlace: 28 análisis completos y 280 ms.

Las variables de enlace dieron el mejor resultado. Con literales se crean muchos análisis y se pierde tiempo repitiendo trabajo.

**Evidencia:** `casos/20261126T174411Z_C03_diagnosticar.txt`, `casos/20261126T174414Z_C03_validar.txt` y `casos/20261126T174416Z_C03_observar.txt`.

### 5. ¿Por qué FORCE es un puente y no la solución? ¿Qué ve el DBA en V$SQL que lo delata?

`FORCE` permite reutilizar consultas aunque la aplicación siga enviando valores escritos directamente. Aun así, tarda 390 ms, frente a 280 ms con variables de enlace, y puede afectar a la elección del plan. Es una solución temporal hasta corregir la aplicación.

En `V$SQL` aparecen muchos identificadores de consulta distintos con una misma `FORCE_MATCHING_SIGNATURE`: en la prueba, la firma `14573098645096361820` se repitió en 690 SQL_ID.

**Evidencia:** `casos/20261126T174411Z_C03_diagnosticar.txt` y `casos/20261126T174414Z_C03_validar.txt`.

## Parte C · C04 · El informe que se desborda a TEMP

### 6. Bloques de TEMP, tipo de pasada y tiempo del informe antes y después. ¿Qué hacía el disparador de logon?

Antes, el informe tardaba 3.020 ms y usaba 5.456 bloques de TEMP, unos 42,6 MB. La ordenación se hacía en una pasada. El disparador cambiaba la memoria de trabajo a modo manual y la limitaba a 1 MB.

Al quitarlo, el informe completo tardó 1.120 ms y no utilizó TEMP: pudo ordenar en memoria.

**Evidencia:** `casos/20261126T174427Z_C04_provocar.txt`, `casos/20261126T174430Z_C04_diagnosticar.txt` y `casos/20261126T174436Z_C04_observar.txt`.

### 7. ¿Por qué el TOP 100 cabe en memoria y el informe completo no?

El TOP 100 solo necesita conservar los 100 resultados principales y tardó 150 ms, sin usar TEMP. El informe completo tiene que ordenar el millón de filas; necesita unos 48–64 MB y, con el límite de 1 MB, acaba usando TEMP.

**Evidencia:** `casos/20261126T174430Z_C04_diagnosticar.txt` y `casos/20261126T174436Z_C04_observar.txt`.

## Parte D · C07 · EXPLAIN PLAN frente al plan real

### 8. Copia el predicado que delata el problema en el plan real y explica de dónde sale.

El predicado es:

```sql
filter(TO_NUMBER("CODIGO_POSTAL")=:B1)
```

La columna `CODIGO_POSTAL` es de tipo texto, pero la aplicación enviaba el código como número. Oracle convertía la columna para poder comparar los valores. Por eso no podía aprovechar correctamente el índice y tenía que revisar toda la tabla.

**Evidencia:** `casos/20261126T174544Z_C07_diagnosticar.txt`.

### 9. Lecturas y p95 de V1 y V2. ¿Por qué EXPLAIN PLAN no lo vio?

V1 necesitó 5.227 lecturas por búsqueda y tuvo un p95 de 73,2 ms. V2 necesitó 95 lecturas y tuvo un p95 de 1,2 ms.

`EXPLAIN PLAN` no mostró el problema porque no ejecuta la consulta real ni utiliza el tipo de dato que llegaba en la variable. El plan real sí permitió ver la conversión que hacía Oracle.

**Evidencia:** `casos/20261126T174542Z_C07_entender.txt` y `casos/20261126T174547Z_C07_validar.txt`.

## Parte D · C08 · E-Rows frente a A-Rows

### 10. Estimación y filas reales antes y después del grupo de columnas. ¿En qué línea del plan se separan por primera vez?

Antes del cambio, en la línea 3 se estimaban 3 filas, pero salían 56. La línea 4 estaba bastante cerca: estimaba 50 y salían 56. Después del cambio, la línea 3 estimó 50 y obtuvo 56; en la línea 1 se estimaron 496 y salieron 599.

**Evidencia:** `casos/20261126T174558Z_C08_diagnosticar.txt`, `casos/20261126T174559Z_C08_solucionar.txt` y `casos/20261126T174601Z_C08_validar.txt`.

### 11. ¿Por qué el optimizador multiplicaba mal las dos selectividades?

Porque suponía que la ciudad y la comunidad no dependían una de otra. Calculaba unas 3 filas, pero cada ciudad pertenece a una sola comunidad. Al tener en cuenta las dos columnas juntas, la estimación pasó a 50 filas, mucho más cerca de las 56 reales.

**Evidencia:** `casos/20261126T174558Z_C08_diagnosticar.txt` y `casos/20261126T174559Z_C08_solucionar.txt`.

## Parte E · C12 · Estadísticas obsoletas

### 12. Filas según las estadísticas y reales; método de unión y lecturas antes y después.

Antes, las estadísticas indicaban 100 filas en CARRITO, pero realmente había 200.100. Se usaba una unión por bucles anidados y se hicieron 212.438 lecturas. Después de actualizar las estadísticas, se utilizó una unión HASH y las lecturas bajaron a 5.941, aproximadamente un 97 % menos.

**Evidencia:** `casos/20261126T174711Z_C12_entender.txt`, `casos/20261126T174713Z_C12_diagnosticar.txt` y `casos/20261126T174717Z_C12_validar.txt`.

### 13. ¿Por qué la tarea automática no lo habría arreglado a tiempo? ¿Quién debe recoger y cuándo?

La tarea automática solo se ejecuta durante la ventana de mantenimiento, que empezaba a las 22:00. Por eso, una carga nocturna podía dejar las estadísticas antiguas durante la mañana. Lo correcto es que el proceso que carga los datos actualice las estadísticas justo al terminar.

**Evidencia:** `casos/20261126T174718Z_C12_observar.txt`.

## Parte E · C13 · El ciclo de estadísticas con red

### 14. Describe el ciclo que seguiste (pendientes, probar, publicar, restaurar, bloquear) con la vista que comprueba cada paso.

Primero dejé las estadísticas como pendientes y comprobé el resultado en `DBA_TAB_PENDING_STATS`. Después las probé solo en mi sesión y revisé el plan. Cuando vi que la estimación mejoraba, las publiqué y comprobé el resultado en `DBA_TAB_STATISTICS` y `DBA_TAB_COL_STATISTICS`. También revisé el historial en `DBA_TAB_STATS_HISTORY`, restauré las anteriores y, por último, bloqueé las estadísticas y comprobé el bloqueo.

**Evidencia:** `casos/20261126T174740Z_C13_solucionar.txt`, `casos/20261126T174742Z_C13_validar.txt` y `casos/20261126T174747Z_C13_observar.txt`.

### 15. ¿Qué error obtuviste al recoger sobre estadísticas bloqueadas y cómo se recoge si de verdad hace falta?

El error fue `ORA-20005: object statistics are locked (stattype = ALL)`. Si hace falta recogerlas, se puede indicar `force => TRUE` o desbloquearlas primero, recogerlas y volver a bloquearlas.

**Evidencia:** `casos/20261126T174747Z_C13_observar.txt`.

## Parte E · C14 · El índice invisible

### 16. Lecturas por apertura del panel antes y después. ¿Cómo probaste el índice sin que lo viera nadie más?

Antes se hacían 5.266 lecturas por apertura y tardaba 23,1 ms. Después, con el índice, fueron 118 lecturas y 0,44 ms. Lo creé como invisible y activé su uso solo en mi sesión para probarlo. Así, las demás sesiones siguieron usando el plan anterior.

**Evidencia:** `casos/20261126T174755Z_C14_provocar.txt`, `casos/20261126T174802Z_C14_solucionar.txt` y `casos/20261126T174803Z_C14_validar.txt`.

### 17. Redo con el índice INVISIBLE y VISIBLE: ¿qué demuestra?

Al actualizar 20.000 pedidos se generaron 9.008 KB de redo sin el índice, 10.403 KB con él invisible y 10.402 KB cuando era visible. Esto demuestra que hacerlo invisible evita que otras sesiones lo usen, pero no evita el trabajo adicional al guardar cambios.

**Evidencia:** `casos/20261126T174807Z_C14_observar.txt`.

## Parte F · C17 · INC-604 con AWR, ASH y ADDM

### 18. SLI y SLO; p95 antes y después; instantáneas AWR que usaste.

El indicador que medí fue el tiempo de respuesta de la búsqueda por código postal. El objetivo era que el p95 estuviera por debajo de 20 ms. Antes, el p95 era de 98 ms; después del cambio bajó a 0,6 ms. Para comparar usé las instantáneas AWR 24 y 25.

**Evidencia:** `casos/20261126T175356Z_C17_entender.txt`, `casos/20261126T175644Z_C17_validar.txt` y `herramientas/20261126T175355Z_t6-base.txt`.

### 19. ¿Qué dijeron ASH, AWR y ADDM, y qué no podían decirte? ¿Cuál fue el ÚNICO cambio?

ASH mostró que la consulta pasaba mucho tiempo trabajando en CPU. AWR confirmó que se ejecutaba miles de veces y hacía 5.245 lecturas por ejecución. ADDM señaló el consumo de CPU y recomendó revisar la consulta. Ninguno explicaba por sí solo por qué se leían tantas filas: eso se vio en el plan. El único cambio fue que la aplicación llamara a `APP.BUSCAR_CP_V2`, enviando el código como texto.

**Evidencia:** `casos/20261126T175401Z_C17_diagnosticar.txt`, `casos/20261126T175435Z_C17_solucionar.txt` y `casos/20261126T175645Z_C17_observar.txt`.

## Parte F · C18 · SQL Plan Management

### 20. PLAN_HASH_VALUE y lecturas del lunes, del martes y con la línea base.

- Lunes: plan `1767728868`, 195 lecturas y 6,5 ms.
- Martes: plan `2571571058`, 5.227 lecturas y 24,9 ms.
- Con la línea base: plan `1767728868`, 188 lecturas y 12,3 ms.

La línea base permitió volver al plan que había funcionado el lunes.

**Evidencia:** `casos/20261126T175721Z_C18_entender.txt`, `casos/20261126T175726Z_C18_solucionar.txt` y `casos/20261126T175728Z_C18_validar.txt`.

### 21. ¿Qué hizo la evolución con el plan nuevo y por qué? ¿Qué queda pendiente para que no vuelva a pasar?

La evolución probó el plan nuevo, pero no lo aceptó porque no mejoraba el resultado del plan guardado. Así se mantuvo el plan anterior. Queda pendiente corregir la configuración que elimina el histograma de la columna ESTADO cuando se recogen las estadísticas.

**Evidencia:** `casos/20261126T175730Z_C18_observar.txt`.

## Parte G · Incidente 1 · INC-605 · El informe de cestas abandonadas tarda desde la carga de anoche

**Síntoma:** Las estadísticas decían que CESTA tenía 100 filas, pero había 208.100. El informe hacía 220.811 lecturas y tardaba 111,6 ms.

**Playbook y pasos:** Seguí PB-3, paso 2. Revisé las estadísticas, los cambios pendientes y el plan. Vi que las estadísticas estaban bloqueadas y desactualizadas.

**Causa:** La tabla tenía las estadísticas bloqueadas con el valor antiguo de 100 filas. La tarea automática no actualiza tablas bloqueadas.

**Arreglo aplicado:**

```sql
EXEC DBMS_STATS.GATHER_TABLE_STATS('T6', 'CESTA');
EXEC DBMS_STATS.UNLOCK_TABLE_STATS('T6', 'CESTA');
EXEC DBMS_STATS.GATHER_TABLE_STATS('T6', 'CESTA');
```

La primera recogida devolvió `ORA-20005` porque las estadísticas estaban bloqueadas. Después las desbloqueé y las actualicé.

**Verificación:** La comprobación terminó con 3 OK: 208.100 filas estimadas y reales, y unión HASH.

**Evidencia:** `incidentes/20261126T175853Z_INC-605_romper.txt`, `incidentes/20261126T175854Z_INC-605_verificar.txt`, `herramientas/20261126T175902Z_t6-estad.txt`, `herramientas/20261126T175921Z_t6-plan.txt` y `incidentes/20261126T175934Z_INC-605_verificar.txt`.

**Prevención:** Evitar bloquear las estadísticas de tablas que siguen creciendo. Revisar si están desactualizadas y actualizar las de las tablas de carga al terminar cada carga.

## Parte G · Incidente 2 · INC-608 · El informe por estado empeoró tras el mantenimiento nocturno

**Síntoma:** El informe del estado D estimaba 250.000 filas, aunque realmente había 28.007. La columna ESTADO no tenía histograma y se hacía una lectura completa de la tabla.

**Playbook y pasos:** Seguí PB-3, paso 2. Revisé las estadísticas y la configuración de la tabla. Encontré que se había indicado que no se crearan histogramas.

**Causa:** La configuración `METHOD_OPT = FOR ALL COLUMNS SIZE 1` quitaba el histograma de ESTADO cada vez que se recogían estadísticas.

**Arreglo aplicado:**

```sql
EXEC DBMS_STATS.SET_TABLE_PREFS('T6', 'PEDIDO', 'METHOD_OPT', 'FOR ALL COLUMNS SIZE 1 FOR COLUMNS ESTADO SIZE 254');
EXEC DBMS_STATS.SET_TABLE_PREFS('T6', 'PEDIDO', 'PUBLISH', 'FALSE');
EXEC DBMS_STATS.GATHER_TABLE_STATS('T6', 'PEDIDO');
ALTER SESSION SET optimizer_use_pending_statistics = TRUE;

EXPLAIN PLAN FOR
SELECT COUNT(*), SUM(importe), MAX(fecha_pedido)
FROM t6.pedido
WHERE estado = 'D';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(format => 'BASIC +ROWS +COST'));

ALTER SESSION SET optimizer_use_pending_statistics = FALSE;
EXEC DBMS_STATS.PUBLISH_PENDING_STATS('T6', 'PEDIDO');
EXEC DBMS_STATS.SET_TABLE_PREFS('T6', 'PEDIDO', 'PUBLISH', 'TRUE');
```

Primero preparé las estadísticas sin publicarlas, las probé en mi sesión y, al comprobar que el resultado era correcto, las publiqué.

**Verificación:** La comprobación terminó con 4 OK. La estimación fue de 28.007 filas, se creó el histograma FREQUENCY y la configuración lo conserva.

**Evidencia:** `incidentes/20261126T175948Z_INC-608_romper.txt`, `incidentes/20261126T175950Z_INC-608_verificar.txt`, `herramientas/20261126T175957Z_t6-estad.txt` y `incidentes/20261126T180019Z_INC-608_verificar.txt`.

**Prevención:** Revisar la configuración de las estadísticas después de cada mantenimiento y evitar que se elimine el histograma de ESTADO.

## Parte G · Incidente 3 · INC-610 · Muchas consultas cambiaron de plan a la vez en la PDB

**Síntoma:** Varias pantallas empezaron a ir lentas. La búsqueda por código postal pasó a leer toda la tabla, con el plan `2571571058`.

**Playbook y pasos:** Seguí PB-3, paso 3. Como varias consultas cambiaron a la vez, revisé los parámetros generales y los guardados para la PDB. Encontré `optimizer_index_cost_adj = 6600`.

**Causa:** El valor era 6600, cuando el valor normal es 100. Esto hacía que Oracle considerara demasiado caros los índices y eligiera leer las tablas completas.

**Arreglo aplicado:**

```sql
ALTER SYSTEM RESET optimizer_index_cost_adj SCOPE = BOTH;
```

Usé `RESET` para volver al valor predeterminado y quitar la configuración guardada, no solo cambiarla temporalmente.

**Verificación:** La comprobación terminó con 4 OK. El valor volvió a 100 y la búsqueda recuperó el plan `2982358210`, que utiliza el índice.

**Evidencia:** `incidentes/20261126T180034Z_INC-610_romper.txt`, `incidentes/20261126T180037Z_INC-610_verificar.txt` e `incidentes/20261126T180110Z_INC-610_verificar.txt`.

**Prevención:** No cambiar parámetros generales sin registrar y medir el cambio. Revisar periódicamente los parámetros modificados y guardar una comparación antes y después.

## Parte H · Reflexión

### 22. De todo el laboratorio, ¿qué cambio dio más mejora por menos riesgo? Justifícalo con tus números.

El cambio de la búsqueda por código postal fue el que más mejoró el resultado con un cambio pequeño. Al pasar de V1 a V2, el p95 bajó de 98 ms a 0,6 ms y las lecturas por ejecución pasaron de 5.245 a 94. Solo hubo que corregir el tipo de dato que enviaba la aplicación, sin cambiar la configuración general de la base de datos.

**Evidencia:** `casos/20261126T175356Z_C17_entender.txt`, `casos/20261126T175644Z_C17_validar.txt` y `casos/20261126T175645Z_C17_observar.txt`.

### 23. Un caso no evaluable (sin ★) que hayas hecho y qué aprendiste de él (opcional).

No he realizado ningún caso adicional sin ★.
