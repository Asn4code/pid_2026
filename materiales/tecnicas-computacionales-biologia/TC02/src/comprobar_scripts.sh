#!/usr/bin/env bash
# Comprueba los cinco guiones del anexo de TC-CH02 contra propiedades que
# calcula por su cuenta a partir de datos/corpus. No imprime los valores
# esperados: dice si su resultado los cumple. Ejecútelo desde la entrega.
# Uso: herramienta/check_scripts.sh [DIRECTORIO_ENTREGA]
set -uo pipefail
W="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$W" || { echo "no se puede entrar en $W" >&2; exit 2; }
C="datos/corpus"
[ -d "$C" ] || { echo "FALTA: $W/datos/corpus" ; echo "SCRIPTS_INCOMPLETO"; exit 1; }
fallos=0; ko() { echo "FALLO: $*"; fallos=$((fallos+1)); }; ok() { echo "OK: $*"; }
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

# valores de referencia, calculados aquí y no impresos
n_fasta=$(find "$C" -maxdepth 1 -type f -name '*.fasta' | wc -l | tr -d ' ')
n_txt=$(find "$C" -maxdepth 1 -type f -name '*.txt' | wc -l | tr -d ' ')
n_reg=$(find "$C" -maxdepth 1 -type f | wc -l | tr -d ' ')
n_cab=$(cat "$C"/*.fasta | grep -c '^>')
n_bases=$(cat "$C"/*.fasta | grep -v '^>' | tr -d '\n' | wc -c | tr -d ' ')
corto=$(for f in "$C"/*.fasta; do n=$(wc -l < "$f"); [ "$n" -le 20 ] && { echo "$f"; break; }; done)
largo=$(for f in "$C"/*.fasta; do n=$(wc -l < "$f"); [ "$n" -gt 20 ] && { echo "$f"; break; }; done)

# 0 sintaxis
for s in extremos inventario resumir normalizar contar_bases; do
  if [ -f "scripts/$s.sh" ]; then bash -n "scripts/$s.sh" 2>"$tmp/e" || ko "scripts/$s.sh no pasa bash -n: $(head -1 "$tmp/e")"
  else ko "scripts/$s.sh no existe"; fi
done
[ "$fallos" -eq 0 ] || { echo "SCRIPTS_INCOMPLETO: $fallos"; exit 1; }
ok "los cinco guiones existen y pasan bash -n"

# 1 extremos: nombra todos los FASTA y emite dos líneas de secuencia por fichero
if bash scripts/extremos.sh > "$tmp/ext" 2>"$tmp/exterr"; then
  falta=0
  for f in "$C"/*.fasta; do grep -q "$(basename "$f")" "$tmp/ext" || falta=$((falta+1)); done
  seqs=$(grep -c '^[ACGTNacgtn]\{4,\}' "$tmp/ext")
  if [ "$falta" -gt 0 ]; then ko "extremos.sh no menciona $falta de los $n_fasta ficheros FASTA"
  elif [ "$seqs" -lt $((n_fasta * 2)) ]; then ko "extremos.sh emite $seqs líneas de secuencia; se esperan dos por fichero"
  else ok "extremos.sh recorre los $n_fasta ficheros y emite sus dos extremos"; fi
else ko "extremos.sh termina con error: $(tail -1 "$tmp/exterr")"; fi

# 2 inventario: cuenta los .txt y produce las dos salidas con la longitud debida
if bash scripts/inventario.sh > "$tmp/inv" 2>&1; then
  grep -qw "$n_txt" "$tmp/inv" || ko "inventario.sh no informa del número de ficheros .txt"
  if [ -f resultados/file_list.txt ]; then
    l=$(wc -l < resultados/file_list.txt | tr -d ' ')
    [ "$l" -eq "$n_reg" ] || ko "resultados/file_list.txt tiene $l líneas; debe listar solo los ficheros regulares del corpus"
  else ko "inventario.sh no crea resultados/file_list.txt"; fi
  if [ -f resultados/summary.txt ]; then
    l=$(wc -l < resultados/summary.txt | tr -d ' ')
    [ "$l" -eq 10 ] || ko "resultados/summary.txt tiene $l líneas; se piden las 10 primeras"
  else ko "inventario.sh no crea resultados/summary.txt"; fi
  [ "$fallos" -eq 0 ] && ok "inventario.sh cuenta los .txt y produce las dos salidas"
else ko "inventario.sh termina con error"; fi

# 3 resumir: rama corta, rama larga y ruta inexistente
if [ -n "$corto" ] && [ -n "$largo" ]; then
  bash scripts/resumir.sh "$corto" > "$tmp/corto" 2>/dev/null
  bash scripts/resumir.sh "$largo" > "$tmp/largo" 2>/dev/null
  falta_corto=$(comm -23 <(sort -u "$corto") <(sort -u "$tmp/corto") | wc -l | tr -d ' ')
  falta_largo=$(comm -23 <(sort -u "$largo") <(sort -u "$tmp/largo") | wc -l | tr -d ' ')
  [ "$falta_corto" -eq 0 ] || ko "resumir.sh omite $falta_corto líneas de un fichero de 20 líneas o menos, que debe mostrarse entero"
  [ "$falta_largo" -gt 0 ] || ko "resumir.sh no recorta nada en un fichero de más de 20 líneas"
  bash scripts/resumir.sh "$C/no_existe_jamas.txt" >/dev/null 2>&1 && ko "resumir.sh devuelve estado 0 ante una ruta inexistente" || ok "resumir.sh distingue las dos ramas y falla ante una ruta inexistente"
fi

# 4 normalizar: mismas cabeceras, sin espacios, secuencia intacta, originales sin tocar
antes=$(sha256sum "$C"/*.fasta | sha256sum)
if bash scripts/normalizar.sh > "$tmp/norm" 2>/dev/null; then
  sal="$tmp/norm"
  [ -s "$sal" ] || sal=resultados/normalizado.fasta
  if [ ! -s "$sal" ]; then ko "normalizar.sh no produce salida ni en la salida estándar ni en resultados/normalizado.fasta"; sal=/dev/null; fi
  c=$(grep -c '^>' "$sal" || true); e=$(grep '^>' "$sal" | grep -c ' ' || true)
  c=${c:-0}; e=${e:-0}
  if [ "$sal" != /dev/null ]; then
    [ "$c" -eq "$n_cab" ] || ko "el resultado tiene $c cabeceras y el corpus tiene $n_cab"
    [ "$e" -eq 0 ] || ko "quedan $e cabeceras con espacios en el resultado"
    diff <(grep -v '^>' "$sal" | sort) <(cat "$C"/*.fasta | grep -v '^>' | sort) >/dev/null || ko "normalizar.sh ha alterado líneas de secuencia"
  fi
  [ "$antes" = "$(sha256sum "$C"/*.fasta | sha256sum)" ] || ko "normalizar.sh ha modificado los ficheros de datos/corpus"
else ko "normalizar.sh termina con error"; fi

# 5 contar_bases: el total coincide con el recuento independiente
if bash scripts/contar_bases.sh > "$tmp/bas" 2>/dev/null; then
  grep -qw "$n_bases" "$tmp/bas" || ko "contar_bases.sh no emite el total de bases de secuencia del corpus"
else ko "contar_bases.sh termina con error"; fi

if [ "$fallos" -eq 0 ]; then echo "SCRIPTS_OK: los cinco guiones cumplen lo pedido"; exit 0; fi
echo "SCRIPTS_INCOMPLETO: $fallos comprobaciones sin superar"; exit 1
