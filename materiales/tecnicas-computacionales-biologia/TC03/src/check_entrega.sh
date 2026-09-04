#!/usr/bin/env bash
# Verificador de entrega de TC-CH03. Comprueba lo que produce el alumnado, no
# lo que dejó el generador. No puntúa: la nota la pone quien corrige.
# Uso: practice_assets/check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
# 1 la auditoría: cabecera correcta y al menos tres fragmentos dictaminados
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^fragmento\tveredicto_ia\torden_real\tjustificacion' || ko "notas/respuestas.tsv: cabecera distinta de fragmento/veredicto_ia/orden_real/justificacion"
  n=$(awk -F'\t' 'NR>1 && NF>=4 && $2!="" && $3!="" && length($4)>20' "$W/notas/respuestas.tsv" | wc -l)
  [ "$n" -ge 3 ] || ko "notas/respuestas.tsv: $n filas con veredicto, orden real y una justificación de más de veinte caracteres; se exigen al menos 3"
  d=$(awk -F'\t' 'NR>1 && $2==$3' "$W/notas/respuestas.tsv" | wc -l)
  [ "$d" -eq 0 ] || ko "notas/respuestas.tsv: en $d filas el veredicto de la máquina y el orden real coinciden; los tres fragmentos del enunciado están mal clasificados"
else ko "notas/respuestas.tsv"; fi
# 2 las mediciones guardadas: los cuatro modos medidos deben aparecer en resultados/
if [ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ]; then
  for m in CALLS COMPUTATIONS OPS STEPS; do
    grep -rqs "$m" "$W/resultados" || ko "resultados/ no contiene ninguna salida con «$m»: faltan mediciones del bloque correspondiente"
  done
else ko "resultados/ vacía: guarde ahí la salida de las mediciones"; fi
# 3 escalado: la entrega debe registrar las cuatro medidas de n y 2n
grep -rqs "OPS:51" "$W/resultados" && grep -rqs "OPS:101" "$W/resultados" || ko "resultados/ no recoge el par de medidas del fragmento lineal con n y con 2n"
grep -rqs "OPS:55" "$W/resultados" && grep -rqs "OPS:210" "$W/resultados" || ko "resultados/ no recoge el par de medidas del fragmento cuadrático con n y con 2n"
# 4 defensa
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 80 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras; se piden entre 100 y 150"; else ko "notas/defensa.md"; fi
# 5 paquete
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/notas/respuestas.tsv" ] || ko "el paquete no contiene notas/respuestas.tsv bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
