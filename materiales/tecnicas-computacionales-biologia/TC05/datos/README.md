# Datos docentes de TC-CH05

El fichero de esta carpeta es sintético, de elaboración propia de Álvaro Serrano
Navarro, y se redistribuye con licencia CC0-1.0. No procede de ninguna base de
datos de interacciones reales.

| Fichero | Contenido | Para qué |
|---|---|---|
| `tc05_red_interaccion.tsv` | ocho aristas no dirigidas sobre siete nodos | recorridos en anchura, grados y experimento del nodo puente |

La red tiene dos módulos triangulares, los nodos 1, 2 y 3 por un lado y los
nodos 5, 6 y 7 por otro, unidos a través del nodo 4. Está construida así a
propósito: el nodo de mayor grado y el nodo cuya retirada parte la red en dos no
son el mismo, que es justamente lo que el anexo pide comprobar.

Para verificar que no ha modificado nada, desde esta carpeta:

```bash
sha256sum -c manifest.sha256
```
