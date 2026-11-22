en# Lab 6 · Guardia nocturna · E058

## INC-601 · La pantalla de secretaría se queda colgada
- Detección:23:41 UTC, ticket de Ana García (secretaría). 
- Impacto: Ana no podía guardar la ficha del alumno 101; estuvo unos 60 s colgada (de 23:41:00 a 23:41:59).
- Diagnóstico:  08-diagnostico-inc601. SID 176 (ANA_GARCIA) esperaba en enq: TX - row lock contention al SID 59 (APP_ACADEMIA, matriculas/cierre-periodo). En la fila de ACA_ESTUDIANTES, el 59 tenía el TX en lmode 6 y 1 registro de undo sin confirmar.
- Causa raíz: la aplicación deja un UPDATE sin COMMIT mientras espera. Reiniciar el PC de Ana no tenía nada que ver.
- Intervención: ALTER SYSTEM KILL SESSION '59,10364' IMMEDIATE. Es la intervención más pequeña porque afecta a una sola sesión. CANCEL SQL no bastaba porque no libera el bloqueo.
- Validación: 0 sesiones bloqueadas y la fila 101 en ACTIVO (08-validacion-inc601).
- Acción preventiva:que la aplicación confirme antes de esperar, cortar las sesiones inactivas (IDLE_TIME) y alertar si hay bloqueos que duran más de N segundos. 

## INC-602 · La aplicación no conecta: ORA-12514
- Detección: 23:42 UTC, aviso del equipo de matrículas.
- Impacto: toda la aplicación de matrículas sin conexión durante algo menos de 1 minuto. Las conexiones por freepdb1 siguieron funcionando.
- Diagnóstico:  08-turno-inc602 y 08-diagnostico-inc602. La base estaba OPEN/ALLOWED y la PDB en READ WRITE, pero academia_app tenía ARRANCADO = NO. lsnrctl solo anunciaba freepdb1 y app.sh daba "Service academia_app is not registered with the listener".
- Causa raíz: alguien paró el servicio fuera de un cambio controlado. ORA-12514 lo da el listener, no la base.
- Intervención: DBMS_SERVICE.START_SERVICE('academia_app') y ALTER PLUGGABLE DATABASE freepdb1 SAVE STATE. No hacía falta reiniciar nada.
- Validación: academia_app READY en el listener y la app conecta con SERVICE_NAME = academia_app (08-validacion-inc602).
- Acción preventiva: vigilar los servicios que existen pero no están arrancados (sección 6 del diagnóstico) y que solo se paren servicios mediante un procedimiento de cambio.

## INC-603 · La aplicación no entra: ORA-28000
- Detección: 23:47 UTC, el equipo de matrículas tras el despliegue. Nota del turno: ese día se ejecutó el script trimestral de bajas.
- Impacto: la aplicación no podía iniciar sesión, alrededor de 30 s (de 23:47:44 a 23:48:15).
- Diagnóstico: 08-diagnostico-inc603. APP_ACADEMIA estaba en LOCKED (no TIMED) con el perfil DEFAULT de 10 intentos, así que no fueron intentos fallidos. La auditoría muestra ALTER USER app_academia ACCOUNT LOCK a las 23:47:44, hecho por SYS desde sqlplus.
- Causa raíz: el script de bajas no distingue entre cuentas de personas y cuentas de aplicación.
- Intervención:  ALTER USER app_academia ACCOUNT UNLOCK, sin cambiar la contraseña. 
- Validación: la app vuelve a entrar por academia_app y no queda ninguna cuenta bloqueada (08-validacion-inc603).
- Acción preventiva: que el script de bajas excluya las cuentas de aplicación (por ejemplo, filtrando por perfil: las personas tienen PRF_PERSONAS), revisar ese script y alertar de las cuentas que no están OPEN.
