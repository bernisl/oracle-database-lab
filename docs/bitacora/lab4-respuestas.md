# Lab 4 — Respuestas

> Los valores entre `[COMPLETA: ...]` hay que sustituirlos por el dato real de tu evidencia.

## Preguntas tipo examen (letra + una frase de justificación)

**P1.** Respuesta: **A y D.**
Tras SHUTDOWN IMMEDIATE la base se cierra con un checkpoint: todos los archivos quedan en el mismo SCN, así que la copia es consistente, no necesita recuperación con redo y se puede restaurar y abrir directamente con STARTUP. No exige ARCHIVELOG (B), no pierde transacciones confirmadas (C) y no hace falta RMAN (E).

**P2.** Respuesta: **B.**
En Standard Edition no hay movimiento en línea; se pone el tablespace OFFLINE, se copia el archivo con el SO, se hace RENAME DATAFILE (que solo actualiza el control file) y se vuelve a ONLINE. RENAME no copia nada (C) y ABORT es innecesario y peligroso (D).

**P3.** Respuesta: **A y C.**
STARTUP_TIME es de la instancia y cambia en cada arranque; CREATED de v$database es la fecha de creación de la base, que no cambia al reiniciar. El DBID no cambia al recrear el contenedor, porque la base vive en el volumen (B); una instancia monta una sola base (D); v$database se consulta ya en MOUNT (E).

**P4.** Respuesta: **A y C.**
En NOMOUNT solo existe la instancia: se pueden consultar vistas v$ que leen de memoria (v$parameter) y recrear el control file con CREATE CONTROLFILE. dba_users necesita la base abierta (B); cambiar a ARCHIVELOG y renombrar datafiles exigen MOUNT (D, E).

**P5.** Respuesta: **B.**
ALTER DATABASE ARCHIVELOG solo se puede ejecutar con la base en MOUNT (no abierta).

**P6.** Respuesta: **B.**
Con la instancia arrancada con SPFILE, el SCOPE por defecto es BOTH: cambia la memoria y persiste en el SPFILE.

**P7.** Respuesta: **C.**
PROCESSES no se puede modificar desde una PDB; la sentencia falla con ORA-65040 ("operación no permitida desde una base de datos conectable"), aunque el SCOPE sea SPFILE.

**P8.** Respuesta: **A y C.**
Se arranca con un PFILE bueno (STARTUP PFILE=...) y después se regenera el SPFILE con CREATE SPFILE FROM PFILE. RESET con SCOPE=MEMORY (B) necesita la instancia levantada; RESETLOGS (D) y ABORT (E) no arreglan un parámetro.

**P9.** Respuesta: **B.**
Con MEMORY_TARGET = 0 y SGA_TARGET fijado se usa ASMM: la SGA se autoajusta y DB_CACHE_SIZE actúa como mínimo, no como valor fijo. AMM (C) requiere MEMORY_TARGET > 0 y DB_CACHE_SIZE no se ignora (D).

**P10.** Respuesta: **A y D.**
La PGA contiene las áreas de trabajo (sort area de un ORDER BY) y la memoria de sesión en servidor dedicado. Shared pool, log buffer y buffer cache son parte de la SGA.

**P11.** Respuesta: **C.**
El COMMIT no devuelve el control hasta que LGWR escribe el redo en los redo logs online (write-ahead logging); DBWn escribe los bloques de datos después, de forma diferida.

**P12.** Respuesta: **B y D.**
PMON y SMON son obligatorios (junto con DBWn, LGWR y CKPT). ARC0 solo existe en ARCHIVELOG, RECO si hay transacciones distribuidas y CJQ0 si hay jobs.

## Preguntas de comprobación

### Respaldo

1. La copia es consistente porque se tomó tras `SHUTDOWN IMMEDIATE` y parar el contenedor: todos los datafiles, control files y redo logs están en el mismo SCN y sin transacciones a medias, así que arranca sin recuperación. Evidencia: `manifiesto.txt` (`tipo=copia en frio consistente (SHUTDOWN IMMEDIATE)`). Si se hubiera copiado con la base abierta, cada archivo se copiaría en un instante distinto (copia "fuzzy"), con SCN incoherentes y bloques a medio escribir; al restaurarla no abriría sin recuperación, y en este flujo (copia de archivos sin RMAN) no sería fiable.

