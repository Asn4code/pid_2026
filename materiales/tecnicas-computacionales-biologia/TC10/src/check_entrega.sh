#!/usr/bin/env bash
# Verificador de entrega de TC-CH10. No puntúa: la nota la pone quien corrige.
# Uso: practice_assets/check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^bloque\tpregunta\tvalor_manual\tvalor_script\tcoincide' || ko "notas/respuestas.tsv: cabecera distinta de bloque/pregunta/valor_manual/valor_script/coincide"
  n=$(awk -F'\t' 'NR>1 && NF>=5 && $3!="" && $4!="" && $5!=""' "$W/notas/respuestas.tsv" | wc -l)
  [ "$n" -ge 5 ] || ko "notas/respuestas.tsv: $n filas con valor manual, valor del oráculo y veredicto; se exigen al menos 5"
  awk -F'\t' 'NR>1 && tolower($1) ~ /oculta|backward|hidden/' "$W/notas/respuestas.tsv" | grep -q . || ko "falta la fila del paso hacia atrás hasta la capa oculta"
  awk -F'\t' 'NR>1 && $3!="" && $4!="" && $3==$4 && tolower($5) !~ /si|sí/' "$W/notas/respuestas.tsv" | grep -q . && ko "hay filas donde los dos valores coinciden y la columna de veredicto no lo dice"
else ko "notas/respuestas.tsv"; fi
if [ -x "$W/herramienta/chapter_results.sh" ]; then
  v=$(bash "$W/herramienta/chapter_results.sh" forward_enhancer_pass 1.0 0.5 2>/dev/null | grep -o 'Y_HAT:[0-9.]*' | cut -d: -f2)
  [ "${v:-}" = "0.605264" ] || ko "herramienta/chapter_results.sh no reproduce la pasada hacia delante del caso resuelto"
else ko "herramienta/chapter_results.sh no está o no es ejecutable"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí la salida de sus ejecuciones"
grep -rqs "DELTA_H1" "$W/resultados" || ko "resultados/ no recoge el paso hacia atrás hasta la capa oculta"
if [ -f "$W/notas/auditoria.md" ]; then p=$(wc -w < "$W/notas/auditoria.md"); [ "$p" -ge 100 ] || ko "notas/auditoria.md: $p palabras; la auditoría del diseño de validación necesita más desarrollo"; else ko "notas/auditoria.md: falta la auditoría del diseño de validación"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/notas/respuestas.tsv" ] || ko "el paquete no contiene notas/respuestas.tsv bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
