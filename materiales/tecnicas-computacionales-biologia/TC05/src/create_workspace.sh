#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de TC-CH05: carpetas, datos de partida,
# oráculo, comprobador y dos plantillas vacías.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto TC05_entrega)
set -euo pipefail
DEST="${1:-TC05_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/datos" "$DEST/notas" "$DEST/resultados" "$DEST/scripts" "$DEST/herramienta"
cp -- "$CAP/data/tc05_red_interaccion.tsv" "$CAP/data/manifest.sha256" "$DEST/datos/"
cp -- "$CAP/verification/chapter_results.sh" "$DEST/herramienta/chapter_results.sh"
cp -- "$AQUI/comprobar_scripts.sh" "$DEST/herramienta/check_scripts.sh"
chmod +x "$DEST/herramienta/"*.sh
cat > "$DEST/scripts/mi_tabla_codones.sh" <<'EOF'
#!/usr/bin/env bash
# mi_tabla_codones.sh SECUENCIA - tabla de dispersion de codones propia.
# Escriba aqui su implementacion.
#
# Debe imprimir una linea por cada uno de los tres marcos de lectura:
#   MARCO:0 CODONES:AUG-AAU-... AMINOACIDOS:Met-Asn-...
# y una linea final con el tamano de su tabla y las colisiones que produjo
# su funcion de dispersion sobre los codones leidos:
#   DISPERSION:<tamano> COLISIONES:<numero>
set -euo pipefail
exit 0
EOF
cat > "$DEST/scripts/mi_bfs.sh" <<'EOF'
#!/usr/bin/env bash
# mi_bfs.sh ORIGEN - recorrido en anchura sobre datos/tc05_red_interaccion.tsv.
# Escriba aqui su implementacion.
#
# Debe imprimir dos lineas:
#   BFS:<nodo1> <nodo2> ...   (orden de visita desde ORIGEN)
#   VISITADOS:<cuantos>
# Los vecinos de cada nodo se recorren en orden numerico creciente.
set -euo pipefail
exit 0
EOF
chmod +x "$DEST/scripts/"*.sh
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': datos/ (red y manifiesto), scripts/ (dos plantillas vacías), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador)"
