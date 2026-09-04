#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de TC-CH06: carpetas, oráculo y una
# tabla de respuestas con la cabecera.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto TC06_entrega)
set -euo pipefail
DEST="${1:-TC06_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/verification/chapter_results.sh" "$DEST/herramienta/chapter_results.sh"
chmod +x "$DEST/herramienta/chapter_results.sh"
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/chapter_results.sh"
