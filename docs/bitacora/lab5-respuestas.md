# Lab 5 — Respuestas

> **BORRADOR** preparado a partir de la evidencia real de `docs/bitacora/lab5/evidencia/`.
> Revísalo y reescríbelo con tus palabras antes de entregar.
> Abreviatura: `script/` = `docs/bitacora/lab5/evidencia/script/`.

## Preguntas de comprobación

### Punto de partida y banco de medida (A, B)

**1.** En mi repositorio, el paso 6 dice lo mismo en las dos copias: «ninguno: el volumen contiene toda la base de datos». Lo dicen tanto `docs/bitacora/lab4/evidencia/script/20261023T095355Z_00-backup-lab3.script.log` como `script/20261029T164604Z_00-backup-lab4.script.log`. En mi caso no hay diferencia, y la causa es el **orden** en que hice el Lab 4. Según `docs/bitacora/lab4/evidencia/script/20261023T094630Z_03-reubicar-datafiles.script.log`, a las 09:46:30 los cinco datafiles de negocio estaban **fuera del volumen**, en `/opt/oracle/product/26ai/dbhomeFree/dbs/` (academia01, clinica01, fintech01, logistica01 y retail01), y se movieron dentro de `/opt/oracle/oradata/FREE/FREEPDB1/`. La copia lab3-final se hizo después, a las 09:53:55. Por eso ya no vio ningún archivo fuera. La segunda ejecución de la reubicación (10:04:26) lo confirma: «Nada que reubicar».

Lo que demuestra la comparación es lo mismo que pretende el PDF. Antes de la reubicación, una copia del volumen **no** habría incluido esos cinco datafiles, porque vivían en el contenedor y no en el volumen. Después, la copia lab4-final es autosuficiente: restaurar el volumen basta para recuperar toda la base. El simulacro C lo probó al restaurar lab5-pre-simulacro y recuperar las 60 000 matrículas.

Lección: la copia lab3-final no es una foto real del estado del Lab 3. Una copia de seguridad hay que hacerla **antes** de cambiar nada.

**2.** Lo saco de `script/20261029T171506Z_01-perfil-tiendasur.script.log`, sección 1. CLIENTE tiene r = 100 000 filas en b = 1517 bloques, con R = 102 bytes por fila, así que bfr = 66. PEDIDO tiene r = 1 000 000 filas en b = 5320 bloques, con R = 32 bytes, así que bfr = 188. PEDIDO cabe casi el triple por bloque porque su fila mide un tercio: solo tiene números, una fecha y códigos cortos, mientras que CLIENTE lleva nombre, apellidos, email y DNI. Comprobación: ⌈1 000 000 / 188⌉ = 5320, que coincide con lo medido. En CLIENTE, ⌈100 000 / 66⌉ = 1516 frente a los 1517 medidos, porque bfr es una media.

**3.** La primera ejecución incluye el análisis (hard parse) y carga los bloques en la caché, y ese coste no se repite en el uso normal. La segunda mide el trabajo estable, en caliente. Por eso `prueba_pk` da 4 lecturas lógicas y 0 físicas (`script/20261029T171507Z_01-herramienta-medir.script.log`).

### Anatomía y tipos de índice (C, D)

**4.** Según `script/20261029T171553Z_02-anatomia-indice.script.log`, sección 2, IX_PED_CLIENTE tiene altura 3, 2216 hojas y 6 ramas. Su factor de ramificación real es (2216 + 6 − 1) / 6 = 370 y el máximo es 543. Con mil millones de filas tendría unas 2 208 969 hojas y altura 4, es decir, 5 lecturas para encontrar una fila. Es la tabla que calcula el propio script.

**5.** La hoja de PK_CLIENTE (mismo log, bloque [B]) tiene esta entrada: `row#0[1200] ... data:(6): 00 00 03 1b 00 00`, con la clave `c1 02`, que es el número 1. El ROWID se descompone así: 4 bytes de bloque `00 00 03 1b`, que son 0x31B = 795, y 2 bytes de fila `00 00`, que es la ranura 0. La consulta de comprobación lo confirma: ID_CLIENTE 1, BLOQUE 795, RANURA 0. No aparece el número de archivo porque TBS_TIENDASUR es un tablespace BIGFILE: tiene un único datafile y el índice guarda un ROWID «corto» de 6 bytes. La misma hoja muestra `kdxconro 578` y `kdxcoavs 8`: 578 entradas y solo 8 bytes libres.

