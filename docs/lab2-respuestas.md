### 1. ¿Por qué es una mala práctica subir código directamente a `main` en proyectos de equipo?
Subir directamente a `main` impide la revisión de código por parte de otros miembros, aumenta la probabilidad de introducir errores no detectados en producción y rompe el historial limpio del proyecto sin trazabilidad del motivo de cada cambio.

### 2. ¿Qué ventaja ofrece usar ramas de función o documentación separadas antes de fusionar?
Permite aislar los cambios en un entorno seguro para desarrollarlos, probarlos y debatirlos sin alterar la versión estable del proyecto que utilizan los demás compañeros de equipo.

### 3. ¿Qué aporta el formato de Conventional Commits respecto a mensajes como "cambios" o "fix"?
Aporta consistencia, facilita la lectura del historial de cambios, permite automatizar la generación de notas de versión (changelogs) y comunica de forma explícita la intención del cambio (docs, feat, fix, etc.).

### 4. ¿Para qué sirve indicar `Refs #ID` en un commit y qué diferencia tiene con usar `Closes #ID` en un PR?
`Refs #ID` vincula el commit con el Issue para referencia e historial sin cerrarlo. `Closes #ID` en un Pull Request vincula la fusión del cambio y cierra automáticamente el Issue correspondiente al ser integrado en `main`.

### 5. ¿Por qué es recomendable proteger la rama `main` exigiendo Pull Request y aprobaciones?
Garantiza que ningún cambio llegue a la rama principal sin haber pasado por un control de calidad mínimo y haber sido revisado por al menos otra persona del equipo, reduciendo fallos en el código base.

### 6. ¿Qué diferencia hay entre realizar comentarios informativos y solicitar cambios (*Request changes*) en una revisión?
Un comentario informativo sugiere mejoras opcionales o aclaraciones sin bloquear el proceso. *Request changes* bloquea la fusión del Pull Request hasta que el autor aplique las correcciones obligatorias indicadas.

### 7. ¿Por qué el autor no debería resolver la conversación si el revisor pidió un cambio relevante?
Porque corresponde al revisor validar que la corrección aplicada en el nuevo commit satisface los requisitos solicitados antes de marcar la discusión como resuelta.

### 8. ¿Qué ocurre si intentas hacer `git push` directamente a una rama protegida desde la consola?
Git y GitHub rechazan la operación devolviendo un mensaje de error (`Protected branch update failed`), impidiendo que el código se suba directamente sin pasar por un Pull Request.

### 9. ¿Por qué se recomienda la estrategia *Squash and merge* en PRs de funcionalidades cortas?
Combina todos los commits individuales de la rama de trabajo en un único commit limpio al integrarlo en `main`, manteniendo el historial principal conciso y fácil de auditar.

### 10. ¿Por qué es importante eliminar las ramas locales y remotas después de realizar el merge?
Evita la acumulación de ramas obsoletas (*branch rot*), reduce el desorden en el repositorio y previene confusiones al trabajar en futuras tareas.

### 11. ¿Qué diferencia hay entre `git fetch` y `git pull` al actualizar tu repositorio local?
`git fetch` descarga los cambios remotos al repositorio local sin modificar tus archivos de trabajo. `git pull` realiza el `fetch` y fusiona automáticamente los cambios remotos en tu rama actual.

### 12. ¿Por qué es útil vincular un Issue a un Pull Request mediante palabras clave como `Closes #1`?
Aumenta la trazabilidad y la eficiencia al automatizar el cierre de tareas pendientes en el gestor del proyecto en cuanto los cambios son aprobados e integrados.

### 13. ¿Qué valor aporta la revisión entre pares (*peer review*) en el desarrollo de software?
Mejora la calidad final del código, fomenta el intercambio de conocimientos dentro del equipo, unifica criterios de estilo e identifica fallos o vulnerabilidades tempranamente.