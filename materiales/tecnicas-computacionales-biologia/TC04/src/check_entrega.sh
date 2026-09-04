#!/usr/bin/env bash
# Verificador de entrega de TC-CH04. Comprueba lo que produce el alumnado.
# No puntúa: la nota la pone quien corrige.
# Uso: practice_assets/check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
Wabs="$(cd "$W" && pwd)"
salida=$(bash "$AQUI/comprobar_estructuras.sh" "$Wabs" 2>&1) || true
printf '%s' "$salida" | grep -q '^ESTRUCTURAS_OK' || { ko "la pila y la cola no cumplen su contrato:"; printf '%s\n' "$salida" | grep '^FALLO' | sed 's/^/    /'; }
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^apartado\tprediccion\tresultado\tjustificacion' || ko "notas/respuestas.tsv: cabecera distinta de apartado/prediccion/resultado/justificacion"
  n=$(awk -F'\t' 'NR>1 && NF>=4 && $2!="" && $3!="" && length($4)>15' "$W/notas/respuestas.tsv" | wc -l)
  [ "$n" -ge 4 ] || ko "notas/respuestas.tsv: $n filas con predicción, resultado y justificación; se exigen al menos 4"
else ko "notas/respuestas.tsv"; fi
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí la salida de sus ejecuciones"
grep -rqs "STACK" "$W/resultados" || ko "resultados/ no recoge ninguna validación con pila"
grep -rqs "DEQUEUED\|DEQUEUE" "$W/resultados" || ko "resultados/ no recoge el orden de salida de la cola"
if [ -f "$W/notas/dos_colas.md" ]; then [ "$(wc -w < "$W/notas/dos_colas.md")" -ge 60 ] || ko "notas/dos_colas.md: demasiado breve para explicar el coste de las dos operaciones"; else ko "notas/dos_colas.md: falta la simulación de una pila con dos colas"; fi
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 80 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras; se piden entre 100 y 150"; else ko "notas/defensa.md"; fi
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/scripts/mi_pila.sh" ] && [ -f "$t/$base/scripts/mi_cola.sh" ] || ko "el paquete no contiene los dos guiones bajo $base/scripts/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