**6.** Datos de `script/20261029T172336Z_03-tipos-indice.script.log`:
- **Único (Q13):** baja de 1486 a 3 lecturas. Sin índice se recorre CLIENTE entera; con UNIQUE basta bajar por el árbol hasta una sola hoja. Además, la base rechaza el duplicado con ORA-00001.
- **Cubriente (Q7):** 15 lecturas con ix_ped_cliente, 7 con (id_cliente, fecha) y 3 con el cubriente. Al tener todas las columnas pedidas en el índice, no hace falta visitar la tabla.
- **Bitmap (Q14):** baja de 4073 a 528 lecturas. Los cuatro mapas de bits se combinan con AND antes de tocar la tabla, algo que un B-tree por columna no puede hacer de forma barata.

### Agrupamiento, equilibrio y sargabilidad (E, F)

**7.** Según `script/20261029T172426Z_04-agrupamiento-equilibrio.script.log`, IX_PED_FECHA tiene CF = 5220 (la tabla tiene 5320 bloques) e IX_PED_CLIENTE tiene CF = 999 041 (la tabla tiene 1 000 000 de filas). Los pedidos se cargaron en orden de fecha, así que fechas vecinas están en bloques vecinos. En cambio, id_cliente se repartió al azar, y cada entrada del índice salta a otro bloque. Un REBUILD no lo arreglaría: el CF depende del orden de las filas en la tabla, no del índice. Habría que reordenar la tabla.

**8.** En la curva medida (sección 3 del mismo log), el índice con CF malo deja de compensar entre el 0,1 % (975 lecturas frente a 5232) y el 0,2 % (2004 frente a 5232). Con el 1 % ya lee 9920, casi el doble que la tabla. El índice con CF bueno aguanta hasta el 50 % (3938 lecturas frente a 5232) y solo pierde al 100 % (7875). La fórmula de la Unidad 3 da k/r < 1/188 = 0,53 % en lecturas lógicas y 0,11 % en disco. El dato medido queda dentro de ese rango.

**9.** Según `script/20261029T172455Z_05-sargabilidad.script.log`, Q4b (`LIKE 'Gonz%'`) usa INDEX RANGE SCAN IX_CLI_APELLIDOS y aun así lee 2024 bloques, más que el recorrido completo de CLIENTE (≈ 1486). El motivo es que devuelve 2056 filas (el 2 %) y el índice tiene un CF malo para apellidos: casi cada fila es un bloque de tabla distinto. Es sargable, pero el 2 % ya está por encima del punto de equilibrio.

### Coste de escritura y mantenimiento (G, H)

**10.** Según `script/20261029T172510Z_06-indices.script.log`, cada INSERT modifica estos bloques por fila: hoy (4 índices + PK) **10,2**; con la propuesta del compañero (9) **20,2**; con V005 (5) **12,3**. De la propuesta rechacé:
- IX_PED_ESTADO e IX_PED_CANAL, por no ser viables para igualdad: 4 y 3 claves distintas, con un 25 % y un 33 % de la tabla por valor, muy por encima del 0,5 %. IX_PED_CANAL además no lo usaba la carga habitual (USADO = NO).
- IX_PED_FEC_CLI, porque nadie lo usaba.

Acepté IX_PED_CP (Q3: 106 lecturas) y la idea de IX_PED_CLI_FEC, que en V005 se convierte en el cubriente. Esto deja redundante a IX_PED_CLIENTE, que se borra. IX_PED_IMPORTE se probó como INVISIBLE: Q2 siguió en 329 lecturas, así que también se borra.

**11.** Gráficos de `script/*_07a-grafico-*.script.log` y `*_07b/07c-grafico-IX_COLA-*.script.log`:
- **50/50:** IX_AZAR, con un mapa irregular de `-` y `=` (hojas entre el 50 y el 90 %). Tuvo 595 divisiones, ninguna 90/10.
- **90/10:** IX_CRECIENTE, con el mapa entero en `#` (≥ 90 %). Tuvo 398 divisiones, todas 90/10.
- **Patrón cola:** IX_COLA antes del remedio, con la mitad izquierda vacía (espacios) y la derecha llena: `[                                =####...]`.

**12.** Elegiría **COALESCE**. En `script/20261029T172544Z_07c-remedios.script.log` bajó de 425 a 201 hojas, de 70 245 entradas borradas a 0, y la siguiente lectura pasó de 226 a 2. Además es en línea, sin bloqueo y con poco redo. SHRINK SPACE también devuelve espacio, pero mueve más. REBUILD ONLINE necesita el doble de espacio y genera mucho redo. La cura definitiva es de diseño: particionar por fecha.

