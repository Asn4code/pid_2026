#!/usr/bin/env bash
# Verificador de entrega de BC-CH10. No puntúa: la nota la pone quien corrige.
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_delivery.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
if [ -f "$W/mi_diseno.py" ]; then
  python3 -m py_compile "$W/mi_diseno.py" 2>/dev/null || ko "mi_diseno.py no compila"
  salida=$(python3 "$AQUI/comprobar_diseno.py" "$W/mi_diseno.py" 2>&1) || true
  printf '%s' "$salida" | grep -q '^DISENO_OK' || { ko "mi_diseno.py no cumple el contrato:"; printf '%s\n' "$salida" | grep -E '^(FALLO|FALTA)' | sed 's/^/    /'; }
else ko "mi_diseno.py"; fi
if [ -d "$W/data" ]; then (cd "$W/data" && sha256sum -c --quiet manifest.sha256 >/dev/null 2>&1) || ko "data/ no coincide con el manifiesto"; else ko "data/"; fi
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^cebador\tprediccion_gc\tprediccion_tm\tresultado_gc\tresultado_tm\tcoincide\tjustificacion' || ko "notas/respuestas.tsv: cabecera distinta de la que genera el espacio de trabajo"
  n=$(awk -F'\t' 'NR>1 && NF>=7 && $2!="" && $3!="" && $4!="" && $5!="" && $6!="" && length($7)>10' "$W/notas/respuestas.tsv" | wc -l)
  [ "$n" -ge 4 ] || ko "notas/respuestas.tsv: $n cebadores documentados con predicción y resultado; se exigen los cuatro que la fórmula admite"
else ko "notas/respuestas.tsv"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí las salidas de sus ejecuciones"
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 90 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras; se piden entre 100 y 150"; else ko "notas/defensa.md"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/mi_diseno.py" ] || ko "el paquete no contiene mi_diseno.py bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
