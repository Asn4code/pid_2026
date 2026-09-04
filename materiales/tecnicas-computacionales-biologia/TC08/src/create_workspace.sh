#!/usr/bin/env bash
# Crea el espacio de trabajo del anexo de TC-CH08: carpetas, oráculo, la
# secuencia de partida para estimar la matriz y plantillas vacías.
# Uso: practice_assets/create_workspace.sh [DESTINO]   (por defecto TC08_entrega)
set -euo pipefail
DEST="${1:-TC08_entrega}"
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAP="$(cd "$AQUI/.." && pwd)"
if [ -e "$DEST" ]; then echo "ERROR: '$DEST' ya existe; elija otro nombre o retírelo antes." >&2; exit 1; fi
mkdir -p "$DEST/datos" "$DEST/notas" "$DEST/resultados" "$DEST/herramienta"
cp -- "$CAP/verification/chapter_results.sh" "$DEST/herramienta/chapter_results.sh"
cp -- "$AQUI/comprobar_matriz.sh" "$DEST/herramienta/check_matriz.sh"
chmod +x "$DEST/herramienta/"*.sh
cat > "$DEST/datos/secuencia_entrenamiento.txt" <<'EOF'
ACGACGTACGGCGACGTTACGACGCGTACGACGGCGTACGACGTTACGCG
EOF
cat > "$DEST/datos/secuencia_prueba.txt" <<'EOF'
ACGCGTACG
EOF
printf 'contexto\thacia_A\thacia_C\thacia_G\thacia_T\n' > "$DEST/notas/mi_matriz.tsv"
printf 'apartado\tprediccion\tresultado\tcoincide\tjustificacion\n' > "$DEST/notas/respuestas.tsv"
echo "Espacio de trabajo creado en '$DEST': datos/ (secuencia de entrenamiento y de prueba), notas/mi_matriz.tsv y notas/respuestas.tsv (solo cabecera), resultados/ (vacía), herramienta/ (oráculo y comprobador de la matriz)"
