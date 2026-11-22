1. ¿Cuántos errores ORA- tenía tu alert log en 24 h en la Parte B y a qué se debían? ¿Por qué ese número no es una alarma por sí solo?

En las últimas 24 horas aparecían 4 errores ORA-. Por sí solo, este número no significa que haya un problema, ya que habría que compararlo con los días anteriores para saber si es algo habitual o si ha aumentado. Además, los simulacros del Lab 5 del 29 de octubre quedaron fuera de ese periodo de 24 horas.

2. ¿A qué hora empieza y cuánto dura la ventana de mantenimiento de un miércoles en tu base? ¿Qué tareas automáticas corren en ella?

La ventana de mantenimiento de los miércoles empieza a las 22:00 y dura 4 horas. Durante ese tiempo se ejecutan tres tareas automáticas: las estadísticas del optimizador, el Auto Space Advisor y el SQL Tuning Advisor.

3. Explica con tu salida de la Parte C la diferencia entre lo que mostraban V$SPPARAMETER y V$PARAMETER tras el SCOPE = SPFILE. ¿Qué habría pasado en el siguiente reinicio sin el RESET?

V$SPPARAMETER mostraba el valor 250, mientras que V$PARAMETER seguía mostrando 200. Esto ocurre porque el cambio se guardó en el SPFILE, pero todavía no se había aplicado a la memoria. Si no hubiera hecho el RESET, al reiniciar la base de datos habría arrancado con el valor 250.

4. ¿Por qué RESET fue la vuelta atrás correcta para db_files y no lo habría sido para processes? Cita la línea de tu PFILE que lo demuestra.

En el caso de db_files, el parámetro no aparece definido en el PFILE, por lo que al hacer RESET vuelve a su valor por defecto, que coincide con el valor anterior. Sin embargo, processes sí aparece definido en la línea 31 del PFILE (*.processes=200). Por tanto, hacer RESET lo habría cambiado al valor por defecto, que no era 200.

5. Tras el reinicio sin estado guardado, ¿qué error obtuvo C##OPS_RO y por qué la instancia decía «Database opened»?

C##OPS_RO obtuvo el error ORA-01109 (database not open). Aunque la instancia y la CDB estaban abiertas, la PDB FREEPDB1 seguía en estado MOUNTED porque no se había guardado su estado de apertura. Por eso, no se podía acceder a ella normalmente.

6. ¿Qué SID, SPID y evento tenía la sesión de la aplicación en tu ejecución? ¿Qué te dicen MODULE, ACTION y CLIENT_IDENTIFIER que no te diría USERNAME?

La sesión tenía el SID 21, el SPID 2125 y estaba esperando por el evento PL/SQL lock timer. Además, MODULE indicaba que pertenecía a matriculas, ACTION mostraba que estaba realizando el cierre-periodo y CLIENT_IDENTIFIER identificaba al usuario ana.garcia@ucam. Estos datos permiten saber qué estaba haciendo la sesión y quién la estaba utilizando, mientras que USERNAME solo mostraría la cuenta general APP_ACADEMIA.

7. Tras CANCEL SQL, ¿cuántas transacciones abiertas tenía la aplicación? ¿Y tras KILL SESSION? ¿En qué estado quedó la fila 101 y por qué?

Después de ejecutar CANCEL SQL todavía quedaba una transacción abierta. Sin embargo, después de KILL SESSION ya no quedaban sesiones. La fila 101 terminó en estado ACTIVO porque el UPDATE que se había realizado no llegó a confirmarse y Oracle deshizo el cambio.

8. ¿Qué valor tiene common_user_prefix en tu imagen? ¿Qué implica para el nombre de una cuenta común?

El valor es C##. Esto significa que las cuentas comunes deben empezar obligatoriamente por ese prefijo, como ocurre con C##OPS_RO. En cambio, las cuentas locales, como APP_ACADEMIA, no necesitan llevarlo.

9. Completa con tus cifras la tabla de las tres miradas (ALL_TABLES, DBA_USERS, CDB_USERS, V$DATAFILE) y explica una diferencia.

| Vista | C##OPS_RO en la raíz | C##OPS_RO en FREEPDB1 | APP_ACADEMIA |
|---|---|---|---|
| ALL_TABLES de ADMIN_ACADEMIA | 0 | 0 | 1 |
| DBA_USERS | 37 | 47 | ORA-00942 |
| CDB_USERS | 37 (CON_ID 1) y 47 (CON_ID 3) | 47 (CON_ID 3) | ORA-00942 |
| V$DATAFILE | 17 | 10 | ORA-00942 |

Una diferencia importante es que DBA_USERS y V$DATAFILE no están disponibles para APP_ACADEMIA porque no tiene los permisos necesarios. En cambio, CDB_USERS permite consultar información de usuarios de los distintos contenedores.

10. Con tu salida de 04-deltas: ¿cuántas lecturas lógicas por recorrido y cuánto DB time costó la carga? ¿Qué indica la relación entre DB time y DB CPU?

La carga necesitó 5.317 lecturas lógicas por recorrido y tuvo un DB time de 0,44 segundos. El DB CPU fue de 0,39 segundos, por lo que ambos valores son muy parecidos. Esto indica que prácticamente todo el tiempo se utilizó en procesar datos y apenas hubo esperas.

11. Da las tres medidas (asignado, libre, máximo) de TBS_ACADEMIA_HIST antes de la carga y explica cuál usarías para alertar.

Antes de la carga había 10 MB asignados, 3,9 MB libres y un máximo de 40 MB. Para controlar el espacio utilizaría el porcentaje ocupado respecto al máximo, que era del 15,16 %, ya que así se tiene en cuenta el crecimiento que todavía puede alcanzar el tablespace.