### SCN, control files, redo y FRA (I a L)

**13.** Compara el SCN de checkpoint de cada datafile en el control file (`v$datafile.checkpoint_change#`) con el de la cabecera del propio archivo (`v$datafile_header`). En `script/20261029T172622Z_08-scn-checkpoint.script.log`, tras el CHECKPOINT los dos valen 4258524 en system01, sysaux01 y academia01. Si coinciden, no hace falta recuperación. PDB$SEED se queda en 2098101 porque es de solo lectura.

**14.** Protege de borrar o corromper **un archivo**: quedan otras dos copias idénticas, y así se ve en `script/20261029T172653Z_09-multiplexar-controlfile.script.log`, con control01, 02 y 03. No protege de perder el **disco o volumen**, porque las tres copias comparten volumen. En producción, cada copia va en un disco o controlador distinto (o en grupos de discos ASM distintos), y además se hace una copia de seguridad del control file con RMAN.

**15.** Lo muestra `script/20261029T172734Z_10-redo.script.log`:
- **CURRENT:** es el grupo en el que LGWR está escribiendo.
- **ACTIVE:** ya no se escribe en él, pero contiene cambios que aún harían falta para recuperar la instancia, porque su checkpoint no ha terminado.
- **INACTIVE:** se puede reutilizar.

Oracle rechazó los tres borrados del paso 4:
- 4a, ORA-01623: no se puede borrar el grupo CURRENT.
- 4b, ORA-01609: no se puede quitar un miembro del grupo CURRENT.
- 4c, ORA-01624: el grupo 1 estaba ACTIVE y hacía falta para recuperar la instancia.

Mi base tiene 3 grupos, no 2 como en el PDF. Por eso el error de 4c fue ORA-01624 y no ORA-01567 (ver `script/20261029T172744Z_10-nota-tres-grupos.script.log`).

**16.** La cadena, según `script/20261029T172803Z_11-fra-llena.script.log`:
1. La FRA se reduce a 2 MB y aparece ORA-19815 en el alert log: «100.00% used».
2. ARCn intenta archivar el grupo 1 y falla con ORA-19809 (límite superado) y ORA-16038 (el log no se puede archivar).
3. El grupo 1 queda `ARC = NO` y no se puede reutilizar.
4. Cuando el redo da la vuelta y necesita ese grupo, las sesiones esperan en «log file switch (archiving needed)» y las conexiones nuevas reciben ORA-00257.

Al devolver los 4 GB, ARCn archivó solo y los grupos 1 y 2 pasaron a `ARC = YES`.

### Undo, WAL y simulacros (M a P)

**17.** Según `script/20261029T172818Z_12-lectura-consistente.script.log`:
- La sesión A cambia la fila 101 a EGRESADO sin confirmar.
- Paso 1: B lee la fila sin esperar y ve **ACTIVO**, el valor confirmado, reconstruido con el undo.
- Paso 2: la transacción de A ya ocupa 1 bloque de undo.
- Paso 3: A tiene un bloqueo TM modo 3 y TX modo 6.
- Paso 4: B solo choca (ORA-00054) cuando intenta **bloquear** la fila con FOR UPDATE.

Es decir: leer no espera a quien escribe, y escribir no espera a quien lee.

**18.** Según `script/20261029T172854Z_12-undo-y-redo.script.log`, 10 000 filas generan este undo: INSERT 143 bloques, UPDATE 158 y DELETE 427. Para deshacer un INSERT basta con guardar «borra este ROWID». Para deshacer un DELETE hay que guardar la fila entera y sus entradas de índice. El ROLLBACK también genera redo (354 KB, 2470 KB y 4701 KB) porque deshacer es aplicar cambios a bloques, y todo cambio a un bloque se protege con redo.

**19.** Según `script/20261029T172902Z_13-lgwr-dbwn.script.log`: tras el COMMIT, LGWR había escrito 6240 KB de redo y DBWn 0 bloques, con 231 bloques sucios aún en memoria. La garantía de durabilidad está en el **redo log online**. Tras el CHECKPOINT, DBWn escribió 523 bloques y quedaron 0 sucios: ahora el dato también está en los **datafiles**, y ese redo ya no hace falta para recuperar la instancia.

