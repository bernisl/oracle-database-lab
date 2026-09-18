1. ¿Cuál es la diferencia entre Working Directory, Staging Area y Local Repository? Da un ejemplo de un archivo pasando por las tres.

Working Directory = donde editas; Staging Area = lo que preparas con git add; Local Repo = donde queda guardado con git commit. Ej: creas a.txt, haces git add a.txt y luego git commit.


2. Si modificas un archivo pero no haces git add, ¿aparece ese cambio en tu próximo commit? Explica por qué.

No, no aparece. El commit solo coge lo que está en el Staging Area, y si no haces git add, ese cambio se queda fuera.


3. ¿Por qué git status no mostraba las carpetas vacías que creaste en la Parte C? ¿Qué truco usamos para solucionarlo?

Porque Git no trackea carpetas vacías, solo archivos. Metimos un .gitkeep dentro para que Git las viera.


4. Explica con tus palabras qué es HEAD.

HEAD es un puntero que dice en qué commit o rama estás ahora mismo. Vamos, "dónde estás parado".


5. ¿Qué diferencia hay entre crear una branch con git switch -c y crear una carpeta nueva con mkdir? ¿Cómo lo comprobamos en la Parte G?

git switch -c crea una rama de Git, mkdir solo crea una carpeta normal del sistema. Se comprobó con git branch o git status, que no veían la carpeta.


6. Durante el conflicto de la Parte H, ¿qué representaba el contenido entre <<<<<<< HEAD y =======? ¿Y entre ======= y >>>>>>>?

Entre <<<<<<< HEAD y ======= está tu versión (la de tu rama actual). Entre ======= y >>>>>>> está la versión de la otra rama.


7. ¿Por qué NO se debe hacer git commit --amend sobre un commit que ya se subió con git push?

Porque cambias el historial y los commits ya subidos. Si otro ya los tiene, le líes un conflicto gordo al hacer push.



8. Si borras por accidente la carpeta .git de tu proyecto, ¿qué se pierde exactamente? ¿Se pierde también el código fuente que está en el disco?

Pierdes todo el historial, ramas y configuración de Git. El código fuente del disco NO se pierde, sigue ahí.


9. Explica con tus propias palabras la diferencia entre Git y GitHub, sin usar la palabra "nube".

Git es la herramienta que usas en tu PC para controlar versiones. GitHub es una web donde subes esos repos para compartirlos y trabajar en equipo.


10. ¿Por qué no se debe subir un archivo .env con contraseñas reales a un repositorio, aunque el repositorio sea privado?

Porque aunque sea privado, cualquiera con acceso o un despiste lo puede ver. Mejor usar .env.example y variables de entorno.


11. Un compañero te dice: "hice push y ahora GitHub me rechaza el segundo push con 'non-fastforward'". ¿Qué ha ocurrido probablemente y qué comando ejecutarías primero?

Que alguien subió cambios antes que tú y tu rama está desfasada. Primero haría git pull (o git pull --rebase).


12. ¿Qué tipo de Conventional Commit (feat, fix, docs, test…) usarías para: añadir un índice de rendimiento a una tabla, corregir una restricción mal definida, y actualizar el README?
Índice de rendimiento → perf (o feat si lo cuentan como mejora). 
Restricción mal definida → fix. 
README → docs.
