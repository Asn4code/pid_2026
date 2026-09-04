#!/usr/bin/env bash
# Verificador de entrega de TC-CH01. Comprueba lo que produce el alumno, no lo que dejó el generador.
# Uso: practice_assets/check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]
# Termina con ENTREGA_OK y código 0 solo si todo está; no puntúa.
set -uo pipefail
W="${1:-}"; TAR="${2:-}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; CAP="$(cd "$AQUI/.." && pwd)"
fallos=0; ko() { echo "FALTA: $*"; fallos=$((fallos+1)); }
[ -n "$W" ] && [ -d "$W" ] || { echo "uso: check_entrega.sh DIRECTORIO_ENTREGA [PAQUETE.tar.gz]" >&2; exit 2; }
# 1 datos intactos frente al manifiesto del capítulo
if [ -d "$W/datos" ]; then (cd "$W/datos" && sha256sum -c --quiet "$CAP/data/manifest.sha256" >/dev/null 2>&1) || ko "datos/ no coincide con el manifiesto del capítulo (¿se modificó algún fichero de partida?)"; else ko "datos/"; fi
# 2 registro de entorno con los siete campos rellenos
if [ -f "$W/notas/entorno.tsv" ]; then bash "$AQUI/registrar_entorno.sh" --validar "$W/notas/entorno.tsv" >/dev/null 2>&1 || ko "notas/entorno.tsv incompleto o con campos PENDIENTE"; else ko "notas/entorno.tsv"; fi
# 3 respuestas: cabecera de cuatro columnas y al menos cuatro filas propias con predicción y resultado
if [ -f "$W/notas/respuestas.tsv" ]; then
  head -1 "$W/notas/respuestas.tsv" | grep -q $'^pregunta\torden\tprediccion\tresultado' || ko "notas/respuestas.tsv: cabecera distinta de pregunta/orden/prediccion/resultado"
  n=$(awk -F'\t' 'NR>1 && NF>=4 && $3!="" && $4!=""' "$W/notas/respuestas.tsv" | wc -l); [ "$n" -ge 4 ] || ko "notas/respuestas.tsv: $n filas completas (se exigen al menos 4, con predicción y resultado)"
else ko "notas/respuestas.tsv"; fi
# 4 protección: salida de pwd y de ls -ld
if [ -f "$W/notas/proteccion.txt" ]; then grep -q '^/' "$W/notas/proteccion.txt" && grep -q '^d[rwx-]' "$W/notas/proteccion.txt" || ko "notas/proteccion.txt: debe contener la salida de pwd (una ruta absoluta) y la de ls -ld (una línea que empieza por d)"; else ko "notas/proteccion.txt"; fi
# 5 resultados no vacía y README con órdenes
[ -d "$W/resultados" ] && [ -n "$(ls -A "$W/resultados" 2>/dev/null)" ] || ko "resultados/ vacía"
if [ -f "$W/README.md" ]; then [ "$(grep -c . "$W/README.md")" -ge 5 ] || ko "README.md: menos de 5 líneas"; else ko "README.md"; fi
# 6 defensa de 100 a 150 palabras
if [ -f "$W/notas/defensa.md" ]; then p=$(wc -w < "$W/notas/defensa.md"); [ "$p" -ge 80 ] && [ "$p" -le 220 ] || ko "notas/defensa.md: $p palabras (se piden 100-150)"; else ko "notas/defensa.md"; fi
# 7 paquete: existe, se extrae en un temporal y contiene el registro y las respuestas
if [ -n "$TAR" ]; then
  if [ -f "$TAR" ]; then t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
    tar -xzf "$TAR" -C "$t" 2>/dev/null || ko "el paquete no se extrae"
    base=$(basename "$W"); [ -f "$t/$base/notas/entorno.tsv" ] && [ -f "$t/$base/notas/respuestas.tsv" ] || ko "el paquete no contiene notas/entorno.tsv y notas/respuestas.tsv bajo $base/"
  else ko "paquete $TAR"; fi
fi
if [ "$fallos" -eq 0 ]; then echo "ENTREGA_OK: la entrega está completa"; exit 0; else echo "ENTREGA_INCOMPLETA: $fallos elementos por resolver"; exit 1; fi
