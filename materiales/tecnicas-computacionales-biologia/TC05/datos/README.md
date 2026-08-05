# Datos de la práctica TC05

Ficheros propios, sintéticos, con licencia CC0-1.0. Los valores esperados se
calculan a mano con los ejemplos del capítulo (oráculo de regresión).

- `caso_bst.txt`: 5 3 8 1 4 7 9 (BST balanceado; in-order 1 3 4 5 7 8 9).
- `caso_bst_ordenado.txt`: 1 3 4 5 7 8 9 (entrada ordenada; altura 6, degenerado).
- `caso_arnm.fasta`: AUGAAUCUGCCU (proteína Met Asn Leu Pro; 4 aminoácidos).
- `caso_red.txt`: red del capítulo (BFS desde A: A0 B1 C1 D2 E3).
- `mini.txt`: secuencia mínima para el smoke test.
- `corpus/`: casos de frontera adicionales (BST balanceado y ordenado, ARNm con
  codón de parada, red con dos componentes).

Verifica la integridad con `sha256sum -c SHA256SUMS` y `-c MANIFEST.sha256`.
