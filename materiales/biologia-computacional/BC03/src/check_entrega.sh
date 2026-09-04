#!/usr/bin/env bash
# Verificador de entrega de BC-CH03. No puntúa: la nota la pone quien corrige.
# Uso: practice_assets/check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
if [ -f "$W/mi_procesador_variantes.py" ]; then
  salida=$(python3 "$AQUI/comprobar_procesador.py" "$W/mi_procesador_variantes.py" 2>&1) || true
  printf '%s' "$salida" | grep -q '^PROCESADOR_OK' || { ko "el procesador de variantes no cumple el contrato:"; printf '%s\n' "$salida" | grep -E '^(FALLO|FALTA)' | sed 's/^/    /'; }
else ko "mi_procesador_variantes.py"; fi
if [ -d "$W/datos" ]; then (cd "$W/datos" && sha256sum -c --quiet manifest.sha256 >/dev/null 2>&1) || ko "datos/ no coincide con el manifiesto: el fichero de variantes se ha modificado"; else ko "datos/"; fi
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^apartado\tprediccion\tresultado\tcoincide\tjustificacion' || ko "notas/respuestas.tsv: cabecera distinta de la esperada"
  n=$(awk -F'\t' 'NR>1 && NF>=5 && $2!="" && $3!="" && length($5)>15' "$W/notas/respuestas.tsv" | wc -l)
  [ "$n" -ge 4 ] || ko "notas/respuestas.tsv: $n filas completas con justificación; se exigen al menos 4"
  awk -F'\t' 'NR>1 && tolower($1) ~ /coordenada|posicion|posición|borde/' "$W/notas/respuestas.tsv" | grep -q . || ko "falta la fila sobre la conversión de coordenadas"
else ko "notas/respuestas.tsv"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí la salida de sus ejecuciones"
grep -rqs "TI:" "$W/resultados" || ko "resultados/ no recoge ningún recuento de transiciones y transversiones"
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 80 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras; se piden entre 100 y 150"; else ko "notas/defensa.md"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/mi_procesador_variantes.py" ] || ko "el paquete no contiene el procesador bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
