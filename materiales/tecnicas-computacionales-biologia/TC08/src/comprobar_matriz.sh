#!/usr/bin/env bash
# Comprueba la matriz de transición que ha estimado el alumnado a partir de
# datos/secuencia_entrenamiento.txt. Calcula la suya por su cuenta y compara.
# Uso: herramienta/check_matriz.sh [DIRECTORIO_ENTREGA]
set -uo pipefail
W="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$W" || { echo "no se puede entrar en $W" >&2; exit 2; }
fallos=0; ko() { echo "FALLO: $*"; fallos=$((fallos+1)); }; ok() { echo "OK: $*"; }
[ -f notas/mi_matriz.tsv ] || { echo "FALTA: notas/mi_matriz.tsv"; echo "MATRIZ_INCOMPLETA"; exit 1; }
[ -f datos/secuencia_entrenamiento.txt ] || { echo "FALTA: datos/secuencia_entrenamiento.txt"; exit 1; }
seq=$(tr -d '\n' < datos/secuencia_entrenamiento.txt)
# matriz de referencia, calculada aquí
declare -A cuenta=()
for ((i = 0; i < ${#seq} - 1; i++)); do
  par="${seq:i:2}"; cuenta[$par]=$(( ${cuenta[$par]:-0} + 1 ))
done
filas=$(awk -F'\t' 'NR>1 && $1!=""' notas/mi_matriz.tsv | wc -l)
[ "$filas" -ge 3 ] || ko "notas/mi_matriz.tsv tiene $filas filas de datos; el alfabeto observado tiene al menos tres contextos"
# cada fila debe sumar uno
malas=$(awk -F'\t' 'NR>1 && $1!="" { s=$2+$3+$4+$5; if (s < 0.999 || s > 1.001) print $1 }' notas/mi_matriz.tsv)
[ -z "$malas" ] || ko "estas filas no suman uno: $(printf '%s' "$malas" | tr '\n' ' ')"
# comparación con la referencia, contexto a contexto
for ctx in A C G T; do
  total=0
  for sig in A C G T; do total=$(( total + ${cuenta[$ctx$sig]:-0} )); done
  [ "$total" -gt 0 ] || continue
  linea=$(awk -F'\t' -v c="$ctx" 'NR>1 && $1==c' notas/mi_matriz.tsv)
  [ -n "$linea" ] || { ko "falta la fila del contexto $ctx"; continue; }
  j=2
  for sig in A C G T; do
    esperado=$(awk -v n="${cuenta[$ctx$sig]:-0}" -v t="$total" 'BEGIN{printf "%.4f", n/t}')
    obtenido=$(printf '%s' "$linea" | cut -f$j)
    dif=$(awk -v a="$esperado" -v b="${obtenido:-0}" 'BEGIN{d=a-b; if (d<0) d=-d; print (d>0.005) ? "no" : "si"}')
    [ "$dif" = si ] || ko "la probabilidad de pasar de $ctx a $sig no coincide con el recuento de la secuencia"
    j=$((j+1))
  done
done
if [ "$fallos" -eq 0 ]; then echo "MATRIZ_OK: la matriz estimada coincide con el recuento y sus filas suman uno"; exit 0; fi
echo "MATRIZ_INCOMPLETA: $fallos comprobaciones sin superar"; exit 1
