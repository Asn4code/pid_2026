# Datos docentes de BC-CH11

El fichero de esta carpeta es sintético, de elaboración propia de Álvaro Serrano
Navarro, y se redistribuye con licencia CC0-1.0. No procede de ninguna estructura
depositada ni de ningún experimento real.

| Fichero | Contenido | Para qué |
|---|---|---|
| `bc11_estructura.pdb` | trece átomos de tres residuos, más una molécula de agua, en formato de ancho fijo | procesar el formato por posiciones, extraer coordenadas y factores de temperatura, y producir un informe de validación |

Está construido con dos cosas a propósito. Los factores de temperatura crecen a
lo largo de la cadena, de quince a casi ochenta, de modo que el extremo es
claramente menos fiable que el principio: es la lectura que el capítulo pide
hacer. Y hay una línea `HETATM`, que no es un residuo de la proteína y que un
procesador descuidado cuenta como si lo fuera.

Para comprobar que no ha modificado nada, desde esta carpeta:

```bash
sha256sum -c manifest.sha256
```
