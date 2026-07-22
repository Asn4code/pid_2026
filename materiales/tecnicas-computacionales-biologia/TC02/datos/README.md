# Datos docentes de TC02 (Bash avanzado)

Todos los ficheros de esta carpeta son sintéticos y han sido creados por
Álvaro Serrano Navarro para TC02. Se dedican al dominio público mediante
CC0-1.0. No representan muestras ni secuencias biológicas reales.

## Recursos

| Recurso | Versión | Finalidad |
|---|---|---|
| `mini.fasta` | 0.1.0 | FASTA mínimo multilínea para la comprobación rápida de S04 |
| `caso.fasta` | 0.1.0 | caso conocido de dos registros para transcripción, longitud y GC |
| `corpus/` | 0.1.0 | práctica integradora S04-S05: 5 FASTA con secuencias en varias líneas |

Los FASTA tienen la secuencia **repartida en varias líneas** a propósito: es la
situación en la que `wc -l` o un `grep` por línea fallan y en la que `awk`, al
acumular hasta la siguiente cabecera, sí da la longitud y el contenido GC
correctos. `adn_3.fasta` mide 34 bases repartidas en cuatro líneas. Uno de los
ficheros incluye espacios en el nombre para comprobar el uso de comillas.

`MANIFEST.sha256` fija el caso conocido y los cinco ficheros del corpus.
`SHA256SUMS` conserva la suma independiente del fichero mínimo de S04.

```bash
sha256sum -c SHA256SUMS
sha256sum -c MANIFEST.sha256
```
