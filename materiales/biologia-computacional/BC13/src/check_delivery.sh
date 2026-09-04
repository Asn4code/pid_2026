#!/usr/bin/env bash
# Verificador de entrega de BC-CH13. No puntúa: la nota la pone quien corrige.
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_delivery.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
if [ -f "$W/mi_auditoria.py" ]; then
  python3 -m py_compile "$W/mi_auditoria.py" 2>/dev/null || ko "mi_auditoria.py no compila"
  salida=$(python3 "$AQUI/comprobar_auditoria.py" "$W/mi_auditoria.py" 2>&1) || true
  printf '%s' "$salida" | grep -q '^AUDITORIA_OK' || { ko "mi_auditoria.py no cumple el contrato:"; printf '%s\n' "$salida" | grep -E '^(FALLO|FALTA)' | sed 's/^/    /'; }
else ko "mi_auditoria.py"; fi
if [ -d "$W/data" ]; then (cd "$W/data" && sha256sum -c --quiet manifest.sha256 >/dev/null 2>&1) || ko "data/ no coincide con el manifiesto"; else ko "data/"; fi
if [ -f "$W/notas/dictamen.tsv" ]; then
  head -1 "$W/notas/dictamen.tsv" | grep -q $'^modelo\tprediccion_banda_media\tprediccion_pae\tresultado_plddt_medio\tresultado_pae\tuso_admisible\tjustificacion' || ko "notas/dictamen.tsv: cabecera distinta de la que genera el espacio de trabajo"
  n=$(awk -F'\t' 'NR>1 && NF>=7 && $2!="" && $3!="" && $4!="" && $5!="" && $6!="" && length($7)>10' "$W/notas/dictamen.tsv" | wc -l)
  [ "$n" -ge 4 ] || ko "notas/dictamen.tsv: $n modelos dictaminados; se exigen los cuatro del fichero de datos"
else ko "notas/dictamen.tsv"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí las salidas de sus ejecuciones"
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 90 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras; se piden entre 100 y 150"; else ko "notas/defensa.md"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/mi_auditoria.py" ] || ko "el paquete no contiene mi_auditoria.py bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
