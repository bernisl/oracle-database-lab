# Runbook — Pérdida de un datafile de aplicación

> Probado en el simulacro D del Lab 5 (`docs/bitacora/lab5/evidencia/script/*_14d-perdida-datafile.script.log`):
> RTO 10 s, RPO 0. Base FREE (CDB) con la PDB FREEPDB1, en el contenedor `oralab-26ai`.

## 1. Síntoma
Las consultas sobre un tablespace fallan con:
- `ORA-01116: error in opening database file N`
- `ORA-01110: data file N: '<ruta>'`
- `ORA-27041: unable to open file` (y `Linux-x86_64 Error: 2: No such file or directory`)

Puede aparecer además `ORA-63999: data file suffered media failure` en el alert log. En ese caso Oracle **ha cerrado la PDB entera** (queda MOUNTED) para protegerla.

## 2. Comprobaciones previas (no tocar nada hasta tenerlas)
```sql
-- como SYSDBA en CDB$ROOT
SELECT log_mode FROM v$database;                          -- debe ser ARCHIVELOG; si no, ver nota final
SELECT name, open_mode FROM v$pdbs WHERE name = 'FREEPDB1';
SELECT file#, name FROM v$datafile WHERE file# = N;       -- confirmar número y ruta
```
```
RMAN> LIST BACKUP OF DATAFILE N;                          -- debe existir una copia
```
Si no hay ARCHIVELOG o no hay copia: **no seguir**. Escalar (ver punto 5).

## 3. Reparación (`rman target /` y `sqlplus / as sysdba` dentro del contenedor)

**Camino A: la PDB sigue en READ WRITE.** Solo el tablespace está caído; el resto del servicio sigue funcionando.
```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE N OFFLINE;
```
```
RMAN> RESTORE DATAFILE N;
RMAN> RECOVER DATAFILE N;
```
```sql
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER DATABASE DATAFILE N ONLINE;
```

**Camino B: la PDB está MOUNTED (apareció ORA-63999).**
1. Esperar a que `v$pdbs` muestre `MOUNTED` del todo. Si se lanza RESTORE mientras se cierra, falla con ORA-01089.
2. Ejecutar los mismos `RESTORE DATAFILE N` y `RECOVER DATAFILE N` de RMAN.
3. Ejecutar `ALTER DATABASE DATAFILE N ONLINE` dentro de FREEPDB1.
4. Ejecutar `ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;`.

## 4. Verificación
```sql
SELECT name, open_mode FROM v$pdbs WHERE name = 'FREEPDB1';   -- READ WRITE
SELECT file#, status FROM v$datafile WHERE file# = N;         -- ONLINE
-- fila de control: un dato confirmado DESPUÉS de la última copia debe seguir ahí (RPO = 0)
```
Ejecuta también el runbook de salud: `bash scripts/ops/ro.sh scripts/lab5/15-healthcheck.sql`. El bloque 5 debe mostrar la incidencia y nada nuevo después.

## 5. A quién avisar
- **Antes de empezar:** al responsable del servicio afectado. En el camino B, toda FREEPDB1 está fuera de servicio.
- **Si no hay ARCHIVELOG o no hay copia:** escalar al DBA responsable. Solo queda restaurar una copia en frío completa, y se pierde lo posterior a ella (`scripts/ops/restaurar-estado.sh`).
- **Al terminar:** anotar en el incidente la hora del fallo, la causa, el RTO y el RPO, y revisar el disco o volumen que falló.

## Nota
Nunca uses `rm` sobre ficheros de la FRA para hacer sitio, ni `RESETLOGS` para este fallo: no hace falta.
