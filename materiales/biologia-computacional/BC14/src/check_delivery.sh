#!/usr/bin/env bash
# Verificador de entrega de BC-CH14. No puntúa: la nota la pone quien corrige.
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_delivery.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
if [ -f "$W/mi_cribado.py" ]; then
  python3 -m py_compile "$W/mi_cribado.py" 2>/dev/null || ko "mi_cribado.py no compila"
  salida=$(python3 "$AQUI/comprobar_cribado.py" "$W/mi_cribado.py" 2>&1) || true
  printf '%s' "$salida" | grep -q '^CRIBADO_OK' || { ko "mi_cribado.py no cumple el contrato:"; printf '%s\n' "$salida" | grep -E '^(FALLO|FALTA)' | sed 's/^/    /'; }
else ko "mi_cribado.py"; fi
if [ -d "$W/data" ]; then (cd "$W/data" && sha256sum -c --quiet manifest.sha256 >/dev/null 2>&1) || ko "data/ no coincide con el manifiesto"; else ko "data/"; fi
if [ -f "$W/notas/ranking.tsv" ]; then
  head -1 "$W/notas/ranking.tsv" | grep -q $'^orden\tcompuesto\tscore\tviolaciones_ro5\ttanimoto\tkd_ilustrativa_um\tpapel\tjustificacion' || ko "notas/ranking.tsv: cabecera distinta de la que genera el espacio de trabajo"
  n=$(awk -F'\t' 'NR>1 && NF>=8 && $2!="" && $3!="" && $4!="" && $5!="" && $6!="" && $7!="" && length($8)>10' "$W/notas/ranking.tsv" | wc -l)
  [ "$n" -ge 10 ] || ko "notas/ranking.tsv: $n compuestos documentados; se exigen los diez de la biblioteca"
  primero=$(awk -F'\t' 'NR==2 {print $2}' "$W/notas/ranking.tsv")
  [ "$primero" = "CMP-01" ] || ko "notas/ranking.tsv: el primer puesto es '$primero'; el control positivo debe encabezar el ranking"
  marcados=$(awk -F'\t' 'NR>1 && tolower($7) ~ /senuelo|señuelo|decoy/' "$W/notas/ranking.tsv" | wc -l)
  [ "$marcados" -ge 2 ] || ko "notas/ranking.tsv: $marcados compuestos marcados como señuelo en la columna de papel; hay dos"
else ko "notas/ranking.tsv"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí las salidas de sus ejecuciones"
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 130 ] && [ "$p" -le 320 ] || ko "notas/defensa.md: $p palabras; se piden entre 150 y 250"; else ko "notas/defensa.md"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/mi_cribado.py" ] || ko "el paquete no contiene mi_cribado.py bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
