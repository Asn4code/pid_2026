#!/usr/bin/env bash
# Genera un registro de entorno de siete campos (los automáticos rellenos, los de juicio marcados PENDIENTE) y lo valida.
# Uso: registrar_entorno.sh RUTA_SALIDA.tsv | --validar RUTA.tsv | --selftest
set -euo pipefail
campos=(sistema bash_version origen_datos fecha ordenes resultado_esperado limitaciones)
validar() {
  local f="$1" faltan=() pend=()
  for c in "${campos[@]}"; do
    grep -q "^${c}"$'\t' "$f" 2>/dev/null || faltan+=("$c")
    grep -q "^${c}"$'\t'"PENDIENTE" "$f" 2>/dev/null && pend+=("$c")
  done
  if [ "${#faltan[@]}" -gt 0 ]; then printf 'ERROR: registro incompleto, faltan: %s\n' "${faltan[*]}" >&2; return 1; fi
  if [ "${#pend[@]}" -gt 0 ]; then printf 'ERROR: campos sin rellenar: %s\n' "${pend[*]}" >&2; return 1; fi
  return 0
}
generar() {
  { printf 'sistema\t%s\n' "$(uname -a)"; printf 'bash_version\t%s\n' "${BASH_VERSION}"
    printf 'origen_datos\tPENDIENTE: describa de dónde proceden los datos\n'
    printf 'fecha\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'ordenes\tPENDIENTE: liste las órdenes ejecutadas\n'
    printf 'resultado_esperado\tPENDIENTE: describa el resultado esperado\n'
    printf 'limitaciones\tPENDIENTE: describa las limitaciones conocidas\n'; } > "$1"
}
case "${1:-}" in
  --selftest) t=$(mktemp -d); trap 'rm -rf "$t"' EXIT; generar "$t/a.tsv"
     validar "$t/a.tsv" 2>/dev/null && { echo "SELFTEST_FAIL registro-con-PENDIENTE-aceptado" >&2; exit 1; }
     sed 's/PENDIENTE[^\t]*/relleno/' "$t/a.tsv" > "$t/b.tsv"; validar "$t/b.tsv" || { echo "SELFTEST_FAIL registro-completo-rechazado" >&2; exit 1; }
     grep -v '^limitaciones' "$t/b.tsv" > "$t/c.tsv"; validar "$t/c.tsv" 2>/dev/null && { echo "SELFTEST_FAIL registro-incompleto-aceptado" >&2; exit 1; }
     echo SELFTEST_OK ;;
  --validar) validar "${2:?ruta}" && echo "REGISTRO_OK $2" ;;
  "") echo "uso: registrar_entorno.sh RUTA_SALIDA.tsv | --validar RUTA.tsv | --selftest" >&2; exit 2 ;;
  *) generar "$1"; echo "REGISTRO_GENERADO $1: complete los tres campos PENDIENTE con su propio juicio antes de entregar" ;;
esac
