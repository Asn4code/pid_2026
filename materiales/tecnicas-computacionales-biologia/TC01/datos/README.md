# Datos docentes de TC-CH01

Todos los ficheros de esta carpeta son sintéticos. Proceden del corpus propio
CC0-1.0 creado por Álvaro Serrano Navarro para el módulo legacy `LEG-TC01`
(`sources_manifest.csv`, `TC01-C5-DATA`) y se redistribuyen aquí con manifiesto
propio para el capítulo. No representan secuencias, textos ni registros
biológicos o clínicos reales.

| Fichero | Líneas | Finalidad |
|---|---:|---|
| `tc01_mini.fasta` | 6 | primer contacto: `pwd`, `ls`, `cat`, `head`/`tail` sobre un fichero mínimo |
| `tc01_sample.fasta` | 19 | contraste de `wc -l` con un conteo manual y con `head -n 5`/`tail -n 5` |
| `tc01_sample.log` | 3 | ejemplo de `file` distinguiendo texto de otros tipos y de inspección con `less` |
| `tc01_notas campo.txt` | 3 | nombre con espacio: obliga a entrecomillar la ruta en toda orden |

`manifest.sha256` fija las cuatro sumas. Desde esta carpeta:

```bash
sha256sum -c manifest.sha256
```

Los datos permiten practicar órdenes de inspección sin escritura ni scripting;
esa parte pertenece a `TC-CH02`, que reutiliza el corpus completo de 21
ficheros bajo la misma licencia.