12. ¿Quién insertó y quién «pagó» en el ORA-01950? ¿Por qué ampliar el tablespace no habría resuelto el ORA-01536?

La inserción la realizó SYS, pero el espacio utilizado pertenecía a CARGA_HIST, que era la propietaria de la tabla. El problema no era que faltase espacio en el tablespace, sino que CARGA_HIST no tenía cuota suficiente. Por eso, ampliar el tablespace no habría solucionado el error ORA-01536.

13. ¿Cuánto tiempo estuvo suspendida la carga reanudable y qué evidencia de ello dejó Oracle en el alert log?

La carga estuvo suspendida aproximadamente 14 segundos. En el alert log aparece que se suspendió a las 23:05:11.10 y que se reanudó a las 23:05:25.11, por lo que se puede comprobar cuándo se produjo la pausa y cuándo continuó.

14. Antes y después del SHRINK: filas, bloques y cuota consumida. ¿Por qué un DELETE no devolvió el espacio?

Antes del DELETE había 20.000 filas, 2.944 bloques y 23 MB ocupados. Después del DELETE quedaron 2.000 filas, pero seguían ocupándose los mismos 2.944 bloques. Tras ejecutar SHRINK, el espacio bajó a 304 bloques y 2,4 MB.

Esto ocurre porque DELETE elimina los registros, pero no reduce por sí solo el espacio reservado por la tabla. Para recuperar ese espacio fue necesario ejecutar SHRINK.

15. ¿Qué valores tenía tu perfil DEFAULT? Justifica dos de los límites de PRF_PERSONAS para una persona de secretaría.

El perfil DEFAULT tenía estos valores:

- FAILED_LOGIN_ATTEMPTS: 10 intentos.

- PASSWORD_LIFE_TIME: 180 días.

- LOCK_TIME: 1 día.

- GRACE_TIME: 7 días.

- INACTIVE_ACCOUNT_TIME: 365 días.

- VERIFY_FUNCTION: NULL.

Para el perfil PRF_PERSONAS establecería un máximo de 3 intentos de inicio de sesión para evitar accesos no autorizados y una duración máxima de contraseña de 90 días para mejorar la seguridad de la cuenta. Son medidas razonables para proteger la información académica que maneja una persona de secretaría.

16. ¿Por qué Ana pudo leer ACA_MATRICULAS si nadie se la concedió por nombre? ¿Qué error obtuvo al cambiar el nombre de un alumno?

Ana podía consultar ACA_MATRICULAS porque tenía concedido el privilegio SELECT ANY TABLE ON SCHEMA admin_academia, que le permitía leer las tablas de ese esquema sin necesidad de recibir permisos individualmente sobre cada una.

Sin embargo, al intentar cambiar el nombre de un alumno obtuvo el error ORA-41900 porque no tenía permiso UPDATE sobre esa columna.

# Partes H-I · Objetos, diagnóstico y guardia

17. ¿Qué objetos se invalidaron en cada uno de los tres cambios de columna y por qué no se invalidó nada con la columna nueva?

Al añadir una columna nueva no se invalidó ningún objeto. Sin embargo, al modificar la columna email se invalidó la vista V_CONTACTO_LAB6. Después, al cambiar los nombres, se invalidaron V_ACTIVOS_LAB6 y la función que dependía de ella.

Esto se debe a que Oracle controla las dependencias por columnas, por lo que añadir una columna que no afecta a los objetos existentes no provoca su invalidación.

18. Según tus advisors, ¿mejoraría el DB time duplicar la SGA? ¿Y por debajo de qué tamaño la PGA tendría sobreasignaciones?

No, duplicar la SGA no mejoraría el DB time, ya que el resultado del advisor mostraba un factor 1, es decir, que no habría mejora. En cuanto a la PGA, por debajo de 512 MB empezaban a aparecer sobreasignaciones: una a 384 MB y cuatro a 256 MB.

19. ¿Cuántas lecturas lógicas necesitó la consulta de la aplicación según la traza (o tkprof)? ¿Qué línea de la traza lo dice?

La consulta necesitó 247 lecturas lógicas. Esto se puede comprobar en la línea FETCH de la traza, donde aparece cr=247, que coincide también con las 247 lecturas que muestra TKPROF.

20. Para cada incidente de la guardia: evidencia clave, intervención y validación (una línea por cada uno).

- INC-601

Evidencia clave: SID 176 (ANA_GARCIA) esperando enq: TX - row lock contention del SID 59 (APP_ACADEMIA,

matriculas), que tenía 1 registro sin confirmar

Intervención: ALTER SYSTEM KILL SESSION '59,10364' IMMEDIATE

Validación: 0 sesiones bloqueadas y fila 101 = ACTIVO

- INC-602

Evidencia clave: La base estaba abierta, pero academia_app aparecía con ARRANCADO = NO y el listener no

lo anunciaba (ORA-12514)

Intervención: DBMS_SERVICE.START_SERVICE('academia_app') + ALTER PLUGGABLE DATABASE freepdb1 SAVE STATE

Validación: El listener anuncia academia_app en READY y la app conecta

- INC-603

Evidencia clave: APP_ACADEMIA en LOCKED (manual, no TIMED); la auditoría muestra ALTER USER

app_academia ACCOUNT LOCK a las 23:47:44, hecho por el script de bajas

Intervención: ALTER USER app_academia ACCOUNT UNLOCK (sin cambiar la contraseña)

Validación: La app vuelve a entrar por academia_app y no queda ninguna cuenta bloqueada