**20.** Lo cuenta `script/20261029T182146Z_14a-caida-instancia.script.log`. Antes del SHUTDOWN ABORT, la fila 102 pasó a EGRESADO con COMMIT y la 103 a INACTIVO sin confirmar. Al arrancar, el alert log muestra los dos pasos:
- **Roll forward:** «Beginning crash recovery», «Recovery starting at checkpoint rba (logseq 18 block 94735)», «read 2144 KB redo, 166 data blocks need recovery» y «Completed redo application of 0.59MB». SMON rehizo desde el último checkpoint todos los cambios que no habían llegado a los datafiles, incluidos los de la 103 y los de su undo.
- **Roll back:** con ese undo deshizo lo no confirmado. Resultado: 102 = EGRESADO (durabilidad) y 103 = ACTIVO (atomicidad).

Nadie intervino: bastó un STARTUP y la base estaba *healthy* en t=0 s tras arrancar. RPO = 0.

**21.**
- **Simulacro C** (`script/20261029T183351Z_14c-simulacro-restauracion.script.log`): RTO = **64 s** restaurando la copia completa de 1,3 GB. RPO = **2 s**, todo lo hecho entre la copia y el fallo.
- **Simulacro D** (`script/20261029T183441Z_14d-perdida-datafile.script.log`): RTO = **10 s** con RMAN, restaurando solo el datafile 16 y aplicando el redo. RPO = **0**: la fila 104, cambiada después de la copia, sobrevivió como EGRESADO.

Son tan distintos porque en C se restaura **toda** la base desde una copia en frío y se pierde lo posterior, ya que no se aplica redo. En D solo se restaura **un archivo**, y RECOVER lo trae al presente con el redo archivado y el online. El RTO de C crece con el tamaño de la base; su RPO, con el tiempo transcurrido desde la última copia. En un caso real, con horas entre copia y fallo, el RPO de C serían horas de datos perdidos. En D, el RTO afectó a toda FREEPDB1 porque Oracle cerró la PDB (ORA-63999).

**22.** Clasificación de los errores del bloque 5 de `script/20261029T175456Z_15-healthcheck.script.log`:

| Error | Clasificación | Motivo |
|---|---|---|
| ORA-19809, ORA-19815 (17:28) | Efecto del laboratorio | Escenario de FRA llena de la Parte L |
| ORA-1623, ORA-1609, ORA-1624 (17:27) | Efecto del laboratorio | Borrados de redo rechazados a propósito en la Parte K |
| ORA-00800 «Set Priority Failed» [LGWR] [VKTM] | Ruido conocido | El contenedor Docker no permite a Oracle subir la prioridad de esos procesos; aparece en cada arranque y no afecta a los datos |
| ORA-00202, ORA-205 (18:25) | Efecto del laboratorio | Simulacro B: control03.ctl borrado a propósito |
| ORA-63999, ORA-01110 file 16 (18:34) | Efecto del laboratorio | Simulacro D: academia01.dbf borrado a propósito |
| ORA-01113 file 21 (18:34:30) | Efecto del laboratorio | Simulacro D, ver detalle debajo |
| Incidentes reales | Ninguno | — |

La tabla se basa en `script/20261029T183516Z_15-healthcheck-tras-simulacros.script.log`, que repite el runbook después de los simulacros.

**Detalle del ORA-01113 del fichero 21.** El fichero 21 es `tiendasur01.dbf`. El alert log (`v$diag_alert_ext`, 18:34:15-18:34:45) cuenta la secuencia:
1. 18:34:21: CKPT detecta ORA-63999 sobre el datafile 16 y Oracle cierra FREEPDB1 de golpe (18:34:22). Al no haber checkpoint final, el resto de sus datafiles (12 a 21) quedan *fuzzy*, como tras un SHUTDOWN ABORT pero a nivel de PDB.
2. 18:34:27-29: RMAN restaura el 16 y RECOVER le aplica el redo (secuencias 19 y 20).
3. 18:34:30: `ALTER PLUGGABLE DATABASE FREEPDB1 OPEN` encuentra el fichero 21 sin recuperar (ORA-01113). Oracle lanza **solo** una recuperación de medios con el redo online sobre los ficheros 12 a 21 («Recovering data file 21 … 12») y abre READ WRITE a las 18:34:31.

No es un incidente: después, `v$recover_file` está vacío, el fichero 21 está ONLINE y TiendaSur conserva sus 1 000 000 de pedidos y 100 000 clientes. Es la misma idea que el simulacro A, aplicada a una PDB.

## Tabla RTO / RPO de los simulacros

