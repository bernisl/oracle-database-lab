1. ¿Qué diferencia hay entre una imagen y un contenedor? Usa como ejemplo lo que hiciste en los ejercicios G2 y G4.
La imagen es la plantilla (como un molde). El contenedor es el molde ya relleno y funcionando. En G2 bajé la imagen de nginx, en G4 la ejecuté y ya tenía un contenedor corriendo.

2. En el Ejercicio G5 el archivo nota.txt desapareció y en el G6 no. Explica por qué.
En G5 lo creé dentro del contenedor sin volumen, así que al borrar el contenedor se fue todo. En G6 usé un volumen que guarda fuera, por eso aguantó.

3. ¿Qué diferencia hay entre docker ps y docker ps -a, y qué significa STATUS = Exited (0)?
ps solo muestra los que están corriendo. ps -a muestra todos, incluso los parados. Exited (0) = terminó bien, sin errores.

4. En -p 8181:8181, ¿qué número corresponde a tu equipo y cuál al contenedor? ¿Qué pasaría con -p 80:8080 en el ejercicio de nginx?
El primer número es de mi PC, el segundo del contenedor. Con -p 80:8080 en nginx no funcionaría, porque nginx dentro escucha en el 80, no en el 8080.

5. ¿Por qué un contenedor de Oracle se queda en marcha y el de hello-world termina solo?
Oracle se queda con el proceso de la base de datos en primer plano, no para. Hello-world imprime y ya, cuando acaba el proceso el contenedor muere.

6. ¿Qué es el digest de una imagen y por qué lo registramos si ya sabemos que usamos :latest?
El digest es un hash fijo que identifica la imagen exacta. :latest es una etiqueta que puede cambiar. Lo apuntamos para saber qué imagen usamos de verdad y poder repetirlo igual.

7. ¿Qué comando borraría realmente los datos de Oracle? ¿Por qué docker rm oralab-26ai no lo hace?
Borrar el volumen: docker volume rm .... docker rm oralab-26ai solo borra el contenedor, los datos están en el volumen, así que siguen ahí.

8. ¿Por qué este laboratorio se hace dentro del repositorio oracle-database-lab, con Issue, branch y Pull Request, en vez de en una carpeta aparte?
Para trabajar como en una empresa de verdad: queda registro de qué hicimos, por qué y con revisión. Además todo queda junto y versionado.

9. ¿Qué diferencia hay entre source 00-config.sh y bash 00-config.sh? ¿Por qué usamos source?
bash lo ejecuta en otro proceso y las variables se pierden. source lo ejecuta en la shell actual, así que las variables se quedan. Por eso usamos source.

10. Explica cada parte del nombre 20260915T091230Z_02-docker.script.log.
Fecha y hora UTC, número de paso y nombre de la fase, y que es un log del script.

11. ¿Para qué sirve .gitattributes y qué error evita?
Sirve para decirle a Git cómo tratar ciertos archivos, típicamente los saltos de línea. Evita que se rompan los scripts por CRLF vs LF.

12. ¿Por qué en este Pull Request elegimos Create a merge commit en lugar de Squash and merge?
Porque queremos conservar todos los commits del branch, no aplanarlos. Así queda la historia completa como evidencia.

13. Describe las cuatro capas de la estrategia de contraseñas (Parte D) y qué pasaría si te saltas la primera.
No hardcodearla, sacarla a variables/archivos fuera de Git, meterla en .gitignore y rotarla. Si te saltas la primera ya la tienes en el código y probablemente en el historial.

14. ¿Por qué no escribimos la contraseña directamente en el comando docker run, aunque el script no se suba a Git?
Porque queda en el .bash_history y en los logs de Docker. Cualquiera con acceso al equipo la ve.

15. Si descubres tu contraseña en un commit ya publicado, ¿basta con borrarla en un commit nuevo? ¿Qué debes hacer?
No basta con borrarla en otro commit, sigue en el historial. Hay que cambiarla ya (por si acaso) y reescribir el historial.

16. ¿Por qué no usamos SPOOL ni @archivo.sql con sqlplus dentro del contenedor, y qué hicimos en su lugar?
Porque dentro del contenedor es un lío acceder a los archivos. Lo hicimos redirigiendo la entrada/salida desde fuera con docker exec.

17. ¿Qué hace WHENEVER SQLERROR EXIT SQL.SQLCODE al inicio de V000 y V001, y qué pasaría sin esa línea?
Hace que si hay un error, sqlplus pare y salga con el código de error. Sin eso seguiría ejecutando y dejaría la migración a medias sin enterarse nadie.

18. ¿Qué es una migración y por qué V000 y V001 no se deben editar una vez aplicadas?
Son cambios versionados del esquema. No se editan una vez aplicadas porque los entornos que ya las corrieron quedarían descuadrados. Se hace una nueva migración.

19. ¿Por qué en SQL Developer se usa el servicio FREEPDB1 y no FREE ni un SID?
Porque Oracle es multitenant: FREE es el contenedor raíz y FREEPDB1 es la PDB donde trabajamos de verdad. SID es cosa vieja.

20. ¿Qué aporta SQLcl frente a SQL*Plus, y por qué un DBA debe dominar ambas?
SQLcl es más moderno: autocompletado, mejor salida, scripts en JS. SQL*Plus está en todos lados y es ligerísimo. Un DBA tiene que saber los dos porque te los encuentras en cualquier sitio.

21. ¿Por qué el curso pasa de Git Bash a Ubuntu en WSL 2? Da al menos dos problemas concretos de Git Bash que desaparecen en Ubuntu.
Porque Git Bash es una emulación limitada de Linux sobre Windows y da problemas. Dos concretos: los permisos de archivos no funcionan igual (los chmod y ejecutables fallan o se comportan raro), y los saltos de línea/ rutas de Windows se lían con scripts y con Docker (montajes, shebangs, etc.). En Ubuntu de WSL 2 eso es Linux de verdad y desaparecen esos problemas.

22. ¿Por qué clonamos el repositorio en ~/oracle-database-lab y no trabajamos sobre la carpeta de Windows (/mnt/c/...)? ¿Y por qué recomendamos bash frente a zsh para los scripts del curso?
Porque trabajar en /mnt/c/... es mucho más lento (WSL tiene que traducir el sistema de archivos de Windows) y da problemas de permisos y de finales de línea que rompen Docker y los scripts. En ~/ (dentro del filesystem de Linux) todo va nativo y rápido. Recomendamos bash en vez de zsh porque es el shell estándar de los scripts y del curso, está en todos los sistemas y no tiene comportamientos raros de zsh que rompen scripts pensados para POSIX/bash.