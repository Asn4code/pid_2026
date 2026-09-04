# Datos docentes de TC-CH02

Todos los ficheros son sintéticos, creados por Álvaro Serrano Navarro para el
módulo legacy `LEG-TC01` y dedicados a dominio público mediante CC0-1.0
(`sources_manifest.csv`, `TC02-C5-DATA`). No representan secuencias ni
registros biológicos reales.

| Recurso | Contenido | Finalidad |
|---|---|---|
| `tc02_caso_regex.fasta` | 2 registros, 2 líneas de secuencia cada uno | caso de oro con coincidencias y no coincidencias conocidas para `grep -E` |
| `corpus/` | 21 ficheros: 11 `.fasta`, 6 `.txt`, 4 `.log` | práctica integradora de automatización (tuberías, `grep`, `cut`/`sort`/`uniq`/`tr`, scripting y `awk`) |

Propiedades fijas del corpus (oráculo de regresión, no constantes que el
script deba llevar codificadas): 21 ficheros regulares; una cabecera `>` por
FASTA; `corpus/file_4.fasta` tiene 19 líneas y `corpus/file_5.fasta` tiene 21;
`corpus/muestra con espacio.fasta`, `corpus/notas campo.txt` y
`corpus/registro final.log` contienen espacios en el nombre.

`manifest.sha256` fija las sumas de los 22 ficheros. Desde esta carpeta:

```bash
sha256sum -c manifest.sha256
```
