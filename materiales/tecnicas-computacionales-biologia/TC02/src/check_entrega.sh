#!/usr/bin/env bash
# Verificador de entrega de TC-CH02. Comprueba lo que produce el alumnado, no
# lo que dejó el generador. No puntúa: la nota la pone quien corrige.
# Uso: practice_assets/check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; CAP="$(cd "$AQUI/.." && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
Wabs="$(cd "$W" && pwd)"
# 1 el producto: los cinco guiones cumplen lo pedido
salida=$(bash "$AQUI/comprobar_scripts.sh" "$Wabs" 2>&1) || true
if ! printf '%s' "$salida" | grep -q '^SCRIPTS_OK'; then
  ko "los guiones de scripts/ no cumplen lo pedido:"; printf '%s\n' "$salida" | grep '^FALLO' | sed 's/^/    /'
fi
# 2 corpus intacto
if [ -d "$W/datos/corpus" ]; then (cd "$W/datos" && sha256sum -c --quiet "$CAP/data/manifest.sha256" 2>/dev/null | grep -q . ) && ko "datos/ no coincide con el manifiesto del capítulo"; else ko "datos/corpus"; fi
# 3 tabla de pruebas con predicción previa
if [ -f "$W/notas/pruebas.tsv" ]; then
  head -1 "$W/notas/pruebas.tsv" | grep -q $'^prueba\torden\tprediccion\tresultado\tcoincide' || ko "notas/pruebas.tsv: cabecera distinta de prueba/orden/prediccion/resultado/coincide"
  n=$(awk -F'\t' 'NR>1 && NF>=5 && $3!="" && $4!="" && $5!=""' "$W/notas/pruebas.tsv" | wc -l)
  [ "$n" -ge 5 ] || ko "notas/pruebas.tsv: $n filas completas; se exigen al menos 5 con predicción, resultado y si coincidieron"
else ko "notas/pruebas.tsv"; fi
# 4 salidas guardadas
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía"
# 5 README y defensa
if [ -f "$W/README.md" ]; then [ "$(grep -c . "$W/README.md")" -ge 5 ] || ko "README.md: menos de 5 líneas"; else ko "README.md"; fi
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 120 ] && [ "$p" -le 280 ] || ko "notas/defensa.md: $p palabras; se piden entre 150 y 200"; else ko "notas/defensa.md"; fi
# 6 paquete
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -d "$t/$base/scripts" ] && [ -f "$t/$base/notas/pruebas.tsv" ] || ko "el paquete no contiene scripts/ y notas/pruebas.tsv bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