| Simulacro | Fallo | RTO medido | RPO real |
|---|---|---|---|
| A | Caída de la instancia (SHUTDOWN ABORT) | Lo que tarda el STARTUP; *healthy* en t=0 s tras arrancar | **0** (102 confirmada sobrevive) |
| B | Pérdida de un control file | Minutos de diagnóstico manual; el script lo resolvió al momento (*healthy* t=0 s) | **0** |
| C | DROP TABLE ... PURGE + restauración completa | **64 s** | **2 s** (todo lo posterior a la copia) |
| D | Pérdida de un datafile (RMAN) | **10 s** (toda FREEPDB1, por ORA-63999) | **0** (104 posterior a la copia sobrevive) |

Además, en C el DROP **sin** PURGE se resolvió con FLASHBACK TABLE ... TO BEFORE DROP en segundos y sin pérdida (60 000 matrículas).

## Retrospectiva sin culpables (game day)

**Qué pasó:** los cuatro simulacros terminaron con la base abierta y los datos confirmados intactos. Solo se perdió lo que el diseño de C pierde a propósito: 2 s.

**Qué sorprendió:**
- En D, Oracle **cerró la PDB entera** (ORA-63999) en vez de dejar solo el tablespace fuera de línea. El RTO afectó a todo FREEPDB1, no solo a ACADEMIA. Además, al reabrirla, tuvo que recuperar con el redo los demás datafiles de la PDB (ORA-01113 del fichero 21): perder un archivo afectó a la PDB completa.
- La copia previa del simulacro C ocupa 1,3 GB, frente a los 551 MB de lab4-final. El banco TiendaSur y la FRA multiplican el tamaño, y con él el RTO de una restauración completa.
- La distancia entre C y D: 64 s con RPO 2 s frente a 10 s con RPO 0. Con ARCHIVELOG más una copia RMAN se recupera más rápido **y** sin pérdida.
- La recuperación de instancia de A fue invisible: un STARTUP normal y nada más.

**Qué cambiaría:**
- Hacer la copia de partida **antes** de tocar nada. En el Lab 4, la reubicación se ejecutó 7 minutos antes que la copia lab3-final (ver respuesta 1).
- Separar las copias del control file y los miembros de redo en volúmenes distintos. Aquí comparten volumen y no protegen de perder el disco.
- Programar copias RMAN periódicas. Antes del simulacro D, el bloque 7 del runbook estaba vacío: no había ninguna copia.
- Lanzar los simulacros largos (C) con un límite de tiempo mayor. Al hacerlo desde Claude Code pasó a segundo plano a los 120 s, y no hay que interrumpirlo nunca.

**Incidencias del procedimiento:**
- La base llegó al Lab 5 ya en ARCHIVELOG, pero sin FRA: los primeros archivados (`arch1_12…`, `arch1_13…`) se escribieron fuera de la FRA.
- C##OPS_RO no podía leer el alert log (ORA-00942 en el bloque 5). Se corrigió con `scripts/lab4/11-ampliar-ops-ro.sql`.
- Hay 3 grupos de redo en lugar de 2: ver la respuesta 15.

## Preguntas tipo examen de cada parte (letra + una frase)

