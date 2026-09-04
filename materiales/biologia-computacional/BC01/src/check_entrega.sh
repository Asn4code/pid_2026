#!/usr/bin/env bash
# Verificador de entrega de BC-CH01. Comprueba lo que produce el alumnado,
# no lo que dejó el generador. No puntúa: la nota la pone quien corrige.
# Uso: practice_assets/check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; CAP="$(cd "$AQUI/.." && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
# 1 el producto: el módulo cumple las cinco propiedades con secuencias que el enunciado no muestra
if [ -f "$W/mi_modulo_secuencias.py" ]; then
  salida=$(python3 "$AQUI/comprobar_modulo.py" "$W/mi_modulo_secuencias.py" 2>&1) || true
  if ! printf '%s' "$salida" | grep -q '^MODULO_OK'; then
    ko "mi_modulo_secuencias.py no cumple el contrato:"; printf '%s\n' "$salida" | sed 's/^/    /'
  fi
else ko "mi_modulo_secuencias.py"; fi
# 2 los datos de partida no se han tocado
if [ -d "$W/datos" ]; then (cd "$W/datos" && sha256sum -c --quiet "$CAP/data/manifest.sha256" >/dev/null 2>&1) || ko "datos/ no coincide con el manifiesto del capítulo: se modificó algún fichero de partida"; else ko "datos/"; fi
# 3 predicciones y resultados: al menos cinco filas propias
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^pregunta\tprediccion\tresultado\tcoincide' || ko "notas/respuestas.tsv: cabecera distinta de pregunta/prediccion/resultado/coincide"
  n=$(awk -F'\t' 'NR>1 && NF>=4 && $2!="" && $3!="" && $4!=""' "$W/notas/respuestas.tsv" | wc -l)
  [ "$n" -ge 5 ] || ko "notas/respuestas.tsv: $n filas completas; se exigen al menos 5 con predicción, resultado y si coincidieron"
else ko "notas/respuestas.tsv"; fi
# 4 salidas guardadas
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía: guarde ahí la salida de sus ejecuciones"
# 5 el informe de las lecturas crudas
if [ -f "$W/notas/lecturas.md" ]; then
  for l in lect_01 lect_02 lect_03 lect_04; do grep -q "$l" "$W/notas/lecturas.md" || ko "notas/lecturas.md no dictamina sobre $l"; done
else ko "notas/lecturas.md: falta el dictamen sobre las cuatro lecturas crudas"; fi
# 6 README y defensa
if [ -f "$W/README.md" ]; then [ "$(grep -c . "$W/README.md")" -ge 5 ] || ko "README.md: menos de 5 líneas"; else ko "README.md"; fi
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 80 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras; se piden entre 100 y 150"; else ko "notas/defensa.md"; fi
# 7 el paquete se extrae y lleva dentro el producto
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/mi_modulo_secuencias.py" ] && [ -f "$t/$base/notas/respuestas.tsv" ] || ko "el paquete no contiene mi_modulo_secuencias.py y notas/respuestas.tsv bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
