#!/usr/bin/env bash
# Verificador de entrega de TC-CH09. No puntúa: la nota la pone quien corrige.
# Uso: practice_assets/check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
Wabs="$(cd "$W" && pwd)"
salida=$(bash "$AQUI/comprobar_entrega.sh" "$Wabs" 2>&1) || true
printf '%s' "$salida" | grep -q '^TRABAJO_OK' || { ko "la matriz o el guion no cumplen lo pedido:"; printf '%s\n' "$salida" | grep '^FALLO' | sed 's/^/    /'; }
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^apartado\tprediccion\tresultado\tcoincide\tjustificacion' || ko "notas/respuestas.tsv: cabecera distinta de la esperada"
  n=$(awk -F'\t' 'NR>1 && NF>=5 && $2!="" && $3!="" && length($5)>15' "$W/notas/respuestas.tsv" | wc -l)
  [ "$n" -ge 5 ] || ko "notas/respuestas.tsv: $n filas completas con justificación; se exigen al menos 5"
  awk -F'\t' 'NR>1 && tolower($1) ~ /esperado|evalue|e-value/' "$W/notas/respuestas.tsv" | grep -q . || ko "falta la fila del valor esperado"
else ko "notas/respuestas.tsv"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí la salida de sus ejecuciones"
c=$(grep -rlso "EVALUE:" "$W/resultados" 2>/dev/null | wc -l)
[ "$c" -ge 1 ] && [ "$(grep -rhso 'EVALUE:[0-9.]*' "$W/resultados" | sort -u | wc -l)" -ge 3 ] || ko "resultados/ no recoge tres valores esperados distintos: hacen falta los tres del bloque de sensibilidad"
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 80 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras; se piden entre 100 y 150"; else ko "notas/defensa.md"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/notas/mi_matriz.tsv" ] && [ -f "$t/$base/scripts/verificar_puntuacion.sh" ] || ko "el paquete no contiene la matriz y el guion bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
