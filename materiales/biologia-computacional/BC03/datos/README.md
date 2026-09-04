# Datos docentes de BC-CH03

El fichero de esta carpeta es sintético, de elaboración propia de Álvaro Serrano
Navarro, y se redistribuye con licencia CC0-1.0. No procede de ningún proyecto de
secuenciación real ni contiene datos de ninguna persona.

| Fichero | Contenido | Para qué |
|---|---|---|
| `bc03_variantes.vcf` | diez variantes de un solo nucleótido sobre un cromosoma ficticio, en formato estándar con sus cabeceras | procesar variantes, clasificarlas y calcular el indicador de calidad del lote |

La primera variante está deliberadamente en la posición 1. Un procesador que
convierta mal las coordenadas, restando uno sin comprobar, produce un índice
negativo justo ahí. Es el caso de frontera que el anexo pide detectar.

Para comprobar que no ha modificado nada, desde esta carpeta:

```bash
sha256sum -c manifest.sha256
```
