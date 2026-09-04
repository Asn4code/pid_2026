#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de TC-CH02: carpetas, copia del corpus,
# plantillas vacías de los cinco guiones y la herramienta de autocomprobación.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto TC02_entrega)
set -euo pipefail
DEST="${1:-TC02_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/datos" "$DEST/scripts" "$DEST/resultados" "$DEST/notas" "$DEST/herramienta"
cp -r -- "$CAP/data/corpus" "$DEST/datos/corpus"
cp -- "$CAP/data/tc02_caso_regex.fasta" "$CAP/data/tc02_anotacion.gff" "$DEST/datos/"
cp -- "$CAP/data/manifest.sha256" "$DEST/datos/manifest.sha256"
cp -- "$AQUI/comprobar_scripts.sh" "$DEST/herramienta/check_scripts.sh"
chmod +x "$DEST/herramienta/check_scripts.sh"
for par in "extremos.sh:primera y ultima linea de secuencia de cada FASTA de datos/corpus" \
           "inventario.sh:conteo de .txt, lista de ficheros regulares y resumen de 10 lineas" \
           "resumir.sh:muestra el fichero entero o solo sus extremos segun su numero de lineas" \
           "normalizar.sh:sustituye con sed el primer espacio de cada cabecera FASTA" \
           "contar_bases.sh:suma con awk las bases de secuencia, excluyendo cabeceras"; do
  nombre="${par%%:*}"; que="${par#*:}"
  cat > "$DEST/scripts/$nombre" <<EOF
#!/usr/bin/env bash
# $nombre - $que
# Escriba aqui su implementacion. Este fichero se entrega vacio a proposito.
set -euo pipefail
exit 0
EOF
  chmod +x "$DEST/scripts/$nombre"
done
printf 'prueba\torden\tprediccion\tresultado\tcoincide\n' > "$DEST/notas/pruebas.tsv"
echo "Espacio de trabajo creado en '$DEST': datos/corpus (21 ficheros + manifiesto), scripts/ (5 plantillas vacías), resultados/ (vacía), notas/pruebas.tsv (solo cabecera), herramienta/check_scripts.sh"