2. `manifiesto.txt` documenta qué contiene la copia (etiqueta, fecha UTC, contenedor, volumen, imagen, commit de git, tipo de copia y `archivos_fuera_del_volumen=0`). `SHA256SUMS` permite comprobar que `volumen.tar.gz`, `extras.lst`, `inventario.txt` y el propio manifiesto no se han corrompido ni alterado (`sha256sum --check` dio OK en los cuatro). `restaurar-estado.sh` [COMPLETA: revisa con `head -n 40 scripts/ops/restaurar-estado.sh` qué valida antes de parar el contenedor; lo esperable es que verifique la existencia de la carpeta y los checksums antes de tocar el volumen].

3. RPO: el máximo de datos que se pierden al restaurar; con esta copia en frío es todo lo ocurrido desde la copia (`20261023T095528Z`), porque no hay redo archivado posterior en el backup. RTO: el tiempo hasta volver a servir; la copia (530 MB comprimidos de ~4,9 GB de volumen) tardó unos 2 minutos (11:53 a 11:55) y la base abrió en ~10 s tras recrear el contenedor, así que el RTO estimado es de unos pocos minutos [COMPLETA: cronometra una restauración real si puedes].

### Diagnóstico y correcciones

4. V000 creó `academia01.dbf` y los demás con una ruta **relativa** (`DATAFILE 'academia01.dbf'`). Oracle los colocó relativos a `$ORACLE_HOME/dbs`, que es un enlace simbólico a `/opt/oracle/oradata/dbconfig/FREE/dbs`: dentro del volumen, pero en una carpeta no estándar, y no en `FREE/FREEPDB1/`. Habría evitado el problema una ruta absoluta o definir `db_create_file_dest` (OMF), que en el diagnóstico (apartado 5) estaba vacío. Evidencia: diagnóstico inicial y log de reubicación [COMPLETA: nombre del archivo y las rutas antiguas].

5. `RENAME DATAFILE` solo cambia la referencia en el control file; no copia ni mueve el archivo físico. Hay que poner el tablespace OFFLINE, copiar el archivo con el SO a la nueva ruta, ejecutar RENAME y volver a ponerlo ONLINE.

6. Las migraciones son un historial versionado e inmutable: editar V000, ya aplicada, rompe la trazabilidad y la reproducibilidad. Por eso los cambios van en una migración nueva (V003). Y la contraseña ya está en el historial de Git, así que borrarla del archivo no la elimina; invalidarla (`admin_*` pasan a cuentas de esquema, `AUTHENTICATION_TYPE = NONE`) neutraliza el secreto filtrado.

7. Demuestra que los datos y datafiles viven en el volumen `oralab-26ai-data`, no en el contenedor: se borró el contenedor, se recreó y los mismos tablespaces y tablas (`ADMIN_ACADEMIA` 3, `ADMIN_CLINICA` 3, `ADMIN_LOGISTICA` 2, `ADMIN_RETAIL` 3) seguían allí, con la base abierta a los 10 s. Se ejecuta después de reubicar para validar el estado final corregido.

### Instancia y arranque

8. Instancia (v$instance): `INSTANCE_NAME = FREE`, `HOST_NAME = d381faffa01e`, `STARTUP_TIME = 2026-10-23 09:55`. Base de datos (v$database): `NAME = FREE`, `LOG_MODE = ARCHIVELOG`, `CDB = YES` (más `OPEN_MODE`, `DBID` y `CREATED`) [COMPLETA: añade el nombre del archivo de evidencia 05].

9. NOMOUNT: lee el SPFILE/parámetros, reserva la SGA y arranca los procesos de background; MOUNT: abre el control file y conoce la estructura de la base; OPEN: abre datafiles y redo logs. ORA-01507 ("database not mounted") aparece si pides algo que necesita el control file estando en NOMOUNT; ORA-01219 ("database not open") si consultas vistas del diccionario (`dba_*`) estando en MOUNT.

