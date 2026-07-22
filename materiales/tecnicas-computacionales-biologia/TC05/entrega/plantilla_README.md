# Entrega individual TC05 — Hash, árboles y grafos

## Qué estructura usa cada script y por qué
- `bst.sh`: árbol binario de búsqueda. Por qué: ...
- `codones.sh`: tabla hash (array asociativo). Por qué: ...
- `bfs.sh`: lista de adyacencia + cola. Por qué: ...

## Tabla de costes
| Script | Estructura | Coste | ¿Puede degenerar? |
|---|---|---|---|
| bst.sh | BST | O(log n) / O(n) | sí, con entrada ordenada |
| codones.sh | tabla hash | O(1) por codón | sí, factor de carga alto |
| bfs.sh | lista de adyacencia + cola | O(V+E) | — |

## Decisiones y auditoría de IA
- ...

## Cómo reproducir
```bash
bash scripts/bst.sh datos/caso_bst.txt
bash scripts/codones.sh datos/caso_arnm.fasta
bash scripts/bfs.sh datos/caso_red.txt A
```