**B1. B.** Sin histograma, el optimizador supone el mismo reparto para todos los valores (25 000 filas) aunque la columna está sesgada (20 reales).
**C1. C.** BLEVEL 2 significa altura 3: 3 lecturas de índice y 1 de tabla, total 4. Lo mismo medí en PK_PEDIDO (Parte C).
**C2. C.** ⌈log₅₀₀ 2 000 000⌉ = 3 niveles por encima de las hojas, así que la altura es 1 + 3 = 4.
**D1. B.** Hay pocas claves distintas, la carga es nocturna y los filtros se combinan libremente: bitmaps por columna, que se combinan con AND (Q14: 4073 → 528).
**D2. A y C.** Evita ir a la tabla (Q7: 3 lecturas), pero cada escritura de sus columnas lo mantiene. Oracle no tiene cláusula INCLUDE.
**E1. B.** Con CF ≈ filas, el 3 % de 10 M son 300 000 lecturas aleatorias frente a 80 000 bloques secuenciales. REBUILD no cambia el CF.
**F1. B.** Comparar VARCHAR2 con un número aplica TO_NUMBER a la columna (Q3: 5232 → 106 al escribir el literal como texto).
**F2. A y C.** Son rangos sobre la columna desnuda. D aplica una función y E hace aritmética sobre la columna.
**G1. B.** INVISIBLE: el optimizador lo ignora pero se sigue manteniendo, y ALTER INDEX ... VISIBLE lo devuelve al instante.
**G2. B.** Cada índice suma unos 2 bloques por INSERT; 500 × 2 = 1000.
**H1. B.** COALESCE fusiona las hojas vacías de la izquierda en línea (la lectura pasó de 226 a 2 en la Parte H).
**H2. A y C.** Reparte la hoja caliente, pero rompe el orden: el rango sobre IX_INVERTIDA hizo un recorrido completo (878 lecturas frente a 4).
**I1. B.** El SCN de checkpoint del control file frente al de la cabecera de cada datafile (Parte I).
**J1. B.** Si cualquier copia falla, la instancia se detiene. Se repara copiando una copia sana o quitándola de CONTROL_FILES.
**J2. A y C.** La estructura física (datafiles y redo) y el SCN de checkpoint. Los parámetros están en el SPFILE.
**K1. C.** Un grupo ACTIVE aún hace falta para recuperar la instancia (en la Parte K, ORA-01624 al intentar borrarlo).
**L1. B.** Primero hay que fijar DB_RECOVERY_FILE_DEST_SIZE (ORA-19802 en el paso 2 de la Parte L).
**L2. A y C.** Dar espacio a la FRA o hacer copia de los archivados y borrarlos con RMAN. Nunca rm.
**M1. C.** Lectura consistente con el undo: B vio ACTIVO (Parte M, paso 1).
**M2. C.** DELETE guarda la fila entera (427 bloques de undo frente a 143 del INSERT).
**M3. B y D.** Más retención y más undo, y RETENTION GUARANTEE si la consulta es crítica.
**N1. A.** COMMIT espera a que LGWR escriba el redo; DBWn había escrito 0 bloques en ese momento (Parte N).
**N2. B y C.** En el checkpoint (523 bloques en la Parte N) y cuando un proceso servidor no encuentra buffers libres.
**O1. B.** SMON hace la recuperación de instancia sin intervención (simulacro A: 166 bloques rehechos y la fila 103 deshecha).
**O2. B y D.** Copiar una copia sana (simulacro B, con control01 → control03), o quitar la perdida de CONTROL_FILES.
**O3. B.** OFFLINE, RESTORE, RECOVER y ONLINE del datafile con la base abierta (simulacro D: RTO 10 s, RPO 0).
**O4. D.** RMAN RECOVER TABLE: tras un PURGE no hay papelera, y restaurar toda la base perdería el trabajo de las demás tablas.

## Simulacro de examen 1Z0-182 (letra + Parte)

**S1. B** — Parte E (CF ≈ filas: casi un bloque por fila).
**S2. A y C** — Partes D y F (índice funcional; o escribir el literal en el formato guardado).
**S3. B** — Parte F, regla 3.
**S4. B** — Parte D, Q14.
**S5. B** — Parte D, Q6 «solo ciudad» (salto del prefijo con pocas claves en PAIS).
**S6. B** — Parte G, pregunta 5 del protocolo.
**S7. A y C** — Parte H, remedios en línea.
**S8. B** — Parte H, IX_INVERTIDA.
**S9. C** — Parte G: un UPDATE de una columna no indexada modifica 2 bloques por fila sea cual sea el número de índices.
**S10. B** — Parte C, factor de ramificación.
**S11. A y C** — Parte D, Q15 IOT (3 lecturas frente a 4).
**S12. B** — Parte I.
**S13. C** — Parte I: CKPT actualiza el control file y las cabeceras.
**S14. B y E** — Lab 4, arranque por etapas: en NOMOUNT solo hay vistas en memoria.
**S15. B** — Parte L (script 11, paso 4).
**S16. B** — Parte K: CLEAR LOGFILE recrea un grupo inactivo y ya archivado.
**S17. A y C** — Parte M, pasos 1 y 6.
**S18. B** — Parte M.2.
**S19. A** — Parte N.
**S20. A** — Parte I, bloque 4 (MTTR estimado).
**S21. B** — Parte L.2.
**S22. B** — Parte O, simulacro D: primero aislar el archivo.
**S23. B** — Parte O (teoría): SYSTEM no puede ponerse OFFLINE con la base abierta.
**S24. B** — Parte O / Unidad 3: sin redo archivado solo queda la copia en frío.
**S25. B y D** — Parte M.
**S26. A** — Parte L (script 11, paso 5).