10. Porque el estado de la PDB se guardó con `ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE`, y la verificación final lo comprueba (`FREEPDB1 abierta`). Si no lo hiciera, la abriría con `ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;` y repetiría `SAVE STATE`.

11. [COMPLETA: lee tu alert log (`06-alert-log.script.log`)]. Como criterio: ORA-00800 es típicamente ruido conocido en contenedores (soft external error, por ejemplo no poder fijar la prioridad del proceso por falta de privilegios), sin impacto en la base; ORA-20013 depende del texto que acompañe en tu log. Una alerta real afecta a la disponibilidad o a los datos; el ruido se repite sin consecuencias.

### Parámetros

12. `v$parameter` muestra el valor vigente en la instancia (memoria); `v$spparameter` muestra lo guardado en el SPFILE. Con `db_files`: tras `SCOPE = SPFILE` el SPFILE tiene un valor pendiente (`isspecified = TRUE`) mientras `v$parameter` conserva el actual hasta reiniciar; tras el RESET vuelve a `isspecified = FALSE`, que es lo que verifica el script 10.

13. `SCOPE = BOTH` cambia el valor en memoria y lo persiste en el SPFILE. Con una instancia arrancada con SPFILE, el SCOPE por defecto es `BOTH`.

14. Porque PROCESSES es un parámetro **estático** (no modificable en caliente en la instancia) y además no es modificable desde una PDB (`ISPDB_MODIFIABLE = FALSE`), de ahí ORA-65040 / ORA-02095. [COMPLETA: contrasta con las columnas `ISSYS_MODIFIABLE` e `ISPDB_MODIFIABLE` de tu evidencia 07 por si `v$parameter` lo muestra distinto].

15. Un PFILE de texto, versionado en Git (`config/initFREE_lab4.ora`), documenta la configuración esperada y permite hacer diff y reconstruir el SPFILE (`CREATE SPFILE FROM PFILE`). "Configuration drift" es que la configuración real diverja poco a poco de la declarada por cambios manuales; versionarla permite detectarlo y revertirlo.

### Memoria y procesos

16. ASMM: `memory_target = 0`, `sga_target > 0` y `pga_aggregate_target > 0` (gestión automática de la SGA, PGA aparte) [COMPLETA: los valores reales de `08-memoria.sql`].

17. Ronda 1: [COMPLETA] lecturas lógicas y [COMPLETA] físicas (>0, el bloque se lee de disco); ronda 2: [COMPLETA] lógicas y 0 físicas (todo sale del buffer cache). Tasa de acierto de la ronda 2 = 1 − físicas/lógicas = 1 − 0/[COMPLETA] = 100 %.

18. Cada proceso Oracle mapea la SGA (memoria compartida) en su espacio de direcciones, y el RSS cuenta esas páginas compartidas en cada proceso. Sumarlas cuenta la SGA varias veces. La memoria real se obtiene de la SGA y la PGA de `v$sgainfo` y `v$pgastat`, no de la suma del RSS.

19. El SPID de `v$process` de LGWR (`[COMPLETA: SPID]`) coincide con el PID de `/proc/<SPID>` dentro del contenedor. `docker top` muestra el PID del host, que pertenece a otro espacio de nombres de PIDs, por eso el número cambia.

20. PMON vigila los procesos de usuario: si una sesión muere, libera sus bloqueos y recursos (y registra servicios en el listener). SMON hace la recuperación de la instancia en el arranque tras una caída y limpia segmentos temporales.

### Seguridad y trabajo profesional

21. Por el principio de mínimo privilegio: `SYSTEM` tiene poderes de administración y una credencial más sensible. `C##OPS_RO` es una cuenta común de solo lectura (`CREATE SESSION` y acceso a vistas de consulta), suficiente para observar. No puede modificar datos ni parámetros, ni arrancar o parar la base.

22. (1) Contraseñas escritas en scripts y migraciones (`sys/<password>` en el script 08 y claves de `admin_*` en V000/V001), corregidas con autenticación por el sistema operativo en 08 v2 y cuentas de esquema en V003. (2) Contraseñas pasadas al reutilizar el volumen al crear el contenedor, eliminadas en 05 v2 ("sin contraseñas"), además de no versionar `config/.env`.
