#!/usr/bin/env bash
# Verificador de entrega de BC-CH09. No puntúa: la nota la pone quien corrige.
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_delivery.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
if [ -f "$W/mi_anclaje.py" ]; then
  python3 -m py_compile "$W/mi_anclaje.py" 2>/dev/null || ko "mi_anclaje.py no compila"
  salida=$(python3 "$AQUI/comprobar_anclaje.py" "$W/mi_anclaje.py" 2>&1) || true
  printf '%s' "$salida" | grep -q '^ANCLAJE_OK' || { ko "mi_anclaje.py no cumple el contrato:"; printf '%s\n' "$salida" | grep -E '^(FALLO|FALTA)' | sed 's/^/    /'; }
else ko "mi_anclaje.py"; fi
if [ -d "$W/data" ]; then (cd "$W/data" && sha256sum -c --quiet manifest.sha256 >/dev/null 2>&1) || ko "data/ no coincide con el manifiesto"; else ko "data/"; fi
if [ -f "$W/notas/variantes.tsv" ]; then
  head -1 "$W/notas/variantes.tsv" | grep -q $'^variante\torden_de_fusion\taltura_raiz\tque_cambio' || ko "notas/variantes.tsv: cabecera distinta de variante/orden_de_fusion/altura_raiz/que_cambio"
  n=$(awk -F'\t' 'NR>1 && NF>=4 && $2!="" && $3!="" && length($4)>10' "$W/notas/variantes.tsv" | wc -l)
  [ "$n" -ge 3 ] || ko "notas/variantes.tsv: $n variantes documentadas; se exigen las tres, base y las dos perturbaciones"
else ko "notas/variantes.tsv"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí la salida de las tres variantes"
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 140 ] && [ "$p" -le 320 ] || ko "notas/defensa.md: $p palabras; se piden entre 150 y 250"; else ko "notas/defensa.md"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/mi_anclaje.py" ] || ko "el paquete no contiene mi_anclaje.py bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
