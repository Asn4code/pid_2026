#!/usr/bin/env bash
# Verificador de entrega de BC-CH06. No puntúa: la nota la pone quien corrige.
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
if [ -f "$W/mi_calculadora.py" ]; then
  salida=$(python3 "$AQUI/comprobar_calculadora.py" "$W/mi_calculadora.py" 2>&1) || true
  printf '%s' "$salida" | grep -q '^CALCULADORA_OK' || { ko "mi_calculadora.py no cumple el contrato:"; printf '%s\n' "$salida" | grep -E '^(FALLO|FALTA)' | sed 's/^/    /'; }
else ko "mi_calculadora.py"; fi
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^apartado\tprediccion\tresultado\tcoincide\tjustificacion' || ko "notas/respuestas.tsv: cabecera distinta de la esperada"
  n=$(awk -F'\t' 'NR>1 && NF>=5 && $2!="" && $3!="" && length($5)>15' "$W/notas/respuestas.tsv" | wc -l)
  [ "$n" -ge 4 ] || ko "notas/respuestas.tsv: $n filas completas con justificación; se exigen al menos 4"
  awk -F'\t' 'NR>1 && tolower($1) ~ /hueco|poisson|cubrir/' "$W/notas/respuestas.tsv" | grep -q . || ko "falta la fila sobre la fracción sin cubrir"
else ko "notas/respuestas.tsv"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía"
grep -rqs "COVERAGE_X\|GAP_FRACTION" "$W/resultados" || ko "resultados/ no recoge ningún cálculo de cobertura"
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 80 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras; se piden entre 100 y 150"; else ko "notas/defensa.md"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/mi_calculadora.py" ] || ko "el paquete no contiene la calculadora bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
