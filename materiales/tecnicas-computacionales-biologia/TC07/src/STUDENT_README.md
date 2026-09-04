# Distribución estudiantil TC07

Este directorio fue preparado de forma atómica por el docente o la fábrica. Es
la raíz completa que se entrega: no necesita ni debe estar dentro del árbol de
autoría.

1. Ejecuta `bash check_environment.sh`.
2. Ejecuta `sha256sum --check --strict manifest.sha256`.
3. Lee `TC07-practice.pdf` y ejecuta `bash bash_recovery.sh`.
4. Completa únicamente la zona `TODO-TC07` de `analysis_tc07.sh`.
5. Comprueba la entrega con
   `bash check_submission.sh ./analysis_tc07.sh`.
6. Genera una entrega nueva con
   `bash analysis_tc07.sh analyze data/tc07_sequences.fasta entrega`.

El comprobador público vuelve a leer cada FASTA mediante un oráculo independiente
del candidato y prueba desafíos positivos creados desde una semilla de ejecución.
Imprime semilla y hashes para repetir exactamente un fallo; no incluye tablas
congeladas ni la solución de clasificación. La evaluación docente elige otras
semillas. Nunca edites `lib/` ni los datos congelados. Todos los scripts usan
Bash, GNU Awk y `cmp`; no se requiere red.
