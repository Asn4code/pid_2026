# Datos docentes de TC01

Todos los ficheros de esta carpeta son sintéticos y han sido creados por
Álvaro Serrano Navarro para TC01. Se dedican al dominio público mediante
CC0-1.0. No representan muestras ni secuencias biológicas reales.

## Recursos

| Recurso | Versión | Finalidad |
|---|---|---|
| `mini.fasta` | 0.1.0 | navegación e inspección inicial de S01 |
| `caso_s02.fasta` | 0.1.0 | caso conocido de dos registros para líneas, coincidencias y símbolos |
| `corpus/` | 0.1.0 | práctica integradora S02-S03 con 21 ficheros |

El corpus contiene 11 FASTA, 6 TXT y 4 LOG. Incluye nombres con espacios para
comprobar el uso de comillas. `file_4.fasta` tiene 19 líneas y
`file_5.fasta`, 21; el caso de 20 líneas debe construirlo cada estudiante.

`MANIFEST.sha256` fija `caso_s02.fasta` y los 21 ficheros del corpus.
`SHA256SUMS` conserva la suma independiente del fichero mínimo de S01.

Desde esta carpeta:

```bash
sha256sum -c SHA256SUMS
sha256sum -c MANIFEST.sha256
```

Los datos permiten probar órdenes y scripts, pero una extensión de fichero y
un checksum no validan por sí solos la semántica de un formato biológico.
