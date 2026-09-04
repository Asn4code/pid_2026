#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de TC-CH01. Solo carpetas, copias de los datos de partida y plantillas vacías.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto TC01_entrega)
set -euo pipefail
DEST="${1:-TC01_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/datos" "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/data/tc01_mini.fasta" "$CAP/data/tc01_sample.fasta" "$CAP/data/tc01_sample.log" "$CAP/data/tc01_notas campo.txt" "$DEST/datos/"
cp -- "$CAP/data/manifest.sha256" "$DEST/datos/manifest.sha256"
cp -- "$CAP/verification/chapter_results.sh" "$DEST/herramienta/chapter_results.sh"
chmod +x "$DEST/herramienta/chapter_results.sh"
printf 'pregunta\torden\tprediccion\tresultado\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': datos/ (4 ficheros + manifiesto), notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/chapter_results.sh"
