#!/usr/bin/env bash
# Comprueba la matriz rellenada a mano y el guion de verificación de puntuación.
# Calcula ambas cosas por su cuenta y compara. Uso: herramienta/check_trabajo.sh [DIR]
set -uo pipefail
W="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$W" || { echo "no se puede entrar en $W" >&2; exit 2; }
fallos=0; ko() { echo "FALLO: $*"; fallos=$((fallos+1)); }; ok() { echo "OK: $*"; }
# matriz de referencia para GAT frente a GC
esperado="0 -2 -4|-2 1 -1|-4 -1 0|-6 -3 -2"
if [ -f notas/mi_matriz.tsv ]; then
  obtenido=$(awk -F'\t' '/^[0-9]/ { printf "%s %s %s|", $2, $3, $4 }' notas/mi_matriz.tsv | sed 's/|$//')
  if [ -z "$(printf '%s' "$obtenido" | tr -d ' |')" ]; then ko "notas/mi_matriz.tsv sigue vacía"
  elif [ "$obtenido" != "$esperado" ]; then ko "la matriz no coincide con el cálculo de referencia; revise la celda de la fila 2 y la columna 2, que es la que decide el empate final"
  else ok "la matriz de Needleman-Wunsch coincide celda a celda"; fi
else ko "notas/mi_matriz.tsv no existe"; fi
# guion de verificación de puntuación
if [ -f scripts/verificar_puntuacion.sh ]; then
  bash -n scripts/verificar_puntuacion.sh 2>/dev/null || ko "scripts/verificar_puntuacion.sh no pasa bash -n"
  prueba() {
    local x="$1" y="$2" esp="$3" sal
    sal=$(bash scripts/verificar_puntuacion.sh "$x" "$y" 2>/dev/null | sed -n 's/^PUNTUACION://p')
    [ "$sal" = "$esp" ] || ko "sobre $x frente a $y su guion dice «${sal:-nada}» y la suma columna a columna da $esp"
  }
  prueba GAT G-C -2
  prueba ACGT ACGT 4
  prueba "AC-T" "ACGT" 1
  bash scripts/verificar_puntuacion.sh ACGT ACG >/dev/null 2>&1 && ko "el guion acepta dos alineamientos de longitud distinta" || true
  bash scripts/verificar_puntuacion.sh "A--T" "A--T" >/dev/null 2>&1 && ko "el guion acepta una columna con hueco en las dos cadenas" || true
  [ "$fallos" -eq 0 ] && ok "el guion recalcula la puntuación columna a columna y rechaza las entradas imposibles"
else ko "scripts/verificar_puntuacion.sh no existe"; fi
if [ "$fallos" -eq 0 ]; then echo "TRABAJO_OK: la matriz y el guion cumplen lo pedido"; exit 0; fi
echo "TRABAJO_INCOMPLETO: $fallos comprobaciones sin superar"; exit 1
