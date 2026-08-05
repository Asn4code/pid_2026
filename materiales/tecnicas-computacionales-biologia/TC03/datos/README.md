# Datos docentes de TC03

Todos los ficheros de esta carpeta son sintéticos y han sido creados por
Álvaro Serrano Navarro para TC03. Se dedican al dominio público mediante
CC0-1.0. No representan muestras ni secuencias biológicas reales.

## Recursos

| Recurso | Versión | Finalidad |
|---|---|---|
| `mini_ordenada.txt` | 0.1.0 | lista ordenada mínima para la comprobación rápida de S06 |
| `caso_busqueda.txt` | 0.1.0 | lista ordenada de 15 enteros como caso conocido de búsqueda |
| `caso_motivo.fasta` | 0.1.0 | secuencia conocida de dos registros para contar un motivo |
| `tamanos.txt` | 0.1.0 | tamaños crecientes para el estudio de escalado |
| `corpus/` | 0.1.0 | práctica integradora S06-S07: 3 listas de enteros y 5 FASTA |

El corpus contiene tres listas de enteros ordenadas (`enteros_07.txt`,
`enteros_15.txt`, `enteros_31.txt`) y cinco ficheros FASTA, uno de ellos con
espacios en el nombre para comprobar el uso de comillas. Las listas están
ordenadas de forma ascendente: es la precondición de la búsqueda binaria.

`MANIFEST.sha256` fija el caso conocido, los tamaños y los ocho ficheros del
corpus. `SHA256SUMS` conserva la suma independiente del fichero mínimo de S06.

Desde esta carpeta:

```bash
sha256sum -c SHA256SUMS
sha256sum -c MANIFEST.sha256
```

Los datos permiten medir comparaciones y observar cómo crece el coste, pero un
recuento reproducible no valida por sí solo la elección del algoritmo: esa
decisión es la competencia que evalúa la práctica.
