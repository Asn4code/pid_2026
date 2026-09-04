# Datos sintéticos del anexo práctico de BC-CH09

- versión: 1.0.0 (2026-08-06)
- autoría: obra original del proyecto de innovación docente
- licencia: CC0 1.0; pueden copiarse, modificarse y redistribuirse
- procedencia biológica: ninguna; `S1`–`S4` son secuencias didácticas sintéticas de 16 nt, alineadas de partida (sin huecos) para aislar el cálculo de distancias del problema de alineamiento, que el capítulo trata por separado
- alfabeto esperado: A, C, G y T en mayúsculas
- propósito: dataset propio del anexo práctico (`practical_coupling: own`), distinto del ejemplo A–B–C–D usado en la teoría; ningún valor de este archivo se reutiliza del cuerpo teórico

`practice_sequences.fasta` contiene los cuatro registros base (`S1`–`S4`) usados en el cálculo ancla, en la reproducción Python y en la perturbación de modelo. La perturbación de datos (dos sustituciones adicionales en `S3`) se genera en tiempo de ejecución por `verification/practice_checks.py`, no como un segundo archivo, para que quede visible como una decisión explícita y no como un dato oculto. `manifest.sha256` permite detectar cualquier cambio en este archivo y en este documento. Ningún archivo requiere red ni contiene datos personales o clínicos.
