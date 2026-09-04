#!/usr/bin/env bash
# Comprueba mi_tabla_codones.sh y mi_bfs.sh contra su contrato, con entradas
# que el enunciado no muestra. No imprime los valores esperados.
# Uso: herramienta/check_scripts.sh [DIRECTORIO_ENTREGA]
set -uo pipefail
W="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$W" || { echo "no se puede entrar en $W" >&2; exit 2; }
fallos=0; ko() { echo "FALLO: $*"; fallos=$((fallos+1)); }; ok() { echo "OK: $*"; }
for s in mi_tabla_codones mi_bfs; do
  [ -f "scripts/$s.sh" ] || { ko "scripts/$s.sh no existe"; continue; }
  bash -n "scripts/$s.sh" 2>/dev/null || ko "scripts/$s.sh no pasa bash -n"
done
[ "$fallos" -eq 0 ] || { echo "SCRIPTS_INCOMPLETO: $fallos"; exit 1; }

# 1 los tres marcos sobre una secuencia que no aparece en el capítulo
sal=$(bash scripts/mi_tabla_codones.sh AUGCCUUGCAAU 2>/dev/null)
n=$(printf '%s\n' "$sal" | grep -c '^MARCO:')
if [ "$n" -ne 3 ]; then ko "mi_tabla_codones.sh no emite los tres marcos de lectura (emitió $n)"
else
  m0=$(printf '%s\n' "$sal" | grep '^MARCO:0' | sed 's/.*CODONES:\([^ ]*\).*/\1/')
  m1=$(printf '%s\n' "$sal" | grep '^MARCO:1' | sed 's/.*CODONES:\([^ ]*\).*/\1/')
  m2=$(printf '%s\n' "$sal" | grep '^MARCO:2' | sed 's/.*CODONES:\([^ ]*\).*/\1/')
  [ "$m0" = "AUG-CCU-UGC-AAU" ] || ko "el marco 0 no lee los codones correctos (llegó: $m0)"
  [ "$m1" = "UGC-CUU-GCA" ] || ko "el marco 1 no lee los codones correctos (llegó: $m1)"
  [ "$m2" = "GCC-UUG-CAA" ] || ko "el marco 2 no lee los codones correctos (llegó: $m2)"
  printf '%s\n' "$sal" | grep -q '^DISPERSION:[0-9]* COLISIONES:[0-9]*$' || ko "falta la línea final con el tamaño de la tabla y las colisiones de su función de dispersión"
  printf '%s\n' "$sal" | grep -q 'AMINOACIDOS:[A-Za-z?]' || ko "los marcos no informan de los aminoácidos traducidos"
fi
[ "$fallos" -eq 0 ] && ok "la tabla de codones lee los tres marcos y declara sus colisiones"

# 2 el recorrido en anchura, desde dos orígenes distintos
sal=$(bash scripts/mi_bfs.sh 1 2>/dev/null)
orden=$(printf '%s\n' "$sal" | grep '^BFS:' | sed 's/^BFS://;s/^ *//')
vis=$(printf '%s\n' "$sal" | grep '^VISITADOS:' | sed 's/^VISITADOS://')
[ "$orden" = "1 2 3 4 5 6 7" ] || ko "el recorrido desde el nodo 1 no sigue el orden en anchura con vecinos en orden creciente (llegó: $orden)"
[ "$vis" = "7" ] || ko "el recorrido no visita los siete nodos de la red (dijo: $vis)"
sal=$(bash scripts/mi_bfs.sh 4 2>/dev/null)
orden=$(printf '%s\n' "$sal" | grep '^BFS:' | sed 's/^BFS://;s/^ *//')
[ "$orden" = "4 3 5 1 2 6 7" ] || ko "el recorrido desde el nodo 4 no es correcto (llegó: $orden)"
[ "$fallos" -eq 0 ] && ok "el recorrido en anchura visita la red entera y respeta el orden por niveles"

if [ "$fallos" -eq 0 ]; then echo "SCRIPTS_OK: los dos guiones cumplen su contrato"; exit 0; fi
echo "SCRIPTS_INCOMPLETO: $fallos comprobaciones sin superar"; exit 1
