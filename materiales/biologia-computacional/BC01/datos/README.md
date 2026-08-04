# Datos de BC01 — Introducción, entorno y reproducibilidad

## Contenido

- `mini.tsv`: archivo pequeño (8 filas) con comandos UNIX esenciales, descripción, resultado esperado y error común. Útil para pruebas rápidas.
- `caso_s01.tsv`: caso concreto de errores de entorno (PATH incorrecto, archivo inexistente, extensión equivocada).
- `corpus/file_gen1.csv`: listado de archivos genómicos (tamano, tipo, fecha).
- `corpus/file_proteinas.txt`: registro de secuencias proteicas.
- `corpus/file_direcciones.txt`: inventario de archivos por ruta con notas de estado.
- `corpus/file_config.csv`: parámetros de configuración de pipeline (recomendados y actuales).
- `corpus/file_sample_info.csv`: información de muestras de secuenciación.
- `corpus/file_phred_distribution.txt`: distribución de puntuaciones Phred por posición de lectura.
- `corpus/file_unix_commands.md`: referencia de comandos UNIX para bioinformática.
- `corpus/file_checksum_reference.txt`: explicación de checksums y su importancia.

## Licencia

Datos sintéticos creados para fines docentes. Licencia: CC0-1.0
Autor: Álvaro Serrano Navarro (docente, Universidad Nebrija)

No son datos reales de experimentos o pacientes.

## Verificación

    cd datos && sha256sum -c SHA256SUMS && sha256sum -c MANIFEST.sha256

Todos los archivos deben mostrar OK.
