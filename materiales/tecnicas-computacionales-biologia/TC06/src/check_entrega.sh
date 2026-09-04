#!/usr/bin/env bash
# Verificador de entrega de TC-CH06. No puntúa: la nota la pone quien corrige.
# Uso: practice_assets/check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^apartado\tprediccion\tresultado\tcoincide\tjustificacion' || ko "notas/respuestas.tsv: cabecera distinta de apartado/prediccion/resultado/coincide/justificacion"
  n=$(awk -F'\t' 'NR>1 && NF>=5 && $2!="" && $3!="" && $4!="" && length($5)>15' "$W/notas/respuestas.tsv" | wc -l)
  [ "$n" -ge 4 ] || ko "notas/respuestas.tsv: $n filas con predicción, resultado, veredicto y justificación; se exigen al menos 4"
  awk -F'\t' 'NR>1 && $2!="" && $3!="" && $2==$3 && tolower($4) !~ /si|sí/' "$W/notas/respuestas.tsv" | grep -q . && ko "hay filas donde predicción y resultado coinciden pero la columna de veredicto no lo dice"
  awk -F'\t' 'NR>1 && tolower($1) ~ /lomuto|particion|partición/' "$W/notas/respuestas.tsv" | grep -q . || ko "falta la fila de la pasada manual del esquema de Lomuto"
else ko "notas/respuestas.tsv"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí la salida de sus ejecuciones"
grep -rqs "COMPARISONS" "$W/resultados" || ko "resultados/ no recoge ningún conteo de comparaciones"
grep -rqs "COMPARISONS:4950" "$W/resultados" && grep -rqs "COMPARISONS:19900" "$W/resultados" || ko "resultados/ no recoge el par de medidas de escalado con n y con 2n"
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 80 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras; se piden entre 100 y 150"; else ko "notas/defensa.md"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/notas/respuestas.tsv" ] || ko "el paquete no contiene notas/respuestas.tsv bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
