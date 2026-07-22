# Práctica TC05 — Hash, árboles y grafos

**Versión:** 0.1.0

Práctica individual de las sesiones S10–S11. Aplica las tres familias de
estructuras del tema sobre datos biológicos pequeños: un árbol binario de
búsqueda, una tabla hash y un grafo. El objetivo no es teclear las estructuras,
sino **elegir la adecuada antes de programar** y justificar la elección.

## Requisitos

- Vía A (recomendada), GNU/Linux con **Bash 4 o superior** (arrays asociativos).
- Vía B, **Google Colab**: cuaderno con celdas `%%bash` (sin instalar nada).
- Windows y macOS: sin soporte local directo; usa la vía B.

Comprueba tu entorno:

```bash
bash src/smoke_test.sh          # debe terminar en TC05_SMOKE_TEST_OK
```

## Preparar tu espacio de trabajo

```bash
bash src/preparar_practica.sh ~/tc05-<tu_usuario>
cd ~/tc05-<tu_usuario>
```

El preparador copia los datos y se **niega a sobrescribir** un directorio
existente. Trabaja siempre sobre la copia, no sobre el material original.

## Tareas

Escribe tus tres scripts en `scripts/`. Cada uno recibe su fichero de entrada
como argumento y **rechaza** con estado distinto de cero una entrada ausente o
inválida.

1. **`bst.sh FICHERO`** — lee una lista de números, construye un árbol binario
   de búsqueda insertándolos en orden de llegada e imprime su recorrido
   **in-order**. Informa además de la **altura** del árbol, para que se vea la
   degeneración cuando la entrada llega ordenada.
2. **`codones.sh ARNM`** — con un **array asociativo** de Bash como tabla hash
   (codón → aminoácido), traduce el ARNm leído de tres en tres e imprime la
   proteína y el **recuento** de cada aminoácido.
3. **`bfs.sh RED ORIGEN`** — lee una red como lista de adyacencia, hace un
   **BFS** con una cola desde `ORIGEN` e imprime la **distancia en saltos** a
   cada nodo alcanzable.

Además:

4. Documenta en `notas/README.md` qué estructura usa cada script y por qué, con
   una tabla de costes.
5. Rellena `pruebas.tsv` con casos de frontera (entrada ordenada frente a
   barajada, codón inexistente, nodo aislado), comparando salida esperada y real.

## Oráculo (verificable a mano)

| Comprobación | Entrada | Esperado |
|---|---|---|
| `bst.sh` in-order | `caso_bst.txt` (5 3 8 1 4 7 9) | `1 3 4 5 7 8 9` |
| `bst.sh` altura | `caso_bst_ordenado.txt` (1 3 4 5 7 8 9) | `6` |
| `codones.sh` proteína | `caso_arnm.fasta` (AUGAAUCUGCCU) | `Met Asn Leu Pro` |
| `codones.sh` distintos | `caso_arnm.fasta` | `4` |
| `bfs.sh` distancias | `caso_red.txt` desde `A` | `A0 B1 C1 D2 E3` |

El programa debe **calcular** estos valores a partir de la entrada, no
incorporarlos escritos.

## Formato de salida esperado

```
$ bash scripts/bst.sh datos/caso_bst.txt
in-order: 1 3 4 5 7 8 9
altura: 2

$ bash scripts/codones.sh datos/caso_arnm.fasta
proteina: Met Asn Leu Pro
aminoacidos_distintos: 4
...

$ bash scripts/bfs.sh datos/caso_red.txt A
A0 B1 C1 D2 E3
```

## Autocomprobación

```bash
bash <ruta_práctica>/src/verificar_entrega.sh scripts/
```

Debe terminar en `TC05_SUBMISSION_TESTS_OK`. Es la misma batería de caja negra
con la que se corrige.

## Qué entregar

- `scripts/bst.sh`, `scripts/codones.sh`, `scripts/bfs.sh`;
- `notas/README.md` con la tabla de costes y la justificación de cada elección;
- `pruebas.tsv` con tus casos de frontera;
- `entrega/plantilla_evidencia.md` cumplimentada.

## Contingencia

Si Colab falla, la entrega permanece abierta y se reprograma en Linux sin
penalización. El entorno no forma parte de la evaluación.
